//
//  OnBoardingViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 11/13/21.
//  Copyright © 2021 Schaff. All rights reserved.
//

import UIKit

class OnBoardingViewModel {
    var onBoardingModels: [OnBoardingModel]!
    init() {
        configureModel()
    }
    
    func configureModel() {
        let model1 = OnBoardingModel(title: "Collect Your Closet".localize(), description: "Choose clothes from the basics or add your own clothes manually by taking a picture from the closet.".localize(), image: UIImage(named: "onboarding1")!)
        let model2 = OnBoardingModel(title: "See Suggestions Everyday".localize(), description: "After adding clothes to your closet you’ll see suggestions on the homepage picked individually for you.".localize(), image: UIImage(named: "onboarding2")!)
        let model3 = OnBoardingModel(title: "Plan Your Outfits".localize(), description: "Plan outfits from the suggestions by clicking “Today’s Choice” for today or “To Calendar” for another day.".localize(), image: UIImage(named: "onboarding3")!)
        let model4 = OnBoardingModel(title: "Create Your Look".localize(), description: "Create your own look in the “Create Look” section, see suggestions with chosen clothes or save them as a set.".localize(), image: UIImage(named: "onboarding4")!)
        let model5 = OnBoardingModel(title: "See Account Statistics".localize(), description: "Edit your account and see statistics of your most worn, least worn, and last worn clothes on your account page.".localize(), image: UIImage(named: "onboarding5")!)
        onBoardingModels = [model1, model2, model3, model4, model5]
    }
}
