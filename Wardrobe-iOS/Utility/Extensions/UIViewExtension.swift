//
//  UIViewExtension.swift
//  Wardrobe-iOS
//
//  Created by Mariam Khachatryan on 3/28/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func addConstraintsToSuperView(insets: UIEdgeInsets = .zero) {
        let metrics = ["top" : insets.top, "bottom" : insets.bottom, "left" : insets.left, "right" : insets.right]
        let views = ["view" : self]
        
        translatesAutoresizingMaskIntoConstraints = false
        superview?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-left-[view]-right-|", options: [], metrics: metrics, views: views))
        superview?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-top-[view]-bottom-|", options: [], metrics: metrics, views: views))
    }
    
    func screenShotImage() -> UIImage {
        UIGraphicsBeginImageContext(frame.size)
        self.drawHierarchy(in: bounds, afterScreenUpdates: true)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func addShadow(_ bottom: Bool = true, _ y: CGFloat = 8, _ blur: CGFloat = 10) {
        if bottom {
            layer.applyShadow(y: y, blur: blur)
        } else {
            layer.applyShadow(y: -y, blur: blur)
        }
    }
    
    func circleView() {
        roundCorners(radius: bounds.height / 2)
    }
    
    func roundCorners(radius: CGFloat = 10) {
        layer.cornerRadius = radius
    }

    //MARK:- Constraints
    func fixInView(_ container: UIView!, _ edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: edgeInsets.left).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: -edgeInsets.right).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: edgeInsets.top).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: -edgeInsets.bottom).isActive = true
    }
    
}

extension CGRect {
    func with(inset: CGFloat) -> CGRect {
        return CGRect(x: inset, y: inset, width: size.width - 2 * inset, height: size.height - 2 * inset)
    }
}

//MARK:- Gradient
extension UIView {
    func gradient(orientation: GradientOrientation, frame: CGRect, cornerRadius: CGFloat = 20, colors: [CGColor] = [SCColors.mainColor.cgColor, SCColors.secondaryColor.cgColor] ) {
        for layer in self.layer.sublayers ?? [CALayer()]  {
            if layer.isKind(of: CAGradientLayer.self) {
                layer.removeFromSuperlayer()
            }
        }
        
        let gradientLayer = CAGradientLayer()
        let startPoint: CGPoint
        let endPoint: CGPoint
        
        if orientation == .horizontal {
            startPoint = CGPoint(x: 0.0, y: 0.5)
            endPoint = CGPoint(x: 1.0, y: 0.5)
        } else  {
            startPoint = CGPoint(x: 0.5, y: 0.0)
            endPoint = CGPoint(x: 0.5, y: 1.0)
        }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        gradientLayer.frame = frame
        
        gradientLayer.colors = colors
        gradientLayer.cornerRadius = cornerRadius
        self.layer.insertSublayer(gradientLayer, at: 1)
    }
    
    func removeGradientt() {
        for layer in self.layer.sublayers ?? [CALayer()]  {
            if layer.isKind(of: CAGradientLayer.self) {
                layer.removeFromSuperlayer()
            }
        }
    }
}

//MARK:- Gradient Layer
func gradientLayerWithOrientation(_ orientation: GradientOrientation, size: CGRect, cornerRadius: CGFloat) -> CAGradientLayer{
    let gradientLayer = CAGradientLayer()
    let startPoint: CGPoint
    let endPoint: CGPoint
    
    if orientation == .horizontal {
        startPoint = CGPoint(x: 0.0, y: 0.5)
        endPoint = CGPoint(x: 1.0, y: 0.5)
    } else {
        startPoint = CGPoint(x: 0.5, y: 0.0)
        endPoint = CGPoint(x: 0.5, y: 1.0)
    }
    gradientLayer.startPoint = startPoint
    gradientLayer.endPoint = endPoint
    
    gradientLayer.frame = size
    
    gradientLayer.colors = [SCColors.mainColor.cgColor, SCColors.secondaryColor.cgColor]
    gradientLayer.cornerRadius = cornerRadius
    
    return gradientLayer
}

extension CALayer {
    func applyShadow(
        color: UIColor = .black,
        alpha: Float = 0.1,
        x: CGFloat = 0,
        y: CGFloat = 8,
        blur: CGFloat = 10,
        spread: CGFloat = 0) {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
    
    var sliding: CAAnimation {
        let startPointAnim = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.startPoint))
        startPointAnim.fromValue = CGPoint(x: -1, y: 0.5)
        startPointAnim.toValue = CGPoint(x: 1, y: 0.5)
        
        let endPointAnim = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.endPoint))
        endPointAnim.fromValue = CGPoint(x: 0, y: 0.5)
        endPointAnim.toValue = CGPoint(x: 2, y: 0.5)
        
        let animGroup = CAAnimationGroup()
        animGroup.animations = [startPointAnim, endPointAnim]
        animGroup.duration = 1.5
        animGroup.timingFunction = CAMediaTimingFunction(name: .easeIn)
        animGroup.repeatCount = .infinity
        
        return animGroup
    }
}

