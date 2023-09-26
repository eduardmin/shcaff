//
//  DraggableContainerView.swift
//  Wardrobe-iOS
//
//  Created by Eduard on 6/9/20.
//  Copyright © 2020 Eduard. All rights reserved.
//

import UIKit

protocol DraggableContainerViewDelegate: class {
    func scrollMinPostion()
    func scrollinitialPostion()
}

class DraggableContainerView: UIView {
    
    weak var delegate: DraggableContainerViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    var maximumY: CGFloat! = 200
    var minimumY: CGFloat! = -450
    var initialY: CGFloat! = 10
    var topConstraint: NSLayoutConstraint!

    private func commonInit() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(viewWasDragged(sender:)))
        addGestureRecognizer(gesture)
        clipsToBounds = true
        layer.cornerRadius = 30
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.borderColor = UIColor.gray.withAlphaComponent(0.1).cgColor
        layer.borderWidth = 3
    }
    
    @objc func viewWasDragged(sender: UIPanGestureRecognizer) {
        guard let superview = superview else { return }
      
        if sender.state == .began {
            sender.setTranslation(CGPoint(x: 0, y: topConstraint.constant), in: superview)
        }
        else if sender.state == .changed {
            if frame.minY > minimumY && frame.minY < maximumY {
                let y = sender.translation(in: superview).y
                scrollToY(position: y, animated: false)
            }
        }
        else if sender.state == .ended {
            let velocity = sender.velocity(in: self.superview)
            if velocity.y > 0  {
                scrollToInitialYPosition(animated: true)
            } else {
                scrollToMinimumYPosition(animated: true)
            }
        }
    }
    
    func scrollToInitialYPosition(animated: Bool = false) {
        scrollToY(position: initialY, animated: animated)
        delegate?.scrollinitialPostion()
    }
    
    func scrollToMaximumYPosition(animated: Bool = false) {
        scrollToY(position: maximumY, animated: animated)
    }
    
    func scrollToMinimumYPosition(animated: Bool = false) {
        scrollToY(position: minimumY, animated: animated)
        delegate?.scrollMinPostion()
    }

    
    func scrollToY(position: CGFloat, animated: Bool) {
        guard let superview = superview else { return }

        if animated {
            UIView.animate(withDuration: 0.5) {
                self.topConstraint.constant = position
                superview.layoutIfNeeded()
            }
        }
        else {
            self.topConstraint.constant = position
        }
    }
}
