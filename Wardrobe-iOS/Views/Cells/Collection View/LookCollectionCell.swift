//
//  LookCollectionCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 5/2/20.
//

import UIKit
import PINRemoteImage
import UIKit.UIGestureRecognizerSubclass
import AudioToolbox

enum MoreState : Int {
    case show
    case hide
}

@objc protocol LookCollectionCellDelegate: class {
    func addAlbum(cell: LookCollectionCell)
    func addCalendar(cell: LookCollectionCell)
    func share(cell: LookCollectionCell)
    @objc optional func openLogo(url: String, message: String)
}

class LookCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var saveLookButton: UIButton!
    @IBOutlet weak var addCalendarButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var moreHeight: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomConstrait: NSLayoutConstraint!
    weak var delegate: LookCollectionCellDelegate?
    private let grLayer = CAGradientLayer()
    private let selectView = ItemSelectView.instanceFromNib()
    private var look: LookModelSuggestion?
    private var longPress: UILongPressGestureRecognizer?
    @IBOutlet weak var imageViewTop: NSLayoutConstraint!
    @IBOutlet weak var imageViewleading: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottom: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var linkLogoButton: UIButton!
    var isAnimating: Bool = false
    override func awakeFromNib() {
        super.awakeFromNib()
        moreButton.isHidden = true
        moreButton.tag = MoreState.hide.rawValue
        saveLookButton.isHidden = true
        addCalendarButton.isHidden = true
        shareButton.isHidden = true
        imageView.layer.cornerRadius = 20
        saveLookButton.layer.cornerRadius = saveLookButton.frame.height / 2
        addCalendarButton.layer.cornerRadius = addCalendarButton.frame.height / 2
        shareButton.layer.cornerRadius = shareButton.frame.height / 2
        collectionView.register(cell: SuggestionLookItemCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.updateInsets(horizontal: 0, interItem: 4)
        selectView.delegate = self
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandle(_:)))
        addGestureRecognizer(longPress!)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func configure(look: LookModelSuggestion, isLongPress: Bool = true, showItems: Bool = false, cornerRadius: CGFloat? = nil, showLogo: Bool = false) {
        self.look = look
        if let cornerRadius = cornerRadius {
            imageView.layer.cornerRadius = cornerRadius
            mainView.layer.cornerRadius = cornerRadius
        }
        
        if !isLongPress, let longPress = longPress {
            removeGestureRecognizer(longPress)
        }
        isAnimating = true
        startAnimating()
        if look.haveItems && showItems {
            let width = (frame.width - 12) / 4
            collectionViewHeight.constant = width
            imageViewBottomConstrait.constant = 7
            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            layout?.itemSize = CGSize(width: width, height: width)
            collectionView.reloadData()
        } else {
            collectionViewHeight.constant = 0
            imageViewBottomConstrait.constant = 0
        }
        imageView.pin_updateWithProgress = true
        imageView.pin_setImage(from: URL(string: look.url)) { [weak self] (result) in
            self?.stopAnimating()
            self?.isAnimating = false
            self?.collectionView.reloadData()
        }
        
        if showLogo, let image = look.logoImage {
            linkLogoButton.isHidden = false
            linkLogoButton.setImage(image, for: .normal)
        } else {
            linkLogoButton.isHidden = true
        }
    }
    
    func configure(image: UIImage) {
        collectionViewHeight.constant = 0
        imageViewBottomConstrait.constant = 0
        imageView.image = image
    }
    
    func stopAnimating() {
        mainView.layer.cornerRadius = 0
        grLayer.removeFromSuperlayer()
    }
    
    func startAnimating(multipleHeight: CGFloat? = nil) {
        stopAnimating()
        mainView.layer.cornerRadius = 20
        addAnimGradientLayerTo(mainView, multipleHeight)
    }
    
    @IBAction func linkLogoButtonAction(_ sender: Any) {
        delegate?.openLogo?(url: look?.resourceUrl ?? "", message: look?.logoMassage ?? "")
    }
}

//MARK:- Button Action
extension LookCollectionCell {
    @IBAction func moreClick(_ sender: Any) {
        if moreButton.tag == MoreState.hide.rawValue {
            moreButton.tag = MoreState.show.rawValue
            showButtons()
        } else {
            moreButton.tag = MoreState.hide.rawValue
            hideButtons()
        }
    }
    
