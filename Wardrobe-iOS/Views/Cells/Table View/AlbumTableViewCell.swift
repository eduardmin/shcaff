//
//  AlbumTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/22/20.
//

import UIKit

protocol AlbumTableViewCellDelegate: class {
    func editAlbum(_ cell: AlbumTableViewCell)
    func deleteAlbum(_ cell: AlbumTableViewCell)
}

class AlbumTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var saveLabel: UILabel!
    private let albumEditSelectView = ItemSelectView.instanceFromNib()
    private let layout = AlbumCollectionViewLayout()
    private let topMargin: CGFloat = 100
    private var albumModel: AlbumModel?
    private var setModels: [SetModel]?
    private var contentSize: CGSize?
    weak var delegate: AlbumTableViewCellDelegate?
    var count: Int {
        return 3
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        selectionStyle = .none
        albumEditSelectView.delegate = self
        collectionView.isUserInteractionEnabled = false
        collectionView.layer.cornerRadius = 20
        layout.panding = 1
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cell: AlbumSetCollectionViewCell.self)
        collectionView.register(cell: ClosetItemCollectionViewCell.self)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandle(_:)))
        addGestureRecognizer(longPress)
    }

    func configure(_ albumModel: AlbumModel) {
        self.albumModel = albumModel
        self.setModels = albumModel.setModels.sorted(by: {$0.itemIds?.count ?? 0 > $1.itemIds?.count ?? 0})
        saveLabel.text = "\(albumModel.setModels.count) "  + "saves".localize()
        albumName.text = albumModel.name
        layout.count = count
        collectionView.reloadData()
    }
}

//MARK:- UICollectionViewDelegate, UICollectionViewDataSource
extension AlbumTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if albumModel!.setModels.count > indexPath.row {
            let setModel = setModels?[indexPath.row]
            if setModel?.lookId != nil {
                let cell = collectionView.dequeueReusableCell(ClosetItemCollectionViewCell.self, indexPath: indexPath) as ClosetItemCollectionViewCell
                cell.configureWithoutCornerRadius(setModel?.lookImage ?? UIImage())
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(AlbumSetCollectionViewCell.self, indexPath: indexPath) as AlbumSetCollectionViewCell
                cell.configure(setModel?.itemModels ?? [])
                return cell
            }
        } else {
            let cell = collectionView.dequeueReusableCell(AlbumSetCollectionViewCell.self, indexPath: indexPath) as AlbumSetCollectionViewCell
            cell.configure([])
            return cell
        }
    }
}

//MARK:- ItemSelectViewDelegate
extension AlbumTableViewCell: ItemSelectViewDelegate {
    func selectButton(type: ItemSelectType) {
        switch type {
        case .edit:
            delegate?.editAlbum(self)
        case .delete:
            delegate?.deleteAlbum(self)
        default:
            break
        }
    }
    
    @objc func longPressHandle(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            if let hostView = UIApplication.appDelegate.tabBarController.view, let albumModel = albumModel  {
                albumEditSelectView.frame = hostView.bounds
                hostView.addSubview(albumEditSelectView)
                albumEditSelectView.appearOnView(.album, hostView, albumModel.isDefault ? nil : "Edit Album", "Delete Album", getCellView(viewFrame: frame))
            }
        }
    }
    
    private func getCellView(viewFrame: CGRect) -> UIView {
        let customView = Bundle.main.loadNibNamed("AlbumTableViewCell", owner: nil, options: nil)?[0] as? AlbumTableViewCell
        customView?.frame = viewFrame
        customView?.backgroundColor = UIColor.clear
        customView?.albumName.textColor = SCColors.whiteColor
        customView?.saveLabel.textColor = SCColors.whiteColor
        customView?.configure(albumModel!)
        return customView ?? UIView()
    }
}
