//
//  PlusView.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/24/20.
//

import UIKit

@objc protocol PlusViewDelegate: class {
    @objc optional func takePhotoAction()
    @objc optional func basicAction()
    @objc optional func plusAction()
}

class PlusView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var takePhotoLabel: UILabel!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var basicLabel: UILabel!
    @IBOutlet weak var basicButton: UIButton!
    private var isTransform: Bool = false
    weak var delegate: PlusViewDelegate?
    var stateIsChange: Bool = false
    
    convenience init(_ stateIsChange: Bool = true) {
        self.init()
        self.stateIsChange = stateIsChange
        commonInit()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !isTransform {
            if plusButton.frame.contains(point) {
                return super.hitTest(point, with: event)
            }
        } else {
            return super.hitTest(point, with: event)
        }
        
        return nil
    }
}

//MARK:- Button Action
extension PlusView {
    @IBAction func plusAction(_ sender: Any) {
        if stateIsChange {
            changeState()
            EventLogger.logEvent("Wardrobe plus action")
        } else {
            delegate?.plusAction?()
        }
    }
    
    @IBAction func takePhotoAction(_ sender: Any) {
        delegate?.takePhotoAction?()
        EventLogger.logEvent("Wardrobe take photo action")
    }
    
    @IBAction func basicAction(_ sender: Any) {
        delegate?.basicAction?()
        EventLogger.logEvent("Wardrobe basic action")
    }
    
    @objc func gesture() {
        changeState()
    }
    
    func changeState() {
        isTransform = !isTransform
        if isTransform {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                self.plusButton.backgroundColor = SCColors.whiteColor
                self.plusButton.setImage(UIImage(named: "transformPlus"), for: .normal)
                self.backgroundView.isHidden = false
                self.backgroundView.backgroundColor = SCColors.titleColor.withAlphaComponent(0.7)
                self.hideButtons()
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.plusButton.backgroundColor = SCColors.mainColor
                self.plusButton.setImage(UIImage(named: "plus"), for: .normal)
                self.backgroundView.backgroundColor = UIColor.clear
                self.hideButtons()
            }, completion: nil)
        }
    }
}

//MARK:- Private functions
extension PlusView {
    
    private func commonInit() {
        Bundle.main.loadNibNamed("PlusView", owner: self, options: nil)
        addSubview(contentView)
        contentView.addConstraintsToSuperView()
        configureUI()
    }
    
    private func configureUI() {
        plusButton.layer.cornerRadius = plusButton.bounds.width / 2
        takePhotoButton.layer.cornerRadius = takePhotoButton.bounds.width / 2
        basicButton.layer.cornerRadius = basicButton.bounds.width / 2
        takePhotoLabel.text = "Take a picture".localize()
        basicLabel.text = "Add basics".localize()
        plusButton.addShadow(true, 3, 6)
        takePhotoButton.addShadow(true, 3, 6)
        basicButton.addShadow(true, 3, 6)
        hideButtons()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gesture)))
    }
    
    private func hideButtons() {
        if isTransform {
            takePhotoButton.isHidden = false
            basicButton.isHidden = false
            takePhotoLabel.isHidden = false
            basicLabel.isHidden = false
        } else {
            takePhotoButton.isHidden = true
            basicButton.isHidden = true
            takePhotoLabel.isHidden = true
            basicLabel.isHidden = true
        }
    }
}
