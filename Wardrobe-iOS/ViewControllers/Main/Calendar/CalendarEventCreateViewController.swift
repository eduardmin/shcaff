//
//  CalendarEventCreateViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/29/20.
//

import UIKit

enum CalendarEventRow: Int {
    case look
    case name
    case category
}


class CalendarEventCreateViewController: BaseNavigationViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var acceptButton: UIButton!
    
    var viewModel = CalendarEventCreateViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func didSelectNavigationAction(action: NavigationAction) {
        switch action {
        case .back:
            navigationController?.popViewController(animated: true)
        default:
            break
        }
    }
    
    private func configureUI() {
        if viewModel.type == .create {
            setNavigationView(type: .defaultWithBack, attibuteTitle: getNavigationTitle("Make".localize(), "Event".localize()), additionalTopMargin: 16)
        } else {
            setNavigationView(type: .defaultWithBack, attibuteTitle: getNavigationTitle("Edit".localize(), "Event".localize()), additionalTopMargin: 16)
        }
        acceptButton.setTitle("Accept".localize(), for: .normal)
        acceptButton.setMode(.background, color: SCColors.whiteColor)
        checkAcceptButtonEnable()
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        tableView.register(cell: EventLookTableViewCell.self)
        tableView.register(cell: EventNameTableViewCell.self)
        tableView.register(cell: EventCategoryTableViewCell.self)
        hideKeyboardWhenTappedAround()
    }
    
    private func checkAcceptButtonEnable() {
        acceptButton.enableButton(enable: viewModel.isEnable())
    }
}

//MARK:- Button Action
extension CalendarEventCreateViewController {
    @IBAction func acceptAction(_ sender: Any) {
        viewModel.saveCalendarEvent()
        NotificationCenter.default.post(name: NSNotification.Name.init(NotificationName.updateEvents), object: nil, userInfo: nil)
        if viewModel.type == .create {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
        EventLogger.logEvent("Calendar Event Save")
    }
}

extension CalendarEventCreateViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CalendarEventRow.category.rawValue + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case CalendarEventRow.look.rawValue:
            let cell = tableView.dequeueReusableCell(EventLookTableViewCell.self) as EventLookTableViewCell
            cell.delegate = self
            if let setModel = viewModel.getSetModel() {
                cell.configure(setModel, isEdit: viewModel.type == .edit)
            }
            return cell
        case CalendarEventRow.name.rawValue:
            let cell = tableView.dequeueReusableCell(EventNameTableViewCell.self) as EventNameTableViewCell
            cell.configure(viewModel.getName())
            cell.delegate = self
            return cell
        case CalendarEventRow.category.rawValue:
            let cell = tableView.dequeueReusableCell(EventCategoryTableViewCell.self) as EventCategoryTableViewCell
            cell.configure(eventTypes: viewModel.eventTypeModels, selectedId: viewModel.getEventId())
            cell.delegate = self
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == CalendarEventRow.look.rawValue {
            if let setModel = viewModel.getSetModel() {
                return round(setModel.multipleHeight * 166) + 45
            }
            return 0
        } else {
            return UITableView.automaticDimension
        }
    }
}

//MARK:- Cells delegate
extension CalendarEventCreateViewController: EventNameTableViewCellDelegate, EventCategoryTableViewCellDelegate, EventLookTableViewCellDelegate {
    func changeAction() {
        let album = AlbumsViewController()
        album.type = .event
        album.eventCompletion = { [weak self] setModel in
            album.dismiss(animated: true, completion: nil)
            guard let strongSelf = self else { return }
            strongSelf.viewModel.setSetModel(setModel)
            strongSelf.checkAcceptButtonEnable()
            strongSelf.tableView.reloadData()
        }
        let navigation = UINavigationController(rootViewController: album)
        navigation.navigationBar.isHidden = true
        navigation.modalPresentationStyle = .fullScreen
        navigationController?.present(navigation, animated: true, completion: nil)
    }
    
    func selectCategory(_ id: Int64) {
        viewModel.setEventTypeId(id)
        checkAcceptButtonEnable()
    }
    
    func addTitle(_ text: String) {
        viewModel.setName(text)
        checkAcceptButtonEnable()
    }
}
