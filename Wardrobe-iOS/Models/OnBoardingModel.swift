//
//  OnBoardingModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 11/14/21.
//  Copyright © 2021 Schaff. All rights reserved.
//

import UIKit

class OnBoardingModel {
    let title: String
    let description: String
    let image: UIImage
    init(title: String, description: String, image: UIImage) {
        self.title = title
        self.description = description
        self.image = image
    }
}
