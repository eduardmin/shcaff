//
//  ItemCategorySelectViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 9/2/20.
//

import UIKit

class ItemCategorySelectViewController: BaseAlertViewController {

    private var tableView: UITableView = UITableView()
    private var cancelButton: UIButton = UIButton()
    private var titleLabel: UILabel = UILabel()
    private var descriptionLabel: UILabel = UILabel()
    private let cellHeigth: CGFloat = 65
    public var viewModel: CreateLookViewModel!
    public var selectCompletion: ((Any?) -> Void)?
    
    override func viewDidLoad() {
        topInset = 0
        bottomInset = 0
        super.viewDidLoad()
        createViews()
    }
    
    //MARK:- Private functions
    private func createViews() {
        configureUI()
        setupConstraints()
    }
    
    private func configureUI() {
        cancelButton.setImage(UIImage(named: "cancelGray"), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        contentView.addSubview(cancelButton)
        titleLabel.text = "Add Item".localize()
        titleLabel.textColor = SCColors.titleColor
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        descriptionLabel.text = "Choose the category of your item".localize()
        descriptionLabel.textColor = SCColors.mainGrayColor
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.textAlignment = .center
        contentView.addSubview(descriptionLabel)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.register(cell: ItemCategoryTableViewCell.self)
        contentView.addSubview(tableView)
    }
    
    @objc private func cancelAction() {
        dismissViewController()
    }
    
    private func setupConstraints() {
        for subview in self.contentView.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let metrics = ["tableViewHeight" : CGFloat(viewModel.clothingTypes.count) * cellHeigth, "cancelButtonHeigth" : 18, "topInsetDescripton" : 15, "topInset" : 15, "inset" : 30, "bottomInset": 35]
        let views = ["tableView" : tableView, "cancelButton" : cancelButton, "descriptionLabel" : descriptionLabel, "titleLabel" : titleLabel]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[tableView]-(0)-|", options: [], metrics: metrics, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[cancelButton(==cancelButtonHeigth)]-(22)-|", options: [], metrics: metrics, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[descriptionLabel]-(0)-|", options: [], metrics: metrics, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[titleLabel]-(0)-|", options: [], metrics: metrics, views: views))

        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(topInset)-[titleLabel]-(topInsetDescripton)-[descriptionLabel]-(inset)-[tableView(==tableViewHeight)]-(0)-|", options: [], metrics: metrics, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[cancelButton(==cancelButtonHeigth)]", options: [], metrics: metrics, views: views))


    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource
extension ItemCategorySelectViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.clothingTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ItemCategoryTableViewCell.self) as ItemCategoryTableViewCell
        let type = viewModel.clothingTypes[indexPath.row]
        cell.configure(type.param.name ?? "", type.empty)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let clothingType = viewModel.clothingTypes[indexPath.row]
        if !clothingType.empty {
            tableView.deselectRow(at: indexPath, animated: true)
            selectCompletion?(indexPath.row)
            dismissViewController()
        }
    }
}
