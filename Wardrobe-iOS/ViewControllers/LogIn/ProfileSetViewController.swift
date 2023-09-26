//
//  ProfileSetViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 7/29/20.
//

import UIKit

class ProfileSetViewController: UIViewController {
    
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthDayButton: UIButton!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    @IBOutlet weak var genderDescriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    private var birthDayDate: Date?
    private var gender: UserGender?
    private var otherGenderTitles = ["Male", "Female", "Both"]
    private var otherGenders = [UserGender.otherMale, UserGender.otherFemale, UserGender.both]
    let viewModel = ProfileSetViewModel()
    let settingsViewModel = SettingsViewModel()

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
        
        settingsViewModel.completion = { [weak self] type in
            guard let strongSelf = self else { return }
            switch type {
            case .start(showLoading: let showLoading):
                strongSelf.start(showLoading: showLoading)
            case .fail(showPopup: let showPopup):
                strongSelf.fail(showPopup: showPopup)
            case .success(response: let response):
                strongSelf.logoutHandle()
            }
        }
    }
    
    private func configureUI() {
        titleLabel.attributedText = getNavigationTitle("Age".localize(), "& Gender".localize())
        birthDayButton.layer.cornerRadius = birthDayButton.bounds.height / 2
        birthDayButton.layer.borderWidth = 1
        birthDayButton.layer.borderColor = SCColors.textfieldBorderColor.cgColor
        birthDayButton.setTitle("dd / mm / yyyy".localize(), for: .normal)
        birthdayLabel.text = "Birthday".localize()
        genderLabel.text = "Gender".localize()
        maleButton.layer.cornerRadius = maleButton.bounds.height / 2
        maleButton.layer.borderWidth = 1
        maleButton.layer.borderColor = SCColors.textfieldBorderColor.cgColor
        maleButton.setTitle("Male".localize(), for: .normal)
        femaleButton.layer.cornerRadius = femaleButton.bounds.height / 2
        femaleButton.layer.borderWidth = 1
        femaleButton.layer.borderColor = SCColors.textfieldBorderColor.cgColor
        femaleButton.setTitle("Female".localize(), for: .normal)
        otherButton.layer.cornerRadius = femaleButton.bounds.height / 2
        otherButton.layer.borderWidth = 1
        otherButton.layer.borderColor = SCColors.textfieldBorderColor.cgColor
        otherButton.setTitle("Other".localize(), for: .normal)
        genderDescriptionLabel.text = "Shcaff should suggest you clothes of".localize()
        continueButton.setMode(.background, color: SCColors.whiteColor, backgroundColor: SCColors.mainColor)
        continueButton.setTitle("Continue".localize(), for: .normal)
        showhideOthersButton(true)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cell: ProfileTableViewCell.self)
    }
        
    private func setGenderButtonSelect(button : UIButton, otherButtons: [UIButton]) {
        button.setMode(.background, color:SCColors.whiteColor, backgroundColor: SCColors.secondaryColor, shadow: false)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        for otherButton in otherButtons {
            otherButton.layer.borderWidth = 1
            otherButton.layer.borderColor = SCColors.textfieldBorderColor.cgColor
            otherButton.backgroundColor = SCColors.whiteColor
            otherButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            otherButton.setTitleColor(SCColors.titleColor, for: .normal)
        }
    }
    
    private func showhideOthersButton(_ hide: Bool) {
        if hide {
            tableView.isHidden = true
            genderDescriptionLabel.isHidden = true
        } else {
            tableView.isHidden = false
            genderDescriptionLabel.isHidden = false
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        AlertPresenter.presentInfoAlert(on: self, type: .logout, confirmButtonCompletion:  { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.settingsViewModel.logout()
        })
    }
}

//MARK:- RequestResponseProtocol
extension ProfileSetViewController: RequestResponseProtocol {
    func start(showLoading: Bool) {
        LoadingIndicator.show(on: view)
    }
    
    func fail(showPopup: Bool) {
        AlertPresenter.presentRequestErrorAlert(on: self)
        LoadingIndicator.hide(from: view)
    }
    
    func success(response: Any?) {
        LoadingIndicator.hide(from: view)
        UserDefaults.standard.set(true, forKey: UserDefaultsKey.profile)
        let goalViewController = GoalViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
        navigationController?.pushViewController(goalViewController, animated: true)
    }
    
    func logoutHandle() {
        navigationController?.popViewController(animated: true)
    }
}

//MARK:- Button Action
extension ProfileSetViewController {
    @IBAction func birthDayClick(_ sender: Any) {
        let selectionView = DatePickerView.instanceFromNib()
        if let hostView = tabBarController?.view ?? self.navigationController?.view {
            selectionView.delegate = self
            selectionView.frame = hostView.bounds
            hostView.addSubview(selectionView)
            selectionView.appearOnView(hostView)
        }
    }
    
    @IBAction func maleClick(_ sender: Any) {
        showhideOthersButton(true)
        setGenderButtonSelect(button: maleButton, otherButtons: [femaleButton, otherButton])
        gender = .male
    }
    
    @IBAction func femaleClick(_ sender: Any) {
        showhideOthersButton(true)
        setGenderButtonSelect(button: femaleButton, otherButtons: [maleButton, otherButton])
        gender = .female
    }
    
    @IBAction func otherClick(_ sender: Any) {
        setGenderButtonSelect(button: otherButton, otherButtons: [maleButton, femaleButton])
        showhideOthersButton(false)
        gender = nil
    }
    
    @IBAction func otherMaleClick(_ sender: Any) {
        gender = .otherMale
       // setGenderButtonSelect(button: otherMaleButton, otherButtons: [otherFemaleButton, otherBothButton])
    }
    
    @IBAction func otherFemaleClick(_ sender: Any) {
        gender = .otherFemale
       // setGenderButtonSelect(button: otherFemaleButton, otherButtons: [otherMaleButton, otherBothButton])
    }
    
    @IBAction func otherBothClick(_ sender: Any) {
        gender = .both
       // setGenderButtonSelect(button: otherBothButton, otherButtons: [otherFemaleButton, otherMaleButton])
    }
    
    @IBAction func continueClick(_ sender: Any) {
        sendSetProfile()
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource
extension ProfileSetViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return otherGenderTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProfileTableViewCell = tableView.dequeueReusableCell(ProfileTableViewCell.self)
        let title = otherGenderTitles[indexPath.row]
        cell.configure(title)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: ProfileTableViewCell = tableView.cellForRow(at: indexPath) as! ProfileTableViewCell
        cell.select()
        gender = otherGenders[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell: ProfileTableViewCell = tableView.cellForRow(at: indexPath) as! ProfileTableViewCell
        cell.deselect()
    }
}

//MARK:- Profile send request
extension ProfileSetViewController {
    func sendSetProfile() {
        if let date = birthDayDate?.timeIntervalSince1970, let gender = gender {
            viewModel.setUserProfile(date, gender: gender)
        }
    }
}

//MARK:- DatePickerViewDelegate
extension ProfileSetViewController: DatePickerViewDelegate {
    func setDate(date: Date) {
        birthDayDate = date
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: LanguageManager.manager.currentLanguge().key)
        dateFormatter.dateFormat = "dd/MM/yyyy"
        birthDayButton.setTitle(dateFormatter.string(from: date), for: .normal)
        birthDayButton.setTitleColor(SCColors.titleColor, for: .normal)
        birthDayButton.layer.borderColor = SCColors.titleColor.cgColor
    }
}
