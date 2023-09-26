//
//  InfoAlertViewController.swift
//
//  Created by Eduard Minasyan on 11/20/19.
//

import UIKit

class InfoAlertViewController: BaseAlertViewController {

    //MARK:- Public properties
    public var alertMessage: String = ""
    public var alertImage: String = ""

    //MARK:- Private properties
    private var messageLabel: UILabel = UILabel()
    private var imageView: UIImageView = UIImageView()

    //MARK:- Overided functions
    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
    }

    //MARK:- Private functions
    private func createViews() {
        confirmButtonMode = .background
        createMessageLabel()
        createImageView()
        setupConstraints()
    }
        
    private func createMessageLabel() {
        messageLabel.text = alertMessage.localize()
        messageLabel.textColor = SCColors.titleColor
        messageLabel.font = UIFont.systemFont(ofSize: 13)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        self.contentView.addSubview(messageLabel)
    }
    
    private func createImageView() {
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: alertImage)
        self.contentView.addSubview(imageView)
    }
    
    private func setupConstraints() {
        for subview in self.contentView.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let views = ["messageLabel" : messageLabel, "imageView" : imageView]
        let metrics = ["inset" : 50]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(inset)-[messageLabel]-(inset)-|", options: [], metrics: metrics, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[imageView]-(0)-|", options: [], metrics: metrics, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[messageLabel]-(inset)-[imageView]-(0)-|", options: [], metrics: metrics, views: views))
    }
}
