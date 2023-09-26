//
//  SearchViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 12/14/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

enum TableViewType: Int {
    case parameter
    case resent
    case suggestion
}

enum CollectionType: Int {
    case filrer
    case search
}

class SearchViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var titleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var emptyLabel: UILabel!
    private var commonCollectionLayout: UICollectionViewLayout?
    private let titleHeight: CGFloat = 72
    private let cellHeight: CGFloat = 77
    private let padding: CGFloat = 10
    private let leftRightMargin: CGFloat = 16
    private let tableViewCell: CGFloat = 60
    private let tableViewSearchHeight: CGFloat = 44
    private let headerViewHeight: CGFloat = 56
    private let panding : CGFloat = 10
    private let viewModel = SearchViewModel()
    private var emptyLooks: [CGFloat] = [1.4, 1, 1, 1.4, 1, 1.4, 1, 1.4, 1, 1.4]
    private var lookDetailViewModel: LookDetailViewModel?
    var _collectionViewLayout: LookCollectionViewLayout?
    var collectionViewLayout: LookCollectionViewLayout {
        get {
            if _collectionViewLayout == nil {
                _collectionViewLayout = LookCollectionViewLayout()
                _collectionViewLayout?.multipleHeights = viewModel.lookModels.map { $0.multipleHeight }
                _collectionViewLayout?.panding = panding
                _collectionViewLayout?.leftRightMargin = leftRightMargin
                _collectionViewLayout?.loadMore = true
            }
            return _collectionViewLayout!
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        viewModel.completion = { [weak self] type in
            guard let strongSelf = self else { return }
            switch type {
            case .textSuggestion:
                strongSelf.handleTextSuggestion()
            case .recent:
                strongSelf.handleRecentTexts()
            case .filter:
                strongSelf.handleFilter()
            case .searchResult(let attributedSting):
                strongSelf.handleSearchResult(searchAttributedString: attributedSting)
            case .searchMoreResult(let attributedSting):
                strongSelf.handleSearchMoreResult(searchAttributedString: attributedSting)
            case .error(let error):
                strongSelf.handleError(error: error)
            }
        }
    }
    
    private func configureUI() {
        titleLabel.attributedText = getNavigationTitle("Search".localize(), "\n" + "For The Clothes".localize())
        descriptionLabel.text = "Search by".localize()
        clearButton.setTitle("Clear".localize(), for: .normal)
        collectionView.allowsSelection = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cell: SearchCollectionViewCell.self)
        collectionView.register(cell: LookCollectionCell.self)
        collectionView.register(cell: LoadingCollectionViewCell.self)
        collectionView.tag = CollectionType.filrer.rawValue
        collectionView.updateInsets(interItem: 8, interRow: 5)
        commonCollectionLayout = collectionView.collectionViewLayout
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cell: SearchFilterTableViewCell.self)
        tableView.register(cell: SearchTextTableViewCell.self)
        tableView.allowsSelection = true
        configureSearchBar()
    }
    
    private func configureSearchBar() {
        searchBar.delegate = self
        searchBar.searchTextField.layer.cornerRadius = 25
        searchBar.searchTextField.layer.masksToBounds = true
        searchBar.searchTextField.backgroundColor = SCColors.secondaryGray
        let backgroundView = searchBar.searchTextField.subviews.first
            if #available(iOS 11.0, *) { // If `searchController` is in `navigationItem`
                backgroundView?.backgroundColor = UIColor.white.withAlphaComponent(0.3) //Or any transparent color that matches with the `navigationBar color`
                backgroundView?.subviews.forEach({ $0.removeFromSuperview() }) // Fixes an UI bug when searchBar appears or hides when scrolling
            }
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Find your look".localize(), attributes: [NSAttributedString.Key.foregroundColor : SCColors.titleColor.withAlphaComponent(0.5)])
        searchBar.searchTextField.textColor = SCColors.titleColor
        searchBar.searchTextField.removeConstraints(searchBar.searchTextField.constraints)
        searchBar.searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchTextField.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: 0).isActive = true
        searchBar.searchTextField.topAnchor.constraint(equalTo: searchBar.topAnchor, constant: 0).isActive = true
        searchBar.searchTextField.rightAnchor.constraint(equalTo: searchBar.rightAnchor, constant: 0).isActive = true
        searchBar.searchTextField.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0).isActive = true
        searchBar.setImage(UIImage(named: "search_item"), for: .search, state: .normal)
        searchBar.setImage(UIImage(named: "optionsGray"), for: .bookmark, state: .normal)
        searchBar.setPositionAdjustment(UIOffset(horizontal: 15, vertical: 0), for: .search)
        searchBar.setPositionAdjustment(UIOffset(horizontal: -12, vertical: 0), for: .bookmark)
        searchBar.accessibilityElementsHidden = false
        searchBar.setImage(UIImage(), for: .clear, state: .normal)
    }
    
    private func showTitle() {
        titleHeightConstraint.constant = titleHeight
        backButton.isHidden = true
        searchBar.resignFirstResponder()
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideTitle() {
        titleHeightConstraint.constant = 0
        backButton.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func changeTableViewElements() {
        tableView.isHidden = false
        switch tableView.tag {
        case TableViewType.parameter.rawValue:
            headerHeightConstraint.constant = 10
            collectionView.isHidden = true
            clearButton.isHidden = true
            tableViewHeightConstraint.constant =  CGFloat(viewModel.filterParameters.count) * tableViewCell
        case TableViewType.resent.rawValue:
            headerHeightConstraint.constant = headerViewHeight
            collectionView.isHidden = true
            clearButton.isHidden = false
            descriptionLabel.text = "Recent Searches".localize()
            viewModel.filterParameters.removeAll()
            tableViewHeightConstraint.constant = CGFloat(viewModel.searchRecentTexts.count) * tableViewSearchHeight
        case TableViewType.suggestion.rawValue:
            headerHeightConstraint.constant = headerViewHeight
            viewModel.filterParameters.removeAll()
            collectionView.isHidden = true
            clearButton.isHidden = true
            descriptionLabel.text = "Suggested Search".localize()
            emptyLabel.text = "No Suggestion Found".localize()
            emptyLabel.isHidden = !viewModel.suggestedTexts.isEmpty
            tableViewHeightConstraint.constant = CGFloat(viewModel.suggestedTexts.count) * tableViewSearchHeight
        default:
            break
        }
        tableView.reloadData()
    }
    
    private func initialState() {
        headerHeightConstraint.constant = headerViewHeight
        view.updateConstraintsIfNeeded()
        collectionView.isHidden = false
        collectionView.collectionViewLayout = commonCollectionLayout!
        collectionView.tag = CollectionType.filrer.rawValue
        tableView.isHidden = true
        clearButton.isHidden = true
        searchBar.text = nil
        emptyLabel.isHidden = true
        descriptionLabel.text = "Search by".localize()
        viewModel.initialState()
        collectionView.reloadData()
    }
    
    @IBAction func backAction(_ sender: Any) {
        showTitle()
        initialState()
    }
    
    @IBAction func clearAction(_ sender: Any) {
        clearAllRecents()
    }
}

//MARK:- Request Send
extension SearchViewController {
    func getSearchSuggesstion(searchText: String) {
        if searchText.isEmpty {
            LoadingIndicator.show(on: view)
            viewModel.getRecentSearchTexts()
        } else {
            viewModel.getSuggestion(searchText: searchText)
        }
    }
    
    func clearAllRecents() {
        LoadingIndicator.show(on: view)
        viewModel.deleteRecentSearchTexts()
    }
    
    func loadingMore() {
        viewModel.searchMore(text: searchBar.text)
    }
}

//MARK:- Handle updates
extension SearchViewController {
    func handleTextSuggestion() {
        changeTableViewElements()
    }
    
    func handleRecentTexts() {
        LoadingIndicator.hide(from: view)
        changeTableViewElements()
    }
    
    func handleFilter() {
        tableView.tag = TableViewType.parameter.rawValue
        changeTableViewElements()
    }
    
    func handleSearchResult(searchAttributedString: NSAttributedString?) {
        LoadingIndicator.hide(from: view)
        collectionView.isHidden = false
        collectionView.tag = CollectionType.search.rawValue
        emptyLabel.text = "No Looks Found".localize()
        emptyLabel.isHidden = !viewModel.lookModels.isEmpty
        lookDetailViewModel?.addMoreLook(looks: viewModel.lookModels, isMoreLoad: viewModel.loadMore)
        collectionViewLayout.multipleHeights = viewModel.lookModels.map { $0.multipleHeight }
        collectionView.collectionViewLayout = collectionViewLayout
        if let searchAttributedString = searchAttributedString {
            tableView.isHidden = true
            clearButton.isHidden = true
            headerHeightConstraint.constant = headerViewHeight
            let attributedString = NSMutableAttributedString(string: "Search".localize() + ": ", attributes: [.foregroundColor: SCColors.titleColor, .font: UIFont.systemFont(ofSize: 15, weight: .heavy)])
            attributedString.append(searchAttributedString)
            descriptionLabel.attributedText = attributedString
        }
        collectionView.reloadData()
    }
    
    func handleSearchMoreResult(searchAttributedString: NSAttributedString?) {
        LoadingIndicator.hide(from: view)
        lookDetailViewModel?.addMoreLook(looks: viewModel.lookModels, isMoreLoad: viewModel.loadMore)
        collectionViewLayout.multipleHeights = viewModel.lookModels.map { $0.multipleHeight }
        collectionView.reloadData()
    }
    
    func handleError(error: NetworkError?) {
        LoadingIndicator.hide(from: view)
        switch error {
        case .failError(code: _, message: _):
            break
        case .successError(errorType: let errorType):
            if let _ = SearchError(rawValue: errorType) {
                return
            }
        default:
            break
        }
        
        AlertPresenter.presentRequestErrorAlert(on: self)
    }
}

//MARK:- UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        hideTitle()
        tableView.tag = TableViewType.resent.rawValue
        changeTableViewElements()
        getSearchSuggesstion(searchText: "")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableView.tag = searchText.isEmpty ? TableViewType.resent.rawValue : TableViewType.suggestion.rawValue
        getSearchSuggesstion(searchText: searchText)
        changeTableViewElements()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        let searchFilterViewController: SearchFilterViewController = SearchFilterViewController.initFromNib()
        searchFilterViewController.viewModel = viewModel
        navigationController?.pushViewController(searchFilterViewController, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            searchBar.resignFirstResponder()
            LoadingIndicator.show(on: view)
            viewModel.search(seachText: text)
        }
    }
}

