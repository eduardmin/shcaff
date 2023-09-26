//
//  NavigationView.swift
//  Wardrobe-iOS
//
//  Created by Mariam on 5/1/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit

protocol NavigationViewDelegate: class {
    func navigationViewDidSelectAction(action: NavigationAction)
}

enum NavigationType {
    case defaultType
    case defaultWithBack
    case defaultWithCancel
    case defaultWithAvatar
    case defaultWithWeather
    case defaultWithWeatherBack
    case defaultWithWeatherCancel
    case defaultWithEdit
    case filterType
    case clearType
    case editType
    case account
    case notification
}

enum NavigationAction: Int {
    case back
    case avatar
    case today
    case edit
    case filter
    case clear
    case notification
}

class NavigationView: UIView {
    //MARK:- Outlets
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var avatarImageView: AvatarImageView!
    @IBOutlet weak private var weatherLabel: UILabel!
    @IBOutlet weak private var backButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak private var backWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak private var backLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak private var titleLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var rigthButton: UIButton!
    @IBOutlet weak private var seperatorView: UIView!
    @IBOutlet weak var rigthButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarHeight: NSLayoutConstraint!
    @IBOutlet weak var rigthButtonTrailing: NSLayoutConstraint!
    private var type: NavigationType = .defaultType
    
    //MARK:- Properties
    private var title: String = ""
    
    //MARK:- Public properties
    weak var delegate: NavigationViewDelegate? = nil
    
    //MARK:- Public functions
    convenience init(type: NavigationType = .defaultType, title: String? = nil, attibuteTitle: NSAttributedString? = nil, _ rigthButtonTitle: String? = nil) {
        self.init()
        commonInit()
        configureView(type, title: title, attibuteTitle: attibuteTitle, rigthButtonTitle)
    }
    
    func setTitle(_ title: String? = nil, _ attibuteTitle: NSAttributedString? = nil) {
        if let attibuteTitle = attibuteTitle {
            self.titleLabel.attributedText = attibuteTitle
        } else {
            self.title = title ?? ""
            self.titleLabel.text = title ?? ""
        }
    }
    
    func setWeatherText(_ text: NSAttributedString) {
        if type == .defaultWithAvatar {
            descriptionLabel.attributedText = text
        } else {
            weatherLabel.attributedText = text
        }
    }
    
    func setRightButtonMode(_ mode: SaveButtonMode) {
        switch mode {
        case .active:
            rigthButton.setSaveButtonMode(.active, widthConstraint: rigthButtonWidthConstraint)
        case .normal:
            rigthButton.setSaveButtonMode(.normal, widthConstraint: rigthButtonWidthConstraint)
        case .passive:
            rigthButton.setSaveButtonMode(.passive, widthConstraint: rigthButtonWidthConstraint)
        }
    }
    
    func setAvatarImage(_ image: UIImage?) {
        avatarHeight.constant = image != nil ? 40 : 24
        layoutIfNeeded()
        avatarImageView.updateImage(image)
        if type == .defaultWithAvatar {
            rigthButtonTrailing.constant = avatarHeight.constant + 54
        }
    }
    
    func setBadge(badge: Bool) {
        rigthButton.setImage(UIImage(named: badge ? "badgeNotification" : "notification")?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
}

//MARK:- Private functions
extension NavigationView {
    
    private func commonInit() {
        Bundle.main.loadNibNamed("NavigationView", owner: self, options: nil)
        addSubview(contentView)
        contentView.addConstraintsToSuperView()
    }
}

//MARK:- Configurations
extension NavigationView {
    
    private func configureView(_ type: NavigationType, title: String? = nil, attibuteTitle: NSAttributedString? = nil, _ rigthButtonTitle: String? = nil) {
        self.type = type
        setTitle(title, attibuteTitle)
        
        switch type {
        case .defaultType:
            backWidthConstraint.constant = 0
            backLeadingConstraint.constant = 16
        case .defaultWithBack:
            rigthButton.isHidden = true
            seperatorView.isHidden = false
            backButton.isHidden = false
            titleLabelBottomConstraint.constant = 20
        case .defaultWithAvatar:
            avatarImageView.isHidden = false
            avatarImageView.delegate = self
            backWidthConstraint.constant = 0
            backLeadingConstraint.constant = 16
            titleLabel.isHidden = true
            rigthButton.isHidden = false
            descriptionLabel.isHidden = false
            rigthButton.setImage(UIImage(named: "notification"), for: .normal)
            rigthButtonTrailing.constant = avatarHeight.constant + 30
        case .defaultWithCancel:
            backButton.isHidden = false
            backButton.setImage(UIImage(named: "cancelVC"), for: .normal)
        case .defaultWithWeather:
            weatherLabel.isHidden = false
            backWidthConstraint.constant = 0
            backLeadingConstraint.constant = 16
        case .defaultWithWeatherBack:
            weatherLabel.isHidden = false
            backButton.isHidden = false
            backButton.setImage(UIImage(named: "cancelVC"), for: .normal)
        case .defaultWithWeatherCancel:
            weatherLabel.isHidden = false
            backButton.isHidden = false
            backButton.setImage(UIImage(named: "cancelVC"), for: .normal)
        case .defaultWithEdit:
            rigthButton.isHidden = false
            rigthButton.setTitle("Edit".localize(), for: .normal)
            backWidthConstraint.constant = 0
            backLeadingConstraint.constant = 16
        case .clearType:
            rigthButton.isHidden = false
            seperatorView.isHidden = false
            backButton.isHidden = false
            rigthButton.setTitle("Clear".localize(), for: .normal)
            titleLabelBottomConstraint.constant = 20
        case .filterType:
            rigthButton.isHidden = false
            seperatorView.isHidden = false
            backButton.isHidden = false
            rigthButton.setImage(UIImage(named: "options"), for: .normal)
            titleLabelBottomConstraint.constant = 20
        case .editType:
            rigthButton.isHidden = false
            seperatorView.isHidden = false
            backButton.isHidden = false
            if rigthButtonTitle != nil {
                rigthButton.setTitle(rigthButtonTitle!.localize(), for: .normal)
            } else {
                rigthButton.setTitle("Edit".localize(), for: .normal)
            }
            titleLabelBottomConstraint.constant = 20
        case .account:
            rigthButton.isHidden = false
            seperatorView.isHidden = false
            backButton.isHidden = false
            backButton.setImage(UIImage(named: "cancelVC"), for: .normal)
            rigthButton.setImage(UIImage(named: "settings"), for: .normal)
            titleLabelBottomConstraint.constant = 20
        case .notification:
            seperatorView.isHidden = false
            backButton.isHidden = false
            backButton.setImage(UIImage(named: "cancelVC"), for: .normal)
            titleLabelBottomConstraint.constant = 20
        }
    }
}

extension NavigationView: AvatarImageViewDelegate {
    func avatarImageView(avatarImageView: AvatarImageView, didTapWith image: UIImage) {
        delegate?.navigationViewDidSelectAction(action: .avatar)
    }
    
    @IBAction func backClick(_ sender: Any) {
        delegate?.navigationViewDidSelectAction(action: .back)
    }
    
    @IBAction func rigthAction(_ sender: Any) {
        switch type {
        case .defaultWithEdit, .editType, .account:
            delegate?.navigationViewDidSelectAction(action: .edit)
        case .filterType:
            delegate?.navigationViewDidSelectAction(action: .filter)
        case .clearType:
            delegate?.navigationViewDidSelectAction(action: .clear)
        case .defaultWithAvatar:
            delegate?.navigationViewDidSelectAction(action: .notification)
        default:
            break
        }
    }
}
