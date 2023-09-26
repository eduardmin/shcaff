//
//  AlbumsViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/21/20.
//

import UIKit

enum AlbumType {
    case normal
    case calendar
    case set
    case event
}

class AlbumsViewController: BaseNavigationViewController {

    private let viewModel = AlbumsViewModel()
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.register(cell: ClothesTableViewCell.self)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true

        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.tabBarHeight, right: 0)
        return tableView
    }()
    
    lazy var createLookButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create Album".localize(), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.addTarget(self, action: #selector(createAlbumAction), for: .touchUpInside)
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36).isActive = true
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36).isActive = true
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        button.heightAnchor.constraint(equalToConstant:50).isActive = true
        return button
    }()
    
    var type: AlbumType = .normal
    var albumCompletion: ((AlbumModel) -> ())?
    var eventCompletion: ((SetModel) -> ())?
    var calendarDate: Double?
    var plusView: PlusView?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.completion = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.showHideEmptyView(isHide: strongSelf.viewModel.albumCount() != 0)
            strongSelf.tableView.reloadData()
        }
        configureUI()
        addObserver()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateSets), name: NSNotification.Name(rawValue: NotificationName.updateSets), object: nil)
    }

    
    private func configureUI() {
        tableView.delegate = self
        tableView.dataSource = self
        addEmptyView(title: "It seems that you deleted all your albums".localize(), description: "Click to the + button to create one.".localize())
        if type == .calendar || type == .set || type == .event {
            setNavigationView(type: .defaultWithCancel, attibuteTitle: getNavigationTitle("Choose".localize(), "The Album".localize()))
        }
        showHideEmptyView(isHide: viewModel.albumCount() != 0)
        createLookButton.setMode(.background, color: SCColors.whiteColor)
        createLookButton.isHidden = type == .normal
        tableView.register(cell: AlbumTableViewCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        plusView?.delegate = self
        plusView?.stateIsChange = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        plusView?.stateIsChange = true
    }
    
    override func didSelectNavigationAction(action: NavigationAction) {
        switch action {
        case .back:
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
    
    @objc func updateSets() {
        tableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource
extension AlbumsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.albumCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(AlbumTableViewCell.self) as AlbumTableViewCell
        let albumModel = viewModel.getAlbum(index: indexPath.row)
        cell.configure(albumModel)
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let albumModel = viewModel.getAlbum(index: indexPath.row)
        if type == .set {
            albumCompletion?(albumModel)
            dismiss(animated: true, completion: nil)
            return
        }
        let albumItemViewController = AlbumItemViewController.initFromStoryboard(storyBoardName: StoryboardName.wardrobe) as AlbumItemViewController
        albumItemViewController.albumModel = albumModel
        albumItemViewController.calendarDate = calendarDate
        albumItemViewController.eventCompletion = eventCompletion
        navigationController?.pushViewController(albumItemViewController, animated: true)
    }
}
 
//MARK:- AlbumTableViewCellDelegate
extension AlbumsViewController: AlbumTableViewCellDelegate {
    func editAlbum(_ cell: AlbumTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let albumModel = viewModel.getAlbum(index: indexPath.row)
            let textFieldAlert = AlertPresenter.presentTextFieldAlert(on: self, defaultText: albumModel.name, title: "Edit Album".localize(), infoText: "Name".localize(), confirmButtonTitle: "Save".localize(), cancelButtonTitle: "Cancel".localize())
            textFieldAlert.confirmButtonHandler = { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.changeAlbumName(title: textFieldAlert.inputText, index: indexPath.row)
                textFieldAlert.dismissViewController()
            }
        }
    }
    
    func deleteAlbum(_ cell: AlbumTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let albumModel = viewModel.getAlbum(index: indexPath.row)
            AlertPresenter.presentInfoAlert(on: self, type: .deleteAlbum(albumModel.name), confirmButtonCompletion:  { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.deleteAlbum(index: indexPath.row)
            })
        }
    }
}

//MARK:- PlusViewDelegate
extension AlbumsViewController: PlusViewDelegate {
    func plusAction() {
        createAlbum()
    }
    
    @objc func createAlbumAction() {
        createAlbum()
    }
    
    func createAlbum() {
        let textFieldAlert = AlertPresenter.presentTextFieldAlert(on: self, title: "Create Album".localize(), infoText: "Name".localize(), confirmButtonTitle: "Create".localize(), cancelButtonTitle: "Cancel".localize())
        textFieldAlert.confirmButtonHandler = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.createAlbum(title: textFieldAlert.inputText)
            textFieldAlert.dismissViewController()
        }
    }
}

//MARK:- Send Request
extension AlbumsViewController {
    private func createAlbum(title: String) {
        viewModel.createAlbum(title)
    }
    
    private func changeAlbumName(title: String, index: Int) {
        viewModel.changeAlbumName(title, index)
    }
    
    private func deleteAlbum(index: Int) {
        viewModel.deleteAlbum(index)
    }
}
