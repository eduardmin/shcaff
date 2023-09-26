//
//  LookSelectView.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/30/20.
//

import UIKit

protocol LookSelectViewDelegate: AnyObject {
    func selectItemCategory(_ index: Int)
}

class LookSelectView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var contentView: UIView!
    weak var delegate: LookSelectViewDelegate?
    var viewModel: CreateLookViewModel!
    override init(frame: CGRect) {
        super.init(frame: frame)
         commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//MARK:- Private functions
extension LookSelectView {
    private func commonInit() {
        Bundle.main.loadNibNamed("LookSelectView", owner: self, options: nil)
        addSubview(contentView)
        contentView.addConstraintsToSuperView()
        configureUI()
    }
    
    private func configureUI() {
        titleLabel.text = "Choose the items you want to wear today, and we’ll suggest all the possible looks with that item.Here you can also create sets and save them to albums.".localize()
        tableView.register(cell: LookSelectTableViewCell.self)
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource
extension LookSelectView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.clothingTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(LookSelectTableViewCell.self) as LookSelectTableViewCell
        let clothingType = viewModel.clothingTypes[indexPath.row]
        cell.configure(clothingType.param.name ?? "", clothingType.empty)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let clothingType = viewModel.clothingTypes[indexPath.row]
        if !clothingType.empty {
            EventLogger.logEvent("Create Look type selected", withParameters: ["name": clothingType.param.defautText ?? ""])
            delegate?.selectItemCategory(indexPath.row)
        }
    }
}


