//
//  SearchFilterTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 12/16/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

protocol SearchFilterTableViewCellViewCellDelegate: class {
    func selectCell(_ cell: SearchFilterTableViewCell, _ indexSelectedCell: Int)
    func deselectCell(_ cell: SearchFilterTableViewCell, _ indexDeselectedCell: Int)
}

class SearchFilterTableViewCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    private var parameterModel : ItemParameterModel?
    private var selectedParameters: [ItemParametersType: [Int64]]?
    weak var delegate: SearchFilterTableViewCellViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    func configureUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize = UICollectionViewFlowLayout.automaticSize
        collectionView.register(cell: ItemColorTypeCollectionViewCell.self)
        collectionView.register(cell: ItemTypeCollectionViewCell.self)
    }
    
    func configure(_ model : ItemParameterModel, selectedParameters: [ItemParametersType: [Int64]]) {
        self.selectedParameters = selectedParameters
        parameterModel = model
        if model.type == .color {
            collectionView.updateInsets(horizontal: 36, interItem: 10, interRow: 8, estimatedSize: CGSize(width: 40, height: 60), left: 16)
        } else if model.type == .type {
            collectionView.updateInsets(horizontal: 86, interItem: 10, interRow: 8, estimatedSize: CGSize(width: 100, height: 60), left: 16)
        } else {
            collectionView.updateInsets(horizontal: 16, interItem: 10, interRow: 8, estimatedSize: CGSize(width: 100, height: 60), left: 16)
        }
        collectionView.allowsMultipleSelection = true
        collectionView.reloadData()
    }
    
    func updateSelectedItems(selectedParameters: [ItemParametersType: [Int64]]) {
        self.selectedParameters = selectedParameters
    }
}

//MARK:- UICollectionViewDelegate && UICollectionViewDataSource
extension SearchFilterTableViewCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
            let selectedParameterIds = selectedParameters?[parameterModel!.type]
            cell.configure(color: color, isSelected: selectedParameterIds?.contains(parameter!.id) ?? false, isWhite: parameter!.id == 1)
            if selectedParameterIds?.contains(parameter!.id) ?? false {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
//            if indexPath.row == parameterModel!.parameterModels!.count - 1 {
//                collectionView.contentSize = CGSize(width: collectionView.contentSize.width + 100, height: collectionView.contentSize.height)
//            }
//            print("ed0",collectionView.contentSize)
            return cell
        } else if parameterModel?.type == .print {
            let parameter = parameterModel!.parameterModels![indexPath.row]
            let image = UIImage(named: parameter.defautText ?? "")
            let cell : ItemColorTypeCollectionViewCell = collectionView.dequeueReusableCell(ItemColorTypeCollectionViewCell.self, indexPath: indexPath)
            let selectedParameterIds = selectedParameters?[parameterModel!.type]
            cell.configure(image: image ?? UIImage(), isSelected: selectedParameterIds?.contains(parameter.id) ?? false)
            if selectedParameterIds?.contains(parameter.id) ?? false {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
            return cell
        } else {
            let parameter = parameterModel!.parameterModels![indexPath.row]
            let info = parameter.name ?? ""
            let cell : ItemTypeCollectionViewCell = collectionView.dequeueReusableCell(ItemTypeCollectionViewCell.self, indexPath: indexPath)
            let selectedParameterIds = selectedParameters?[parameterModel!.type]
            cell.configure(info: info, isSelected: selectedParameterIds?.contains(parameter.id) ?? false, isSearch: true)
            if selectedParameterIds?.contains(parameter.id) ?? false {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? CellSelectionProtocol
        cell?.select()
        delegate?.selectCell(self, indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? CellSelectionProtocol
        cell?.deselect()
        delegate?.deselectCell(self, indexPath.row)
    }
}
