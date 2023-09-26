//
//  UIButtonExtension.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 6/6/20.
//

import Foundation
import UIKit

enum ButtonMode {
    /**Gradient button with colors*/
    case gradient
    /**Bordered button with borders*/
    case passive
    /**Standart button with title*/
    case standart
    /**Standart button with background color*/
    case background
    /**Standart button with background color*/
    case delete
}

enum SaveButtonMode {
    /**normal button*/
    case normal
    /**Gradient button with colors*/
    case active
    /**passive button with colors*/
    case passive
}

extension UIButton {
    
    func setMode(_ mode: ButtonMode, color: UIColor = SCColors.mainColor, backgroundColor: UIColor = SCColors.mainColor, cornerRadius: CGFloat? = nil, shadow: Bool = true){
        layoutIfNeeded()
        if let cornerRadius = cornerRadius {
            layer.cornerRadius = cornerRadius
        } else {
            layer.cornerRadius = frame.height / 2
        }
        removeSubLayers()
        switch mode {
        case .gradient:
            drawGradient(cornerRadius: cornerRadius)
            setTitleColor(SCColors.whiteColor, for: .normal)
        case .passive:
            layer.borderColor = color.cgColor
            layer.borderWidth = 1
            setTitleColor(color, for: .normal)
            
        case .standart:
            setTitleColor(color, for: .normal)
        case .background:
            self.backgroundColor = backgroundColor
            setTitleColor(color, for: .normal)
            if shadow {
                addShadow(true, 3, 6)
            }
        case .delete:
            setTitleColor(SCColors.whiteColor, for: .normal)
            self.backgroundColor = SCColors.deleteColor
        }
    }
    
    func setSaveButtonMode(_ mode: SaveButtonMode, widthConstraint: NSLayoutConstraint) {
        removeSubLayers()
        switch mode {
        case .normal:
            setTitleColor(SCColors.mainColor, for: .normal)
            backgroundColor = .clear
            isEnabled = true
        case .active:
            widthConstraint.constant = 100
            layoutIfNeeded()
            layer.cornerRadius = frame.height / 2
            setMode(.background, color: SCColors.whiteColor, shadow: false)
            isEnabled = true
        case .passive:
            widthConstraint.constant = 100
            layoutIfNeeded()
            layer.cornerRadius = frame.height / 2
            isEnabled = false
            setMode(.background, color: SCColors.mainGrayColor, backgroundColor: SCColors.itemTypeColor, shadow: false)
        }
    }
    
    private func drawGradient(cornerRadius: CGFloat? = nil) {
        var cornRadius: CGFloat = 0
        if let cornerRadius = cornerRadius {
            cornRadius = cornerRadius
        } else {
            cornRadius = bounds.height / 2
        }
        let gradientLayer = gradientLayerWithOrientation(.vertical, size: bounds, cornerRadius: cornRadius)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func enableButton(enable: Bool) {
        isEnabled = enable
        alpha = isEnabled ? 1 : 0.5
    }
    
    private func removeSubLayers() {
        for layer in layer.sublayers ?? [CALayer()]  {
            if layer.isKind(of: CAGradientLayer.self) {
                layer.removeFromSuperlayer()
            }
        }
    }
    
}