//MARK:- UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == CollectionType.filrer.rawValue {
            return viewModel.getSearchParameterCount()
        }
        
        if viewModel.lookModels.count > 0 {
            return viewModel.loadMore ? viewModel.lookModels.count + 1 : viewModel.lookModels.count
        }

        return emptyLooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == CollectionType.filrer.rawValue {
            let cell: SearchCollectionViewCell = collectionView.dequeueReusableCell(SearchCollectionViewCell.self, indexPath: indexPath)
            let type = viewModel.getType(indexPath: indexPath)
            cell.configure(viewModel.getTitle(type: type), imageName: viewModel.getImageName(type: type))
            return cell
        } else {
            if viewModel.lookModels.count == indexPath.row && viewModel.lookModels.count != 0 && viewModel.loadMore {
                let cell: LoadingCollectionViewCell = collectionView.dequeueReusableCell(LoadingCollectionViewCell.self, indexPath: indexPath)
                cell.startAnimating()
                loadingMore()
                return cell
            }
            let cell : LookCollectionCell = collectionView.dequeueReusableCell(LookCollectionCell.self, indexPath: indexPath)
            cell.delegate = self
            if indexPath.row < viewModel.lookModels.count {
                let look = viewModel.lookModels[indexPath.row]
                cell.configure(look: look)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width - 3 * leftRightMargin) / 2, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == CollectionType.filrer.rawValue {
            hideTitle()
            tableView.tag = TableViewType.parameter.rawValue
            viewModel.selectFilter(indexPath: indexPath)
        } else {
            if viewModel.lookModels.isEmpty { return }
            let lookModel = viewModel.lookModels[indexPath.row]
            if let cell = collectionView.cellForItem(at: indexPath) as? LookCollectionCell {
                let lookController: LookViewController = LookViewController.initFromNib()
                lookController.delegate = self
                lookDetailViewModel = LookDetailViewModel(selectedLookModel: lookModel, looksModel: viewModel.lookModels, image: cell.imageView.image ?? UIImage())
                lookController.lookDetailViewModel = lookDetailViewModel
                    let navigationViewController = UINavigationController(rootViewController: lookController)
                navigationViewController.modalPresentationStyle = .overFullScreen
                navigationViewController.modalTransitionStyle = .coverVertical
                navigationViewController.navigationBar.isHidden = true
                navigationController?.present(navigationViewController, animated: true, completion: nil)
            }
        }
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource
extension SearchViewController: UITableViewDelegate, UITableViewDataSource, SearchFilterTableViewCellViewCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case TableViewType.parameter.rawValue:
            return viewModel.filterParameters.count
        case TableViewType.resent.rawValue:
            return viewModel.searchRecentTexts.count
        case TableViewType.suggestion.rawValue:
            return viewModel.suggestedTexts.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView.tag {
        case TableViewType.parameter.rawValue:
            let cell: SearchFilterTableViewCell = tableView.dequeueReusableCell(SearchFilterTableViewCell.self)
            cell.delegate = self
            let model = viewModel.filterParameters[indexPath.row]
            cell.configure(model, selectedParameters: viewModel.selectedItemParameterModels)
            return cell
        case TableViewType.resent.rawValue:
            let cell: SearchTextTableViewCell = tableView.dequeueReusableCell(SearchTextTableViewCell.self)
            let text = viewModel.searchRecentTexts[indexPath.row]
            cell.configure(text)
            cell.selectionStyle = .none
            return cell
        case TableViewType.suggestion.rawValue:
            let cell: SearchTextTableViewCell = tableView.dequeueReusableCell(SearchTextTableViewCell.self)
            let text = viewModel.suggestedTexts[indexPath.row]
            cell.configure(text)
            cell.selectionStyle = .none
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView.tag {
        case TableViewType.parameter.rawValue:
            return tableViewCell
        case TableViewType.resent.rawValue:
            return tableViewSearchHeight
        case TableViewType.suggestion.rawValue:
            return tableViewSearchHeight
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var text: String = ""
        switch tableView.tag {
        case TableViewType.suggestion.rawValue:
            text = viewModel.suggestedTexts[indexPath.row]
        case TableViewType.resent.rawValue:
            text = viewModel.searchRecentTexts[indexPath.row]
        default:
            return
        }
        
        searchBar.text = text
    }
    
    func selectCell(_ cell: SearchFilterTableViewCell, _ indexSelectedCell: Int) {
        if let indexPath = tableView.indexPath(for: cell) {
            LoadingIndicator.show(on: view)
            viewModel.selectParameter(indexPath.row, indexSelectedCell, searchBar.text)
            cell.updateSelectedItems(selectedParameters: viewModel.selectedItemParameterModels)
        }
    }
    
    func deselectCell(_ cell: SearchFilterTableViewCell, _ indexDeselectedCell: Int) {
        if let indexPath = tableView.indexPath(for: cell) {
            LoadingIndicator.show(on: view)
            viewModel.deselectParameter(indexPath.row, indexDeselectedCell, searchBar.text)
            cell.updateSelectedItems(selectedParameters: viewModel.selectedItemParameterModels)
        }
    }
}

extension SearchViewController: LookCollectionCellDelegate, LookViewControllerDelegate {
    func addAlbum(cell: LookCollectionCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let lookModel = viewModel.lookModels[indexPath.row]
            addAlbumWithHelper(selectedLook: lookModel, looks: viewModel.lookModels, image: cell.imageView.image ?? UIImage(), viewController: navigationController ?? self)
        }
        
    }
    
    func addCalendar(cell: LookCollectionCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let lookModel = viewModel.lookModels[indexPath.row]
            addCalendarWithHelper(selectedLook: lookModel, looks: viewModel.lookModels, image: cell.imageView.image ?? UIImage(), viewController: navigationController ?? self)
        }
    }
    
    func share(cell: LookCollectionCell) {
        
    }
    
    func loadMore() {
        loadingMore()
    }
    
    func dismiss() {
        lookDetailViewModel = nil
    }
}
 

