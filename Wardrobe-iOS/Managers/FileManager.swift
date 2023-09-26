//
//  FileManager.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 5/8/20.
//

import UIKit

class FileManagerSW: NSObject {
    static let manager: FileManagerSW = FileManagerSW()
    private let fileManager = FileManager.default

    private override init() { }
    
    func saveFile(name: String, id: String, data: Data) {
        let fileManager = FileManager.default
        do {
            let documentDirectoryURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let folderURL = documentDirectoryURL.appendingPathComponent(name)
            let imagesFolderURL = folderURL.appendingPathComponent(id)
            
            if !fileManager.fileExists(atPath: folderURL.path){
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            }
            try data.write(to: imagesFolderURL)

        } catch {
            print(error)
        }
    }
        
    func getFile(name: String, id: String) -> Data? {
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent(name).appendingPathComponent(id)
            let savedData = try Data(contentsOf: fileURL)
            return savedData
        } catch {
            print(error)
        }
        return nil
    }
    
    func removeFile(name: String, id: String) {
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent(name).appendingPathComponent(id)
            try fileManager.removeItem(at: fileURL)
        } catch {
            print(error)
        }
    }
    
    func removeFileWithId(name: String, id: Int64) {
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent(name).appendingPathComponent("\(id)")
            try fileManager.removeItem(at: fileURL)
        } catch {
            print(error)
        }
    }
    
    func removeDirectory(name : String) {
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent(name)
            try fileManager.removeItem(at: fileURL)
        } catch {
            print(error)
        }
    }
}