    @IBAction func saveLookClick(_ sender: Any) {
        
    }
    
    @IBAction func addCalendarClick(_ sender: Any) {
        
    }
    
    @IBAction func shareClick(_ sender: Any) {
        
    }
    
}

extension LookCollectionCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return look?.itemModels?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SuggestionLookItemCell = collectionView.dequeueReusableCell(SuggestionLookItemCell.self, indexPath: indexPath)
        let item = look!.itemModels![indexPath.row]
        if isAnimating {
            cell.startAnimating()
        } else {
            cell.stopAnimating()
            cell.configure(image: item.image)
        }
        return cell
    }
}

//MARK:- Private Function
extension LookCollectionCell {
    private func showButtons() {
        self.moreButton.alpha = 0.5
        self.moreHeight.constant = 20
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.saveLookButton.alpha = 1
            self.addCalendarButton.alpha = 1
            self.shareButton.alpha = 1
            self.moreButton.alpha = 1
            self.saveLookButton.isHidden = false
            self.addCalendarButton.isHidden = false
            self.shareButton.isHidden = false
            self.moreButton.setImage(UIImage(named: "moreShow"), for: .normal)
        }, completion: nil)
    }
    
    private func hideButtons() {
        self.moreButton.alpha = 0.5
        self.moreHeight.constant = 30
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.saveLookButton.alpha = 0
            self.addCalendarButton.alpha = 0
            self.shareButton.alpha = 0
            self.moreButton.alpha = 1
            self.saveLookButton.isHidden = true
            self.addCalendarButton.isHidden = true
            self.shareButton.isHidden = true
            self.moreButton.setImage(UIImage(named: "moreHide"), for: .normal)
        }, completion: nil)
    }
    
    private func addAnimGradientLayerTo(_ view: UIView, _ multipleHeight: CGFloat? = nil) {
        let multiple = look?.multipleHeight ?? multipleHeight
        view.clipsToBounds = true
        grLayer.colors = [SCColors.emptyItemFirstColor.cgColor, UIColor.white.withAlphaComponent(0.8).cgColor, SCColors.emptyItemFirstColor.cgColor]
        grLayer.frame = view.bounds
        var rect = grLayer.frame
        rect.size.height = view.bounds.width * (multiple ?? 1)
        grLayer.frame = rect
        grLayer.add(grLayer.sliding, forKey: "")
        view.layer.addSublayer(grLayer)
    }
    
    @objc func longPressHandle(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began, let image = imageView.image, let look = look {
            animateLongPressSelection {
                if let hostView = UIApplication.shared.windows.first {
                    self.selectView.frame = hostView.bounds
                    hostView.addSubview(self.selectView)
                    self.selectView.appearOnLook(.look, look, image: image, hostView, "Add To Album", "Add To Calendar", "Share")
                    hostView.bringSubviewToFront(self.selectView)
                }
            }
        }
    }
    
    func animateLongPressSelection(selectCompletion: @escaping () -> ()) {
        self.imageViewTop.constant = self.imageViewTop.constant + 2
        imageViewleading.constant = self.imageViewleading.constant + 2
        imageViewBottom.constant = self.imageViewBottom.constant + 2
        imageViewTrailing.constant = self.imageViewTrailing.constant + 2
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        } completion: { (isfinish) in
            UIImpactFeedbackGenerator().impactOccurred(intensity: 1)
            self.imageViewTop.constant = self.imageViewTop.constant - 2
            self.imageViewleading.constant = self.imageViewleading.constant - 2
            self.imageViewBottom.constant = self.imageViewBottom.constant - 2
            self.imageViewTrailing.constant = self.imageViewTrailing.constant - 2
            selectCompletion()
        }
    }
    
}

//MARK:- ItemSelectViewDelegate
extension LookCollectionCell: ItemSelectViewDelegate {
    func selectButton(type: ItemSelectType) {
        switch type {
        case .add:
            delegate?.addAlbum(cell: self)
        case .calendar:
            delegate?.addCalendar(cell: self)
        case .share:
            delegate?.share(cell: self)
        default:
            break
        }
    }
}
