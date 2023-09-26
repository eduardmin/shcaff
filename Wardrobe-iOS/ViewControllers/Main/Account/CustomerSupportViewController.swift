//
//  CustomerSupportViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/13/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit
import MessageUI

class CustomerSupportViewController: BaseNavigationViewController {
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: LoginTextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextField: LoginTextField!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var confirmButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func didSelectNavigationAction(action: NavigationAction) {
        switch action {
        case .back:
            navigationController?.popViewController(animated: true)
        default:
            break
        }
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        let mailComposeViewController = configureMailComposer()
        if MFMailComposeViewController.canSendMail() {
            present(mailComposeViewController, animated: true, completion: nil)
        }else{
            let mailAddress = UserDefaults.standard.object(forKey: UserDefaultsKey.email) ?? ""
            let message = "Please configure your phone to send mail.".localize()
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Settings".localized(), style: .default) { (_) -> Void in
                let url = URL(string: "mailto:\(mailAddress)")!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            })
            alertController.addAction(UIAlertAction(title: "OK".localized(), style: .cancel))
            alertController.popoverPresentationController?.sourceView = navigationController?.view
            alertController.popoverPresentationController?.sourceRect = CGRect(x: navigationController!.view.bounds.midX, y: navigationController!.view.bounds.midY, width: 0, height: 0)
            alertController.popoverPresentationController?.permittedArrowDirections = []
            navigationController?.present(alertController, animated: true)
        }
    }
    
    //MARK:- UI
    func configureUI() {
        setNavigationView(type: .defaultWithBack, title: "Customer Support".localize(), additionalTopMargin: 16)
        hideKeyboardWhenTappedAround()
        emailTextField.delegate = self
        emailLabel.text = "Your Email".localize()
        titleTextField.delegate = self
        titleLabel.text = "Title".localize()
        messageLabel.text = "Message".localize()
        emailTextField.leftMargin = 20
        titleTextField.leftMargin = 20
        messageTextView.textColor = SCColors.titleColor
        messageTextView.layer.cornerRadius = 30
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.borderColor = SCColors.textfieldBorderColor.cgColor
        messageTextView.textContainerInset = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
        messageTextView.delegate = self
        confirmButton.setMode(.background, color: SCColors.whiteColor)
        confirmButton.setTitle("Send".localize(), for: .normal)
    }
    
    private func configureMailComposer() -> MFMailComposeViewController{
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setCcRecipients([emailTextField.text ?? ""])
        mailComposeVC.setToRecipients([Paths.supportMail])
        mailComposeVC.setSubject(titleTextField.text ?? "")
        mailComposeVC.setMessageBody(messageTextView.text ?? "", isHTML: false)
        return mailComposeVC
    }
}

//MARK:- UITextFieldDelegate & UITextViewDelegate
extension CustomerSupportViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = nil
        messageTextView.textColor = SCColors.titleColor
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
}

//MARK:- MFMailComposeViewControllerDelegate
extension CustomerSupportViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
