//
//  CopyLabel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 6/6/21.
//  Copyright © 2021 Schaff. All rights reserved.
//

import Foundation
import UIKit

class CopyableLabel: UILabel {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isUserInteractionEnabled = true
        addGestureRecognizer(
            UILongPressGestureRecognizer(
                target: self,
                action: #selector(handleLongPress(_:))
            )
        )
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }
    
    // MARK: - UIResponderStandardEditActions
    
    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
    }
    
    // MARK: - Long-press Handler
    
    @objc func handleLongPress(_ recognizer: UIGestureRecognizer) {
        if recognizer.state == .began,
           let recognizerView = recognizer.view,
           let recognizerSuperview = recognizerView.superview {
            recognizerView.becomeFirstResponder()
            UIMenuController.shared.setTargetRect(recognizerView.frame, in: recognizerSuperview)
            UIMenuController.shared.setMenuVisible(true, animated:true)
        }
    }
}

class SCLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    deinit {
        print("")
    }
}
