//
//  FeadbackAlertViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 1/29/22.
//  Copyright © 2022 Schaff. All rights reserved.
//

import UIKit

class FeadbackAlertViewController: BaseAlertViewController, FeadbackViewDelegate {
   
    //MARK:- Private properties
    private var feadbackView: FeadbackView = FeadbackView()
    public var surveyViewModel: SurveysViewModel?
    var expend: Bool = false
    public var confirmSuccessHandler: (() -> ())?

    //MARK:- Overided functions
    override func viewDidLoad() {
        topInset = 0
        super.viewDidLoad()
        createViews()
        enableConfirmButton = false
        hideKeyboardWhenTappedAround()
        confirmButtonHandler = { [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.start(showLoading: true)
            strongSelf.surveyViewModel?.saveSurvey()
        }
    }
    
    override func keyboardWillShow(notification: Notification) {
        isViewEditing = true
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if Int(self.popUpView.frame.maxY) <= Int(UIScreen.main.bounds.height - keyboardHeight) {
                return
            }
            UIView.animate(withDuration: 1.5) {
                self.popUpView.transform = CGAffineTransform(translationX: 0, y: -40)
            }
        }
    }
    
    //MARK:- Private functions
    private func createViews() {
        createFeadbackView()
        setupConstraints()
    }
    
    private func createFeadbackView() {
        if let surveyViewModel = surveyViewModel {
            feadbackView.surveyViewModel = surveyViewModel
        }
        feadbackView.configure()
        feadbackView.delegate = self
        feadbackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(feadbackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.deactivate(contentView.constraints)
        var expendedHeight = 505
        if UIScreen.main.bounds.height - popupHeight < 150 {
            expendedHeight = 400
        }
        let height = expend ? expendedHeight : 400
        let metrics = ["height" : height]
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[feadbackView]|", options: [], metrics: nil, views: ["feadbackView": feadbackView]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[feadbackView(==height)]|", options: [], metrics: metrics, views: ["feadbackView": feadbackView]))
    }
    
    func expendFeadbackView(expend: Bool) {
        self.expend = expend
        setupConstraints()
    }
    
    func enableSubmitButton(enable: Bool) {
        enableConfirmButton = enable
    }
    
    func submitSuccess() {
        hideLoading()
        confirmSuccessHandler?()
        dismissViewController()
    }
    
    func submitFailed() {
        hideLoading()
        AlertPresenter.presentRequestErrorAlert(on: self)
    }
    
    func start(showLoading: Bool) {
        LoadingIndicator.show(on: view)
    }
    
    func hideLoading() {
        LoadingIndicator.hide(from: view)
    }
}
