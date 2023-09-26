//
//  BaseAlertViewController.swift
//
//  Created by Eduard on 11/20/19.
//

import UIKit

@objc protocol AlertPresenterDelegate: class {
    @objc optional func alertDidSelectConfirmButton()
    @objc optional func alertDidSelectCancelButton()
}

class BaseAlertViewController: UIViewController {
    //MARK:- Handlers
    public var confirmButtonHandler: ((Any?) -> Void)?
    public var cancelButtonHandler: ((Any?) -> Void)?

    //MARK:- Public propeties
    public var confirmButtonTitle: String?
    public var cancelButtonTitle: String?
    public var dismissOnTouch: Bool = false
    public var dismissOnConfirmAction: Bool = true
    public var enableConfirmButton: Bool = false {
        didSet {
            confirmButton.isEnabled = enableConfirmButton
            if enableConfirmButton {
                confirmButton.alpha = 1
            } else {
                confirmButton.alpha = 0.5
            }
        }
    }
    public var topInset: Int?
    public var bottomInset: Int?

    public var confirmButtonMode: ButtonMode = .background {
        didSet {
            confirmButton.setMode(confirmButtonMode, color: SCColors.whiteColor)
        }
    }
    
    public var alertTitle: String = "" {
        didSet {
            self.titleLabel.text = alertTitle
        }
    }

    public weak var delegate: AlertPresenterDelegate?
    
    public var contentView: UIView = UIView()
    public var popUpBackgroundColor: UIColor = SCColors.whiteColor {
        didSet {
            popUpView.backgroundColor = popUpBackgroundColor
        }
    }
    
    public var popupHeight: CGFloat {
        return popUpView.frame.height
    }

    //MARK:- Private propeties
    private var titleLabel: UILabel = UILabel()
    private var confirmButton: UIButton = UIButton()
    private var cancelButton: UIButton = UIButton()
    public var popUpView: UIView = UIView()
    public var isViewEditing: Bool = false

    //MARK:- Overided Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        createViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 3, options: .curveEaseInOut, animations: {
            self.popUpView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    //MARK:- Actions
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        if isViewEditing {
            self.view.endEditing(true)
            return
        }
        
        if (delegate?.alertDidSelectCancelButton?()) == nil && cancelButtonHandler == nil {
            dismissOnTouch = true
        }
        if dismissOnTouch {
            self.dismissViewController()
        }
    }
    
    @objc private func confirmButtonAction(_ sender: UIButton) {
        if dismissOnConfirmAction {
            self.dismissViewController()
        }
        self.delegate?.alertDidSelectConfirmButton?()
        if confirmButtonHandler != nil {
            confirmButtonHandler!(nil)
        }
    }
    
    @objc private func cancelButtonAction(_ sender: UIButton) {
        self.dismissViewController()
        self.delegate?.alertDidSelectCancelButton?()
        if cancelButtonHandler != nil {
            cancelButtonHandler!(nil)
        }
    }
    
    //MARK:- Private Functions
    private func configure() {
        self.modalPresentationStyle = .overFullScreen
        self.view.backgroundColor = SCColors.blackColor.withAlphaComponent(0.5)
        self.view.isOpaque = false
        self.view.autoresizesSubviews = false
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTapGesture(_:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func updateButtonsStyles() {
        confirmButton.setMode(.background, color: SCColors.whiteColor, backgroundColor: SCColors.mainColor)
        cancelButton.setMode(.standart, color: SCColors.titleColor)
    }
    
    private func createViews() {
        createPopUpView()
        createTitleLabel()
        createConfirmButton()
        createCancelButton()
        setupConstraints()
    }

    private func createPopUpView() {
        popUpView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        popUpView.backgroundColor = popUpBackgroundColor
        popUpView.roundCorners(radius: 20)
        self.view.addSubview(popUpView)
        
        contentView.backgroundColor = .clear
        contentView.autoresizesSubviews = false
        popUpView.addSubview(contentView)
    }
    
    private func createTitleLabel() {
        titleLabel.text = alertTitle.localize()
        titleLabel.textColor = SCColors.titleColor
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        self.popUpView.addSubview(titleLabel)
    }

    private func createConfirmButton() {
        if let confirmTitle = confirmButtonTitle, !confirmTitle.isEmpty {
            confirmButton.setTitle(confirmTitle.localize(), for: .normal)
            confirmButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            confirmButton.addTarget(self, action: #selector(confirmButtonAction(_:)), for: .touchUpInside)
        } else {
            confirmButtonTitle = ""
            confirmButton.isHidden = true
        }
        popUpView.addSubview(confirmButton)
    }
    
    private func createCancelButton() {
        if let cancelTitle = cancelButtonTitle, !cancelTitle.isEmpty {
            cancelButton.setTitle(cancelTitle.localize(), for: .normal)
            cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            cancelButton.addTarget(self, action: #selector(cancelButtonAction(_:)), for: .touchUpInside)
        } else {
            cancelButtonTitle = ""
            cancelButton.isHidden = true
        }
        popUpView.addSubview(cancelButton)
    }

    private func setupConstraints() {
        popUpView.translatesAutoresizingMaskIntoConstraints = false
        for subview in popUpView.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        popUpView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
        popUpView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16).isActive = true
        popUpView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

        let metrics = ["confirmButtonHeight" : confirmButtonTitle!.isEmpty ? 0 : 50,
                       "cancelButtonHeight" : cancelButtonTitle!.isEmpty ? 0 : 50,
                       "margin" : 22,
                       "topInset" : topInset ?? 35,
                       "buttonInset" : bottomInset ?? 20,
                       "inset" : 20]
        let views = ["confirmButton" : confirmButton, "cancelButton" : cancelButton, "contentView" : contentView, "titleLabel" : titleLabel]
        
        popUpView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(inset)-[titleLabel]-(inset)-|", options: [], metrics: metrics, views: views))
        popUpView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[contentView]-(0)-|", options: [], metrics: metrics, views: views))
        popUpView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(margin)-[confirmButton]-(margin)-|", options: [], metrics: metrics, views: views))
        popUpView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(margin)-[cancelButton]-(margin)-|", options: [], metrics: metrics, views: views))

        popUpView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(topInset)-[titleLabel]-(inset)-[contentView]-(inset)-[confirmButton(==confirmButtonHeight)]-(0)-[cancelButton(==cancelButtonHeight)]-(buttonInset)-|", options: [], metrics: metrics, views: views))
        
        updateButtonsStyles()
    }
    
    func dismissViewController() {
        self.dismiss(animated: false) {}
    }
    
    @objc func keyboardWillShow(notification:Notification) {
        isViewEditing = true
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if Int(self.popUpView.frame.maxY) <= Int(UIScreen.main.bounds.height - keyboardHeight) {
                return
            }
            UIView.animate(withDuration: 1.5) {
                self.popUpView.transform = CGAffineTransform(translationX: 0, y: self.popUpView.frame.minY - keyboardHeight)
            }
        }
    }
    
    
    @objc func keyboardWillHide(notification:Notification) {
        isViewEditing = false
        UIView.animate(withDuration: 1.5) {
            self.popUpView.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
}

//MARK:- UIGestureRecognizerDelegate
extension BaseAlertViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if popUpView.frame.contains(touch.location(in: self.view)) {
            return false
        }
        return true
    }
}

