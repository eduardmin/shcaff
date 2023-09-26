//
//  PannableViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 3/8/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import Foundation
import UIKit

class PannableViewController: UIViewController, UIGestureRecognizerDelegate {
    public var minimumVelocityToHide: CGFloat = 1500
    public var minimumScreenRatioToHide: CGFloat = 0.5
    public var animationDuration: TimeInterval = 0.2
    private var allowContinue = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Listen for pan gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        panGesture.delegate = self
        if #available(iOS 13.4, *) {
            panGesture.allowedScrollTypesMask = .discrete
        } else {
            // Fallback on earlier versions
        }
        view.addGestureRecognizer(panGesture)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func onPan(_ panGesture: UIPanGestureRecognizer) {
        
        func slideViewVerticallyTo(_ y: CGFloat) {
            self.view.alpha = 40 / y
            self.view.frame.origin = CGPoint(x: 0, y: y)
        }
        
        if panGesture.state == .began {
            if getCollectionViewOffset() > 0 {
                allowContinue = false
            } else {
                allowContinue = true
            }
        }
        
        if !allowContinue {
            return
        }
        switch panGesture.state {
        
        case .began, .changed:
            // If pan started or is ongoing then
            // slide the view to follow the finger
            let translation = panGesture.translation(in: view)
            let y = max(0, translation.y)
            slideViewVerticallyTo(y)
        case .ended:
            // If pan ended, decide it we should close or reset the view
            // based on the final position and the speed of the gesture
            let translation = panGesture.translation(in: view)
            let velocity = panGesture.velocity(in: view)
            let closing = (translation.y > self.view.frame.size.height * minimumScreenRatioToHide) ||
                (velocity.y > minimumVelocityToHide)
            if closing {
                UIView.animate(withDuration: animationDuration, animations: {
                    // If closing, animate to the bottom of the view
                    slideViewVerticallyTo(self.view.frame.size.height)
                }, completion: { (isCompleted) in
                    if isCompleted {
                        // Dismiss the view when it dissapeared
                        self.dismiss(animated: false, completion: nil)
                    }
                })
            } else {
                // If not closing, reset the view to the top
                UIView.animate(withDuration: animationDuration, animations: {
                    slideViewVerticallyTo(0)
                })
            }
        default:
            // If gesture state is undefined, reset the view to the top
            UIView.animate(withDuration: animationDuration, animations: {
                slideViewVerticallyTo(0)
            })
            
        }
    }
    
    public func getCollectionViewOffset() -> Int {
        return 0
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .coverVertical
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .coverVertical
    }
}
