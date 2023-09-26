//
//  CoreDataManager.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 7/31/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
    static let shared = CoreDataManager()
    let modelName = "Wardrobe"
    private var _mainContext: NSManagedObjectContext?
    private var privateContext: NSManagedObjectContext!
    private var _managedObjectModel: NSManagedObjectModel?
    private var _persistentStoreCoordinator: NSPersistentStoreCoordinator?
    
    // MARK: Context
    var managedObjectContext: NSManagedObjectContext? {
        if Thread.isMainThread {
            return mainContext
        }
        return backgroundContext
    }
    
    func saveContext() {
        if Thread.current.isMainThread {
            saveMainContext()
        } else {
            saveBackgroundContext()
        }
    }
    
    private func saveMainContext () {
        if let mainContext = _mainContext {
            if mainContext.hasChanges {
                do {
                    try mainContext.save()
                    if self.privateContext.hasChanges {
                        self.privateContext.perform({[unowned self] in
                            do {
                                try self.privateContext?.save()
                            } catch let error as NSError {
                                print("Failed to save private context - \(error.description)")
                            }
                        })
                    }
                } catch let error as NSError {
                    print("Failed to save main context - \(error.description)")
                }
            }
        }
    }
    
    private func saveBackgroundContext () {
        if let bgContext: NSManagedObjectContext = self.backgroundContext {
            if bgContext.hasChanges {
                bgContext.performAndWait {
                    do {
                        try bgContext.save()
                    } catch let error as NSError {
                        print(error.description)
                    }
                }
                _mainContext?.perform({
                    self.saveMainContext()
                })
            }
        }
    }
    
    private var mainContext: NSManagedObjectContext {
        if _mainContext == nil {
            self.privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            self.privateContext.persistentStoreCoordinator = self.persistentStoreCoordinator
            self.privateContext.undoManager = nil
            _mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            _mainContext!.parent = self.privateContext
            _mainContext!.undoManager = nil
        }
        return _mainContext!
    }
    
    private var backgroundContext: NSManagedObjectContext? {
        var bgContext: NSManagedObjectContext?
        if _mainContext != nil {
            let threadDictionary = Thread.current.threadDictionary
            bgContext = threadDictionary.value(forKey: "backgroundContext") as? NSManagedObjectContext
            if bgContext == nil || bgContext!.parent != _mainContext {
                bgContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                bgContext!.parent = _mainContext
                bgContext!.undoManager = nil
                threadDictionary.setValue(bgContext, forKey: "backgroundContext")
            }
        }
        return bgContext
    }
    private var managedObjectModel: NSManagedObjectModel {
        assert(Thread.isMainThread, "Model should be initialized in Main Thread")
        if _managedObjectModel == nil {
            if let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") {
                _managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
            }
        }
        return _managedObjectModel!
    }
    
    private var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        if _persistentStoreCoordinator == nil {
            assert(Thread.isMainThread, "Persistent Store should be initialized in Main Thread")
            let storeURL = UIApplication.appDelegate.applicationDocumentsDirectory.appendingPathComponent(modelName + ".sqlite")
            _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            do {
                try _persistentStoreCoordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: [NSMigratePersistentStoresAutomaticallyOption : true, NSPersistentStoreFileProtectionKey: FileProtectionType.complete, NSInferMappingModelAutomaticallyOption : true])
            } catch _ {
                print("ABORT!!!!")
            }
            
            // prevent persistant storage files from the iCloud backup
            storageExcludeFromBackup()
        }
        return _persistentStoreCoordinator!
    }
    
    func storageExcludeFromBackup() {
        let appDelegate = UIApplication.appDelegate
        var storeURL = appDelegate.applicationDocumentsDirectory.appendingPathComponent(modelName + ".sqlite")
        do {
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try storeURL.setResourceValues(resourceValues)
        } catch {
            print(error.localizedDescription)
        }
        storeURL = appDelegate.applicationDocumentsDirectory.appendingPathComponent(modelName + ".sqlite-shm")
        do {
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try storeURL.setResourceValues(resourceValues)
        } catch {
            print(error.localizedDescription)
        }
        storeURL = appDelegate.applicationDocumentsDirectory.appendingPathComponent(modelName + ".sqlite-wal")
        do {
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try storeURL.setResourceValues(resourceValues)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension CoreDataManager {
    
    func insertNewObject(entityName: String) -> NSManagedObject! {
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: self.managedObjectContext!)
    }
    
    func allObjectsForEntity(entityName: String, sortDescriptors: [NSSortDescriptor]? = nil, limit: Int? = nil) -> [AnyObject]? {
        if let m = self.managedObjectContext {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            fetch.sortDescriptors = sortDescriptors
            fetch.includesPropertyValues = false
            fetch.includesPendingChanges = false
            if let limit = limit {
                fetch.fetchLimit = limit
            }
            return try! m.fetch(fetch) as [AnyObject]?
        }
        return nil
    }
    
    func objectsForEntity(entityName: String, sortDescriptors: [NSSortDescriptor]? = nil, predicates: [NSPredicate]? = nil) -> [AnyObject]? {
        if let m = self.managedObjectContext {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            fetch.sortDescriptors = sortDescriptors
            if let p = predicates {
                fetch.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: p)
            }
            return try! m.fetch(fetch) as [AnyObject]?
        }
        return nil
    }
    
    func allObjectsCountForEntity(entityName: String) -> Int {
        if let m = self.managedObjectContext {
            return try! m.count(for: NSFetchRequest<NSFetchRequestResult>(entityName: entityName))
        }
        return 0
    }
    
    func objectWithID(id: Int64, entityName: String) -> NSManagedObject? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.includesPropertyValues = false
        request.fetchLimit = 1
        let strFormat = "id == %d"
        request.predicate = NSPredicate(format: strFormat, argumentArray: [id])
        var error : NSError?
        do {
            if let managedObjectContext = CoreDataManager.shared.managedObjectContext {
                let result = try managedObjectContext.fetch(request)
                if error == nil && result.count > 0 {
                    return result[0] as? NSManagedObject
                }
            }
        } catch let error1 as NSError {
            error = error1
        }
        return nil
    }
    
    func objectCustomID(id: String, property: String = "tempId", entityName: String) -> NSManagedObject? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.includesPropertyValues = false
        request.fetchLimit = 1
        let strFormat = "\(property) == %@"
        request.predicate = NSPredicate(format: strFormat, argumentArray: [id])
        var error : NSError?
        do {
            if let managedObjectContext = CoreDataManager.shared.managedObjectContext {
                let result = try managedObjectContext.fetch(request)
                if error == nil && result.count > 0 {
                    return result[0] as? NSManagedObject
                }
            }
        } catch let error1 as NSError {
            error = error1
        }
        return nil
    }
    
    func deleteAllObjects(entityName: String) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetch.includesPropertyValues = false
        self.deleteObjectsByFetchRequest(fetchRequest: fetch)
    }
    
    func deleteObjectsByFetchRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
         if let objects = (try? self.managedObjectContext?.fetch(fetchRequest)) as? [NSManagedObject] {
             for object in objects {
                 self.managedObjectContext!.delete(object)
             }
         }
    }
    
    func deleteObjectWithId(id: Int64, entityName: String) {
        guard let object = objectWithID(id: id, entityName: entityName) else { return }
        self.managedObjectContext!.delete(object)
    }
    
    func deleteObjects(objects: [NSManagedObject]) {
        for object in objects {
            self.managedObjectContext!.delete(object)
        }
    }
    
    func deleteObject(object: NSManagedObject) {
        self.managedObjectContext!.delete(object)
    }
    
    public func clearAllCoreData() {
        let entities = persistentStoreCoordinator.managedObjectModel.entities
        entities.compactMap({ $0.name }).forEach(clearDeepObjectEntity)
    }

    private func clearDeepObjectEntity(_ entity: String) {

        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try self.managedObjectContext?.execute(deleteRequest)
            try self.managedObjectContext?.save()
        } catch {
            print ("There was an error")
        }
    }
}

