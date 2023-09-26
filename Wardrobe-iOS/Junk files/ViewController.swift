//
//  ViewController.swift
//  Wardrobe-iOS
//
//  Created by Mariam Khachatryan on 3/28/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var imageview: UIImageView!
    @IBOutlet private weak var editItemView: EditItemView!

    override func viewDidLoad() {
        super.viewDidLoad()
        editItemView.set(image: "shirt.png")
    }
    
    @IBAction func colorButtonAction(_ sender: UIButton) {
        editItemView.setLineColor(sender.backgroundColor!)
    }

    @IBAction func lineWidthSliderAction(_ sender: UISlider) {
        editItemView.setLineWidth(CGFloat(sender.value))
    }
    
    @IBAction func lineSpacingSliderAction(_ sender: UISlider) {
        editItemView.setLineSpacing(CGFloat(sender.value))
    }
    
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        let patterns: [PatternType] = [.None, .VerticalLine, .HorizontalLine, .Cell]
        editItemView.setPattern(patterns[sender.selectedSegmentIndex])
    }
    
    @IBAction func seeImageButtonAction(_ sender: UIButton) {
        imageview.layer.borderColor = UIColor.gray.cgColor
        imageview.layer.borderWidth = 1
        imageview.image = editItemView.screenShotImage()
    }

}

