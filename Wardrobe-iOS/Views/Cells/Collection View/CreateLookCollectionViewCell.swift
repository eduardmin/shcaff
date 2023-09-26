//
//  CreateLookCollectionViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/29/20.
//

import UIKit

protocol CreateLookCollectionViewCellDelegate: class {
    func plusAction()
    func selectItem(sectionIndex: Int, index: Int)
    func setAction()
}

class CreateLookCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var setCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeigthConstraint: NSLayoutConstraint!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emtyTitleLabel: UILabel!
    @IBOutlet weak var emtyDescLabel: UILabel!
    @IBOutlet weak var emtyViewHeight: NSLayoutConstraint!
    weak var delegate: CreateLookCollectionViewCellDelegate?
    private let itemPadding: CGFloat = 5
    private let leftMargin: CGFloat = 14
    private let itemHeight: CGFloat = 42
    private let tableCellHeight: CGFloat = 183
    var sectionModels: [ItemSectionModel]?
    var setItems: [ItemModel]?
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        setCollectionView.backgroundColor = SCColors.collectionBackgroundColor.withAlphaComponent(0.8)
        setCollectionView.layer.cornerRadius = 20
        setCollectionView.addShadow(true, 1, 2)
        plusButton.layer.cornerRadius = 10
        plusButton.layer.borderColor = SCColors.collectionBackgroundColor.cgColor
        plusButton.layer.borderWidth = 2
        plusButton.addShadow(true, 2, 10)
        resultLabel.text = "Results".localize()
        tableView.register(cell: LookItemTableViewCell.self)
        tableView.separatorStyle = .none
        let layout = CenterViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: itemHeight, height: itemHeight)
        setCollectionView.collectionViewLayout = layout
        setCollectionView.register(cell: SetItemCollectionViewCell.self)
        setCollectionView.updateInsets(horizontal: leftMargin, vertical: leftMargin, interItem: itemPadding, interRow: itemPadding)
        setCollectionView.remembersLastFocusedIndexPath = true
        setCollectionView.setNeedsFocusUpdate()
        setCollectionView.updateFocusIfNeeded()
        setCollectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setAction)))
        emtyTitleLabel.text = "No results".localize()
        emtyDescLabel.text = "Please try to search with other items".localize()
    }
    
    func configureItems(_ sectionModels: [ItemSectionModel]?) {
        if self.sectionModels?.count != sectionModels?.count {
            self.sectionModels = sectionModels
            collectionViewHeigthConstraint.constant = tableCellHeight * CGFloat(sectionModels?.count ?? 0)
//            if sectionModels?.count ?? 0 > 1 {
//                if sectionModels?.count ?? 0 >= sectionModels?.last?.index ?? 0 {
//                   // tableView.insertRows(at: [IndexPath(row: (sectionModels?.last?.index ?? 0), section: 0)], with: .none)
//                    tableView.reloadData()
//                } else {
//                    tableView.insertRows(at: [IndexPath(row: (sectionModels?.count ?? 0) - 1, section: 0)], with: .none)
//                }
//                tableView.performBatchUpdates(nil, completion: nil)
//            } else {
                tableView.reloadData()
        //    }
        }
    }
    
    func configureSetItem(_ setItems: [ItemModel]) {
        self.setItems = setItems
        setCollectionView.reloadData()
    }
    
    func hideShowEmptyView(hidden: Bool, emptyViewHeight: CGFloat = 0) {
        emptyView.isHidden = hidden
        emtyViewHeight.constant = emptyViewHeight
    }
}

//MARK:- Button Action
extension CreateLookCollectionViewCell {
    @IBAction func plusClick(_ sender: Any) {
        delegate?.plusAction()
    }
    
    @objc func setAction() {
        delegate?.setAction()
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource
extension CreateLookCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionModels?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(LookItemTableViewCell.self) as LookItemTableViewCell
        cell.delegate = self
        let sectionModel = sectionModels?[indexPath.row]
        cell.configure(sectionModel!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableCellHeight
    }
}

//MARK:- UICollectionViewDelegate, UICollectionViewDataSource
extension CreateLookCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return setItems?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : SetItemCollectionViewCell = collectionView.dequeueReusableCell(SetItemCollectionViewCell.self, indexPath: indexPath)
        let itemModel = setItems?[indexPath.row]
        if let image = itemModel?.image {
            cell.configue(image: image, cornerRadius: 10)
        }
        return cell
    }
}

//MARK:- LookItemTableViewCellDelegate
extension CreateLookCollectionViewCell: LookItemTableViewCellDelegate {
    func selectItem(cell: LookItemTableViewCell, index: Int) {
        if let indexPath = tableView.indexPath(for: cell) {
            delegate?.selectItem(sectionIndex: indexPath.row, index: index)
        }
    }
}
