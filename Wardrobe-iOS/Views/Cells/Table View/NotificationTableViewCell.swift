//
//  NotificationTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 7/16/21.
//  Copyright © 2021 Schaff. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    @IBOutlet weak var lookImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureLabel()
    }

    private func configureLabel() {
        lookImageView.layer.cornerRadius = 10
    }
    
    public func configure(model: NotificationModel) {
        titleLabel.text = model.title.localize()
        descriptionLabel.text = model.body.localize()
        if model.lookId != nil {
            lookImageView.pin_setImage(from: URL(string: model.url ?? ""))
        } else {
            lookImageView.image = model.calendarEventModelModel?.setModel?.lookId != nil ? model.calendarEventModelModel?.setModel?.lookImage : UIImage(named: "setNotification")
        }
        let date = Date(timeIntervalSince1970: (model.date ?? 0) / 1000)
        dateLabel.text = DateUtil.stringFromDateForNotificationList(date)
        
    }
}
