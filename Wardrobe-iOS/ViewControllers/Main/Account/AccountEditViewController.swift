//
//  AccountEditViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/13/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

enum ProfileSection: Int{
    case profile
    case question
}

enum ProfileType: Int {
    case name
    case lastName
    case email
    case birthday
    case male
    case female
    case other
    case otherMale
    case otherFemale
    case both
    static let titles: [ProfileType: String] = [.name: "First name", .lastName: "Last name", .email: "Email", .birthday: "Birthday", .male: "Gender"]
}

enum QuestionType: Int {
    case goal
    case style
    static let titles: [QuestionType: String] = [.goal: "Your Goal", .style: "Your Style"]
}


class AccountEditViewController: BaseNavigationViewController {
    @IBOutlet weak var avatarView: AvatarImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var avatarHeightConstraint: NSLayoutConstraint!
    private let viewModel = AccountEditViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        viewModel.completion = { [weak self] type in
            guard let strongSelf = self else { return }
            switch type {
            case .start(showLoading: let showLoading):
                strongSelf.start(showLoading: showLoading)
            case .fail(showPopup: let showPopup):
                strongSelf.fail(showPopup: showPopup)
            case .success(response: let response):
                strongSelf.success(response: response)
            }
        }
        hideKeyboardWhenTappedAround()
    }
    
    override func didSelectNavigationAction(action: NavigationAction) {
        switch action {
        case .back:
            navigationController?.popViewController(animated: true)
        case .edit:
            viewModel.saveProfile()
            break
        default:
            break
        }
    }
    
    @IBAction func changeAvatarAction(_ sender: Any) {
        let takePhotoViewController: TakePhotoViewController = TakePhotoViewController.initFromStoryboard(storyBoardName: StoryboardName.wardrobe)
        takePhotoViewController.type = .update
        takePhotoViewController.updateCompletion = { [weak self] imageData in
            guard let strongSelf = self else { return }
            strongSelf.rightMode = .active
            strongSelf.viewModel.setImageData(imageData: imageData)
            strongSelf.updateAvatarImage()
        }
        takePhotoViewController.modalPresentationStyle = .fullScreen
        present(takePhotoViewController, animated: true, completion: nil)
    }
    
    //MARK:- UI
    func configureUI() {
        setNavigationView(type: .editType, title: "Edit Account".localize(), additionalTopMargin: 16, "Save".localize())
        rightMode = .passive
        updateAvatarImage()
        changeButton.setTitle("Change".localize(), for: .normal)
        tableView.separatorStyle = .none
        tableView.backgroundColor = SCColors.tableColor
        tableView.allowsSelection = true
        tableView.register(cell: ProfileTextFieldTableViewCell.self)
        tableView.register(cell: ProfileBirthDayTableViewCell.self)
        tableView.register(cell: ProfileGenderTableViewCell.self)
        tableView.register(cell: InfoTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func updateAvatarImage() {
        if let data = viewModel.getImageData() {
            let image = UIImage(data: data)
            avatarHeightConstraint.constant = image != nil ? 80 : 48
            view.layoutIfNeeded()
            avatarView.updateImage(image)
        } else {
            avatarHeightConstraint.constant = 48
            avatarView.updateImage(nil)
        }
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource
extension AccountEditViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ProfileSection.question.rawValue + 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == ProfileSection.profile.rawValue {
            return ProfileType.birthday.rawValue + 1
        }
        return QuestionType.style.rawValue + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == ProfileSection.profile.rawValue {
            let type = ProfileType(rawValue: indexPath.row)!
            switch type {
            case .name, .lastName, .email:
                let cell: ProfileTextFieldTableViewCell = tableView.dequeueReusableCell(ProfileTextFieldTableViewCell.self)
                cell.configure(title: ProfileType.titles[type] ?? "", input: viewModel.getInput(type: type), type: type)
                cell.delegate = self
                cell.selectionStyle = .none
                return cell
            case .birthday:
                let cell: ProfileBirthDayTableViewCell = tableView.dequeueReusableCell(ProfileBirthDayTableViewCell.self)
                cell.configure(title: ProfileType.titles[type] ?? "", input: viewModel.getDateInput(), type: type, popapSuperView: view)
                cell.delegate = self
                cell.selectionStyle = .none
                return cell
            case .male, .female, .other, .otherMale, .otherFemale, .both:
                let cell: ProfileGenderTableViewCell = tableView.dequeueReusableCell(ProfileGenderTableViewCell.self)
                cell.configure(title: ProfileType.titles[type], type: type, select: viewModel.selectGender(type: type))
                return cell
            }
        } else {
            let cell: InfoTableViewCell = tableView.dequeueReusableCell(InfoTableViewCell.self)
            let type = QuestionType(rawValue: indexPath.row)!
            cell.configureAllSeperator(info: QuestionType.titles[type]!)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == ProfileSection.profile.rawValue {
            let type = ProfileType(rawValue: indexPath.row)!
            switch type {
            case .name, .lastName, .email, .birthday:
                return 115
            case .male:
                return 106
            case .female, .other, .otherMale, .otherFemale, .both:
                return 70
            }
        } else {
            return 66
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section ==  ProfileSection.question.rawValue {
            return 20
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == ProfileSection.question.rawValue {
            return UIView()
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == ProfileSection.question.rawValue {
            if indexPath.row == QuestionType.style.rawValue {
                let styleViewController: StyleViewController = StyleViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
                styleViewController.viewModel.type = .account
                styleViewController.completion = { [weak self] viewModel in
                    self?.viewModel.styleViewModel = viewModel
                    self?.rightMode = .active
                }
                navigationController?.pushViewController(styleViewController, animated: true)
            } else if indexPath.row == QuestionType.goal.rawValue {
                let goalViewController: GoalViewController = GoalViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
                goalViewController.viewModel.type = .account
                goalViewController.completion = { [weak self] viewModel in
                    self?.viewModel.goalViewModel = viewModel
                    self?.rightMode = .active
                }
                navigationController?.pushViewController(goalViewController, animated: true)
            }
        }
    }
}

//MARK:- Cell delegate
extension AccountEditViewController: ProfileTextFieldTableViewCellDelegate, ProfileBirthDayTableViewCellDelegate {
    func setInput(date: Date?, type: ProfileType) {
        rightMode = .active
        viewModel.setInput(type: type, input: date)
    }
    
    func setInput(input: String?, type: ProfileType) {
        rightMode = .active
        viewModel.setInput(type: type, input: input)
    }
}

//MARK:- RequestResponseProtocol
extension AccountEditViewController: RequestResponseProtocol {
    func start(showLoading: Bool) {
        LoadingIndicator.show(on: view)
    }
    
    func fail(showPopup: Bool) {
        AlertPresenter.presentRequestErrorAlert(on: self)
        LoadingIndicator.hide(from: view)
    }
    
    func success(response: Any?) {
        LoadingIndicator.hide(from: view)
        NotificationCenter.default.post(name: NSNotification.Name.init(NotificationName.updateProfile), object: nil, userInfo: nil)
     //   tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
}
