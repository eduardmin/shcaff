//
//  AlertPresenter.swift
//  Menu
//
//  Created by Mariam on 11/20/19.
//  Copyright © 2019 Menu Group (UK) LTD. All rights reserved.
//

import UIKit

enum InfoAlertType {
    case clearItemCategory
    case deleteAlbum(String)
    case deleteEvent(String)
    case deleteItem(String)
    case logout
    case deleteAccount
}

class AlertPresenter: NSObject {
    
    typealias AlertActionCompletion = ((Any?) -> Void)?
    
    //MARK:- Public functions
    
    static func presentInfoAlert(on viewController: UIViewController, type: InfoAlertType, dismissOnTouch: Bool = false, delegate: AlertPresenterDelegate? = nil, confirmButtonCompletion: AlertActionCompletion = nil, cancelButtonCompletion: AlertActionCompletion = nil) {
        var title: String? = ""
        var message: String? = ""
        let image: String? = ""
        var confirmButtonTitle: String? = nil
        var cancelButtonTitle: String? = nil
        var confirmButtonMode: ButtonMode?
        switch type {
        case .clearItemCategory:
            title = "Clear all items?".localize()
            message = "Are you sure you want to clear items from the “Create Look” page?".localize()
            confirmButtonTitle = "Clear".localize()
            cancelButtonTitle = "Cancel".localize()
        case .deleteAlbum(let name):
            title = String(format: "Delete Album?".localize(), name)
            message = "By deleting this album you are deleting all the saved looks and sets on it.".localize()
            confirmButtonTitle = "Delete".localize()
            cancelButtonTitle = "Cancel".localize()
            confirmButtonMode = .delete
        case .deleteEvent(let name):
            title = String(format: "Delete Event?".localize(), name)
            message = "By deleting this event you are deleting the saved looks or sets on it.".localize()
            confirmButtonTitle = "Delete".localize()
            cancelButtonTitle = "Cancel".localize()
            confirmButtonMode = .delete
        case .deleteItem(let name):
            title = String(format: "Delete Item?".localize(), name)
            message = "By deleting this item you are deleting it from all the saved looks and sets.".localize()
            confirmButtonTitle = "Delete".localize()
            cancelButtonTitle = "Cancel".localize()
            confirmButtonMode = .delete
        case .logout:
            title = "Log Out".localize()
            message = "Are you sure you want to log out from your account?".localize()
            confirmButtonTitle = "Log Out".localize()
            cancelButtonTitle = "Cancel".localize()
            confirmButtonMode = .delete
        case .deleteAccount:
            title = "Delete account".localize()
            message = "Are you sure you want to delete your account?/nYou can’t undo this action.".localize()
            confirmButtonTitle = "Delete".localize()
            cancelButtonTitle = "Cancel".localize()
            confirmButtonMode = .delete
        }
        
        presentInfoAlert(on: viewController, title: title, message: message, image: image, confirmButtonTitle: confirmButtonTitle, cancelButtonTitle: cancelButtonTitle, confirmButtonMode: confirmButtonMode, delegate: delegate, confirmButtonCompletion: confirmButtonCompletion, cancelButtonCompletion: cancelButtonCompletion)
    }
    
    /**
     Presents app's custom alert with manual parameters
     */
    static func presentInfoAlert(on viewController: UIViewController,
                                 title: String? = nil,
                                 message: String? = nil,
                                 image: String? = nil,
                                 confirmButtonTitle: String? = nil,
                                 cancelButtonTitle: String? = nil,
                                 confirmButtonMode: ButtonMode? = nil,
                                 dismissOnTouch: Bool = false,
                                 delegate: AlertPresenterDelegate? = nil,
                                 confirmButtonCompletion: AlertActionCompletion = nil,
                                 cancelButtonCompletion: AlertActionCompletion = nil)
    {
        DispatchQueue.main.async {
            let infoAlertViewController = InfoAlertViewController()
            infoAlertViewController.delegate = delegate
            infoAlertViewController.dismissOnTouch = dismissOnTouch
            
            infoAlertViewController.alertTitle = title ?? ""
            infoAlertViewController.alertMessage = message ?? ""
            infoAlertViewController.alertImage = image ?? ""
            infoAlertViewController.confirmButtonTitle = confirmButtonTitle ?? "Ok"
            infoAlertViewController.cancelButtonTitle = cancelButtonTitle
            infoAlertViewController.modalPresentationStyle = .overFullScreen
            if confirmButtonCompletion != nil {
                infoAlertViewController.confirmButtonHandler = { data in
                    confirmButtonCompletion!(data)
                }
            }
            
            if cancelButtonCompletion != nil {
                infoAlertViewController.cancelButtonHandler = { data in
                    cancelButtonCompletion!(data)
                }
            }
            
            viewController.present(infoAlertViewController, animated: false) {
                if let confirmButtonMode = confirmButtonMode {
                    infoAlertViewController.confirmButtonMode = confirmButtonMode
                }
            }
        }
    }
    //MARK:- Code Verification Alert
    /**
     Presents app's custom alert to verify phone or email with code
     */
    static func presentVerificationAlert(on viewController: UIViewController,
                                         message: String = "",
                                         identificator: String = "", email: String = "",
                                         confirmButtonTitle: String = "Verify".localize())  -> VerificationAlertViewController
    {
        let verificationAlertViewController = VerificationAlertViewController()
        verificationAlertViewController.modalPresentationStyle = .overFullScreen
        verificationAlertViewController.dismissOnConfirmAction = false
        verificationAlertViewController.dismissOnTouch = false
        
        verificationAlertViewController.message = message
        verificationAlertViewController.email = email
        verificationAlertViewController.identificator = identificator
        verificationAlertViewController.confirmButtonTitle = confirmButtonTitle
        verificationAlertViewController.cancelButtonTitle = "Cancel".localize()
        
        viewController.present(verificationAlertViewController, animated: false, completion: nil)
        return verificationAlertViewController
    }
    
