//
//  LoadingIndicator.swift
//  Menu
//
//  Created by Eduard Minasyan on 9/27/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

enum LoadingType {
    case indicator
    case gif
}


class LoadingIndicator: UIView {
    //MARK:- Constants
    private var defaultHeight: CGFloat = 90.0
    
    //MARK:- Properties
    private var activityIndicator: UIActivityIndicatorView?
    private var type : LoadingType = .indicator
    //MARK:- Overided Functions
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.commonInit()
    }

    //MARK:- Public Function
    @discardableResult
    static func show(on view: UIView, animated: Bool = true, type : LoadingType = .indicator) -> LoadingIndicator {
        let loadingIndicator = LoadingIndicator()
        loadingIndicator.type = type
        if type == .indicator {
            loadingIndicator.defaultHeight = 60
        }
        loadingIndicator.commonInit()
        loadingIndicator.add(to: view, animated: animated)
        loadingIndicator.startAnimating()
        return loadingIndicator
    }
    
    static func hide(from view: UIView, animated: Bool = true) {
        LoadingIndicator.loadingIndicators(on: view)?.first?.removeFromSuperview(animated: animated)
    }

    static func loadingIndicators(on view: UIView) -> [LoadingIndicator]? {
        return view.subviews.filter({$0.isKind(of: LoadingIndicator.self)}) as? [LoadingIndicator]
    }
    
    static func refreshAnimating(view: UIView){
        LoadingIndicator.loadingIndicators(on: view)?.first?.startAnimating()
    }
    
    
    func startAnimating() {
        
        switch type {
        case .gif:
            // implement gif if needed
            print("gif")
        case .indicator:
            self.activityIndicator?.startAnimating()
        }
    }
    
    func stopAnimating() {
        switch type {
        case .gif:
            print("gif")
        case .indicator:
            self.activityIndicator?.stopAnimating()
        }
    }
    
   
    
    //MARK:- Private Functions
    private func commonInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(applWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

        switch type {
        case .gif:
            print("gif")
        case .indicator:
            let cornerRadius = self.defaultHeight / 2
            self.layer.cornerRadius = cornerRadius
            if #available(iOS 13.0, *) {
                self.activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
            } else {
                // Fallback on earlier versions
            }
            self.addSubview(self.activityIndicator!)
            
        }
        
    }
    
    private func add(to view: UIView, animated: Bool) {
        LoadingIndicator.hide(from: view, animated: false)
        view.addSubview(self)
        view.bringSubviewToFront(view)
        self.addConstraints()
        
        if animated {
            self.performAnimation(show: true)
        }
    }
    
    private func removeFromSuperview(animated: Bool) {
        DispatchQueue.main.async {
            if animated {
                self.performAnimation(show: false)
            }

            self.stopAnimating()
            self.removeFromSuperview()
        }
    }
    
    private func performAnimation(show: Bool) {
        let alpha = show ? 1 : 0 as CGFloat
        self.alpha = show ? 0 : 1
        UIView.animate(withDuration: 0.3) {
            self.alpha = alpha
        }
    }
    
    @objc private func applWillEnterForeground() {
        if let superview = self.superview {
            LoadingIndicator.refreshAnimating(view: superview)
        }
    }
    
    private func addConstraints() {
        if let view = self.superview {
            var loadingView : UIView
            switch type {
            case .gif:
                print("gif")
                loadingView = UIView()
            //    loadingView = self.animationView
            case .indicator:
                loadingView = self.activityIndicator!
            }
            self.translatesAutoresizingMaskIntoConstraints = false
            self.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            self.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            self.heightAnchor.constraint(equalToConstant: defaultHeight).isActive = true
            self.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1).isActive = true
            
            loadingView.translatesAutoresizingMaskIntoConstraints = false
            loadingView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            loadingView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            loadingView.heightAnchor.constraint(equalToConstant: defaultHeight).isActive = true
            loadingView.widthAnchor.constraint(equalTo: loadingView.heightAnchor, multiplier: 1).isActive = true
        }
    }
}
