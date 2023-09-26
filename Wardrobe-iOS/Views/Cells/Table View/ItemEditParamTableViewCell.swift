//
//  ItemEditParamTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 6/6/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

protocol CellSelectionProtocol {
    func select()
    func deselect()
}

protocol ItemEditParamTableViewCellDelegate: class {
    func seeAllAction(_ cell: ItemEditParamTableViewCell)
    func selectCell(_ cell: ItemEditParamTableViewCell, _ indexSelectedCell: Int)
    func deselectCell(_ cell: ItemEditParamTableViewCell, _ indexDeselectedCell: Int)
}

class ItemEditParamTableViewCell: BaseTableViewCell {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: ItemEditParamTableViewCellDelegate?
    private var parameterModel : ItemParameterModel?
    private var selectedParameterIds: [Int64]?

    override func awakeFromNib() {
        isSeparatorFull = false
        super.awakeFromNib()
        setUpUI()
    }
    
    //MARK:- UI
    func setUpUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize = UICollectionViewFlowLayout.automaticSize
        collectionView.register(cell: ItemColorTypeCollectionViewCell.self)
        collectionView.register(cell: ItemTypeCollectionViewCell.self)
    }
    
    //MARK:- Action
    @IBAction func seeAllAction(_ sender: Any) {
        delegate?.seeAllAction(self)
    }
}

//MARK:- Public Function
extension ItemEditParamTableViewCell {
    func configure(_ model : ItemParameterModel, _ title: String, _ selectedParameterIds: [Int64]?, _ topSeperator: Bool) {
        self.selectedParameterIds = selectedParameterIds
        parameterModel = model
        infoLabel.text = title
        seeAllButton.isHidden = !(model.parameterModels?.count ?? 0 > 4)
        if model.type == .color || model.type == .print {
            collectionView.updateInsets(horizontal: 30, interItem: 10, interRow: 8, estimatedSize: CGSize(width: 40, height: 40), left: 16)
        } else {
            collectionView.updateInsets(horizontal: 16, interItem: 10, interRow: 8, estimatedSize: CGSize(width: 100, height: 40))
        }
        collectionView.allowsMultipleSelection = model.muliplyTouch
        collectionView.reloadData()
        if topSeperator {
            addTopSeperator()
        }
    }
    
    func updateSelectedItems(_ selectedParameterIds: [Int64]?) {
        self.selectedParameterIds = selectedParameterIds
    }
}

//MARK:- UICollectionViewDelegate && UICollectionViewDataSource
extension ItemEditParamTableViewCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let parameterModel = parameterModel {
            return parameterModel.parameterModels!.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if parameterModel?.type == .color {
            let parameter = parameterModel!.parameterModels![indexPath.row] as? ColorParameterModel
            let color = UIColor(hexString: parameter?.code ?? "")
            let cell : ItemColorTypeCollectionViewCell = collectionView.dequeueReusableCell(ItemColorTypeCollectionViewCell.self, indexPath: indexPath)
            cell.configure(color: color, isSelected: selectedParameterIds?.contains(parameter!.id) ?? false, isWhite: parameter!.id == 1)
            if selectedParameterIds?.contains(parameter!.id) ?? false {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
            return cell
        } else if parameterModel?.type == .print {
            let parameter = parameterModel!.parameterModels![indexPath.row]
            let image = UIImage(named: parameter.defautText ?? "")
            let cell : ItemColorTypeCollectionViewCell = collectionView.dequeueReusableCell(ItemColorTypeCollectionViewCell.self, indexPath: indexPath)
            cell.configure(image: image ?? UIImage(), isSelected: selectedParameterIds?.contains(parameter.id) ?? false)
            if selectedParameterIds?.contains(parameter.id) ?? false {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
            return cell
        } else {
            let parameter = parameterModel!.parameterModels![indexPath.row]
            let info = parameter.name ?? ""
            let cell : ItemTypeCollectionViewCell = collectionView.dequeueReusableCell(ItemTypeCollectionViewCell.self, indexPath: indexPath)
            cell.configure(info: info, isSelected: selectedParameterIds?.contains(parameter.id) ?? false)
            if selectedParameterIds?.contains(parameter.id) ?? false {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let parameter = parameterModel!.parameterModels![indexPath.row]
        if selectedParameterIds?.contains(parameter.id) ?? false && !parameterModel!.muliplyTouch{
            let cell = collectionView.cellForItem(at: indexPath) as? CellSelectionProtocol
            cell?.deselect()
            delegate?.deselectCell(self, indexPath.row)
        } else {
            let cell = collectionView.cellForItem(at: indexPath) as? CellSelectionProtocol
            cell?.select()
            delegate?.selectCell(self, indexPath.row)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? CellSelectionProtocol
        cell?.deselect()
        delegate?.deselectCell(self, indexPath.row)
    }
}