    static func presentItemCategoryAlert(on viewController: UIViewController, viewModel: CreateLookViewModel,
                                         selectCompletion: AlertActionCompletion = nil) {
        DispatchQueue.main.async {
            let itemCategorySelectViewController = ItemCategorySelectViewController()
            itemCategorySelectViewController.modalPresentationStyle = .overFullScreen
            itemCategorySelectViewController.viewModel = viewModel
            itemCategorySelectViewController.dismissOnTouch = true
            itemCategorySelectViewController.selectCompletion = selectCompletion
            viewController.present(itemCategorySelectViewController, animated: false, completion: nil)
        }
    }
    
    static func presentPictureAlert(on viewController: UIViewController, image: UIImage,
                                    selectCompletion: AlertActionCompletion = nil) {
        DispatchQueue.main.async {
            let imageAlertViewController = ImageAlertViewController()
            imageAlertViewController.modalPresentationStyle = .overFullScreen
            imageAlertViewController.dismissOnTouch = true
            imageAlertViewController.image = image
            viewController.present(imageAlertViewController, animated: false, completion: nil)
        }
    }
    
    static func presentTextFieldAlert(on viewController: UIViewController,
                                      defaultText: String? = nil,
                                      title: String? = nil,
                                      infoText: String? = nil,
                                      confirmButtonTitle: String? = nil,
                                      cancelButtonTitle: String? = nil,
                                      dismissOnTouch: Bool = false,
                                      delegate: AlertPresenterDelegate? = nil,
                                      confirmButtonCompletion: AlertActionCompletion = nil) -> TextFieldAlertViewController {
        let textFieldAlertViewController = TextFieldAlertViewController()
        textFieldAlertViewController.dismissOnConfirmAction = false
        textFieldAlertViewController.dismissOnTouch = false
        textFieldAlertViewController.delegate = delegate
        textFieldAlertViewController.defaultText = defaultText
        textFieldAlertViewController.alertTitle = title ?? ""
        textFieldAlertViewController.infoText = infoText ?? ""
        textFieldAlertViewController.confirmButtonTitle = confirmButtonTitle ?? "Ok"
        textFieldAlertViewController.cancelButtonTitle = cancelButtonTitle
        textFieldAlertViewController.modalPresentationStyle = .overFullScreen
        
        if confirmButtonCompletion != nil {
            textFieldAlertViewController.confirmButtonHandler = { data in
                confirmButtonCompletion!(data)
            }
        }
        
        viewController.present(textFieldAlertViewController, animated: false) {}
        return textFieldAlertViewController
    }
    
    static func presentAddItemToSetAlert(on viewController: UIViewController,
                                 image: UIImage? = nil,
                                 confirmButtonTitle: String? = nil,
                                 cancelButtonTitle: String? = nil,
                                 dismissOnTouch: Bool = false,
                                 delegate: AlertPresenterDelegate? = nil,
                                 confirmButtonCompletion: AlertActionCompletion = nil)
    {
        DispatchQueue.main.async {
            let infoAlertViewController = ItemAddInToSetAlertViewController()
            infoAlertViewController.delegate = delegate
            infoAlertViewController.dismissOnTouch = dismissOnTouch
            infoAlertViewController.image = image
            
            infoAlertViewController.confirmButtonTitle = confirmButtonTitle ?? "Ok"
            infoAlertViewController.cancelButtonTitle = cancelButtonTitle
            infoAlertViewController.modalPresentationStyle = .overFullScreen
            
            if confirmButtonCompletion != nil {
                infoAlertViewController.confirmButtonHandler = { data in
                    confirmButtonCompletion!(data)
                }
            }
            
            viewController.present(infoAlertViewController, animated: false) {}
        }
    }
    
    static func presentRequestErrorAlert(on viewController: UIViewController) {
        let alertController = UIAlertController(title: "Error".localize(), message: "Something wrong".localize(), preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "Ok".localize(), style: .default, handler: nil))
        DispatchQueue.main.async {
            viewController.present(alertController, animated: true)
        }
    }
    
    static func presentFeadbackAlert(on viewController: UIViewController, surveyViewModel: SurveysViewModel) -> FeadbackAlertViewController {
        let feadbackAlertViewController = FeadbackAlertViewController()
        feadbackAlertViewController.modalPresentationStyle = .overFullScreen
        feadbackAlertViewController.dismissOnConfirmAction = false
        feadbackAlertViewController.dismissOnTouch = false
        feadbackAlertViewController.surveyViewModel = surveyViewModel
    
        feadbackAlertViewController.confirmButtonTitle = "Submit".localize()
        feadbackAlertViewController.cancelButtonTitle = "Cancel".localize()
        viewController.present(feadbackAlertViewController, animated: false, completion: nil)
        return feadbackAlertViewController
    }
}