//MARK:- Coredata fetch func
extension CoreDataManager {
    func getProfile() -> Profile? {
        return allObjectsForEntity(entityName: EntityName.profile)?.first as? Profile
    }
    
    func getAllCalendars() -> [CalendarEvent]? {
        let predicate = NSPredicate(format: "delete == \(false)")
        return CoreDataManager.shared.objectsForEntity(entityName: EntityName.calendarEvent, predicates: [predicate]) as? [CalendarEvent]
    }
    
    func getConstants(_ type: ServerConstants, _ genderId: Int16?) -> [BaseConstant]? {
        if genderId != nil {
            let predicate = NSPredicate(format: "genderId == \(genderId!) OR genderId == nil")
            return CoreDataManager.shared.objectsForEntity(entityName: ServerConstants.entityNames[type]!, predicates: [predicate]) as? [BaseConstant]
        } else {
            return CoreDataManager.shared.allObjectsForEntity(entityName: ServerConstants.entityNames[type]!) as? [BaseConstant]
        }
    }
    
    func getConstant(_ type: ServerConstants, _ id: Int64) -> BaseConstant?{
        let predicate = NSPredicate(format: "id == \(id)")
        return CoreDataManager.shared.objectsForEntity(entityName: ServerConstants.entityNames[type]!, predicates: [predicate])?.first as? BaseConstant
    }
    
    func getTypesConstant(_ clothingTypeId: Int64, _ genderId: Int16?) -> [ItemTypes]? {
        var predicate: NSPredicate!
        if genderId != nil {
             predicate = NSPredicate(format: "(genderId == \(genderId!) || genderId == nil) && clothingTypeId == \(clothingTypeId)")
        } else {
             predicate = NSPredicate(format: "clothingTypeId == \(clothingTypeId)")
        }
           
        return CoreDataManager.shared.objectsForEntity(entityName: EntityName.itemTypes, predicates: [predicate]) as? [ItemTypes]
    }
    
    func getClothingTypeItemCount(_ id: Int64) -> Int {
        if let m = self.managedObjectContext {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.item)
            let predicate = NSPredicate(format: "clothingType == \(id)")
            fetch.includesPropertyValues = false
            fetch.includesPendingChanges = false
            fetch.predicate = predicate
            return try! m.count(for: fetch)
        }
        return 0
    }
}

