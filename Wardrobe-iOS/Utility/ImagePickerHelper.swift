//
//  ImagePickerHelper.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 10/16/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

protocol ImagePickerHelperDelegate: class {
    func imagePickerHelper(_ pickerHelper: ImagePickerHelper, didFinishGetData imageData: Data)
    func imagePickerHelperDidCancel(_ pickerHelper: ImagePickerHelper)
}

class ImagePickerHelper: NSObject {
    
    // MARK: - Properties
    private let imageMediaType = "public.image"
    private let imagePicker = UIImagePickerController()
    weak var delegate: ImagePickerHelperDelegate?

    // MARK: - Init
    override init() {
        super.init()
        imagePicker.modalPresentationStyle = .fullScreen
        imagePicker.delegate = self
        imagePicker.mediaTypes = [imageMediaType]
    }
    
    // MARK: - Public interface
    func libraryAction(completionHandler:@escaping (_ controller: UIViewController?, _ denied: Bool) -> Void) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let statusBeforeRequest = PHPhotoLibrary.authorizationStatus()
            PHPhotoLibrary.requestAuthorization({ result in
                DispatchQueue.main.async {
                    let status = PHPhotoLibrary.authorizationStatus()
                    if status == .authorized {
                        self.imagePicker.sourceType = .photoLibrary
                        completionHandler(self.showGalery(), false)
                    } else if status != .notDetermined && statusBeforeRequest != .notDetermined {
                        completionHandler(nil, true)
                    }
                }
            })
        }
    }
    
    func showGalery() -> UIViewController {
        if #available(iOS 14, *) {
            var configuration = PHPickerConfiguration()
            configuration.filter = .images
            configuration.selectionLimit = 1
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            return picker
        } else {
            return imagePicker
        }
    }
}

//MARK:- UIImagePickerControllerDelegate
extension ImagePickerHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
            PHImageManager.default().requestImageData(for: asset, options: nil) { (imageData, dataUTI, orientation, info) in
                if let data = imageData {
                    picker.dismiss(animated: true, completion: nil)
                    self.delegate?.imagePickerHelper(self, didFinishGetData: data)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.delegate?.imagePickerHelperDidCancel(self)
    }
}


//MARK:- New ImagePicker
@available(iOS 14, *)
extension ImagePickerHelper: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult])
    {
        guard let provider = results.first?.itemProvider else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { (data, error) in
            DispatchQueue.main.async {
                picker.dismiss(animated: true, completion: nil)
                self.delegate?.imagePickerHelper(self, didFinishGetData: data ?? Data())
            }
        }
        
    }
}

