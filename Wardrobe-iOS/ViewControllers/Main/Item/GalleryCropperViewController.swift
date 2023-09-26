//
//  GalleryCropperViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 11/1/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class GalleryCropperViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confiremButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidth: NSLayoutConstraint!
    private var image: UIImage?
    var imageSetCompletion: ((UIImage) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        scrollView.delegate = self
        setImageToCrop(image: image!)
    }
    
    private func configureUI() {
        cancelButton.layer.cornerRadius = cancelButton.bounds.width / 2
        titleLabel.text = "Choose a Picture".localize()
        confiremButton.setMode(.background, color: SCColors.whiteColor)
        confiremButton.setTitle("Continue".localize(), for: .normal)
    }
    
    func setImage(_ image: UIImage) {
        self.image = image
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func setImageToCrop(image:UIImage){
        imageView.image = image
        imageViewWidth.constant = image.size.width
        imageViewHeight.constant = image.size.height
        let scaleHeight = scrollView.frame.size.width/image.size.width
        let scaleWidth = scrollView.frame.size.height/image.size.height
        scrollView.minimumZoomScale = max(scaleWidth, scaleHeight)
        scrollView.zoomScale = max(scaleWidth, scaleHeight)
    }
}

//MARK:- Button Action
extension GalleryCropperViewController {
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        //        let scale:CGFloat = 1 / scrollView.zoomScale
        //        let x:CGFloat = scrollView.contentOffset.x * scale
        //        let y:CGFloat = scrollView.contentOffset.y * scale
        //        let width:CGFloat = scrollView.frame.size.width * scale
        //        let height:CGFloat = scrollView.frame.size.height * scale
        //        let image = imageView.image!
        //        let croppedCGImage = image.cgImage?.cropping(to: CGRect(x: x, y: y, width: width, height: height))
        //        let croppedImage = UIImage(cgImage: croppedCGImage!, scale: image.scale, orientation: image.imageOrientation)
        UIGraphicsBeginImageContextWithOptions(scrollView.bounds.size, true, UIScreen.main.scale)
        let offset = scrollView.contentOffset
        UIGraphicsGetCurrentContext()!.translateBy(x: -offset.x, y: -offset.y)
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        dismiss(animated: true, completion: nil)
        imageSetCompletion?(image ?? UIImage())
    }
}
