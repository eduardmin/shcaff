//
//  CalendarViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/1/20.
//

import UIKit
import JTAppleCalendar

enum CalendarNavigationType {
    case `default`
    case selectDate
}

enum CalendarViewType {
    case calendar
    case look
}

class CalendarViewController: CalendarTabViewController {
    private let leftRightMargin: CGFloat = 36
    private let itemPadding: CGFloat = 10
    private let setCellHeight: CGFloat = 105
    private let lookCellHeight: CGFloat = 125

    @IBOutlet weak var monthCollectionView: JTACMonthView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addEventButton: UIButton!
    private let formatter = DateFormatter()
    private let today = Date()
    var navigationType: CalendarNavigationType = .default

//MARK:- override func
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
        viewModel.completion = { [weak self] success in
            guard let strongSelf = self else { return }
            if success {
                strongSelf.reload()
            }
        }
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.updateEvents()
    }
    
    override func didSelectNavigationAction(action: NavigationAction) {
        switch action {
        case .back:
            if navigationType == .default {
                setCalendateType()
            } else {
                dismiss(animated: true, completion: nil)
            }
        case .today:
            monthCollectionView.scrollToHeaderForDate(today, withAnimation: true)
        default:
            break
        }
    }
    
    override func selectDate(_ date: Date) {
        selectedDate = date
        collectionView.reloadData()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateEvents), name: NSNotification.Name(rawValue: NotificationName.updateEvents), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateWeather), name: NSNotification.Name(rawValue: NotificationName.updateWeather), object: nil)
    }
    
    func configureUI() {
        view.backgroundColor = SCColors.whiteColor
        setTitle()
        monthCollectionView.register(cell: CalendaryDayCell.self)
        monthCollectionView.register(UINib(nibName: "MonthReusableView", bundle: Bundle.main),
                                     forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                     withReuseIdentifier: "MonthReusableView")
        monthCollectionView.minimumInteritemSpacing = 0
        monthCollectionView.minimumLineSpacing = 0
        monthCollectionView.cellSize = view.bounds.width / 7
        monthCollectionView.scrollToHeaderForDate(today, withAnimation: false)
        addEventButton.layer.cornerRadius = addEventButton.bounds.height / 2
        collectionView.register(cell: CalendarSetCollectionViewCell.self)
        collectionView.register(cell: CalendarLookCollectionViewCell.self)
        collectionView.updateInsets(horizontal: 0, vertical: 0, interItem: 15, interRow: 15)
    }
    
    private func setTitle(_ date: Date = Date()) {
        formatter.dateFormat = "yyyy"
        formatter.locale = Locale(identifier: LanguageManager.manager.currentLanguge().key)
        if type == .calendar {
            if navigationType == .default {
                setNavigationView(type: .defaultWithWeather, title: formatter.string(from: date).capitalized)
            } else {
                setNavigationView(type: .defaultWithWeatherCancel, title: formatter.string(from: date).capitalized)
            }
            if let model = viewModel.getWeatherModel() {
                let attributedString = createAttributedWithWeather(model)
                weatherText = attributedString
            }
        } else {
            setNavigationView(type: .defaultWithWeatherBack, title: formatter.string(from: date).capitalized)
        }
        
        formatter.dateFormat = "dd MMM, EEEE"
        formatter.locale = Locale(identifier: LanguageManager.manager.currentLanguge().key)
        setCalendarTabBar("Today".localize() + ", " + formatter.string(from: date).capitalized)
        if let weatherModel = viewModel.getWeatherModel() {
            handleWeather(weatherModel)
        }
    }
    
    @objc private func updateEvents() {
        viewModel.updateEvents()
    }
    
    @objc func updateWeather() {
        if let weatherModel = viewModel.getWeatherModel() {
            handleWeather(weatherModel)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK:- Button Action
extension CalendarViewController {
    @IBAction func addEventClick(_ sender: Any) {
        let album = AlbumsViewController()
        album.type = .calendar
        album.calendarDate = selectedDate.timeIntervalSince1970
        let navigation = UINavigationController(rootViewController: album)
        navigation.navigationBar.isHidden = true
        navigation.modalPresentationStyle = .fullScreen
        navigationController?.present(navigation, animated: true, completion: nil)
    }
}

//MARK:- Public Function
extension CalendarViewController {
    public func selectEventWithNotification(model: NotificationModel) {
        let date = Date(timeIntervalSince1970: model.calendarEventModelModel?.correctDate ?? 0)
        setLookType(date)
    }
}

//MARK:- Private Function
extension CalendarViewController {
    private func setCalendateType() {
        type = .calendar
        collectionView.isHidden = true
        addEventButton.isHidden = true
        monthCollectionView.isHidden = false
        setTitle()
        monthCollectionView.reloadData()
    }
    
    private  func setLookType(_ date: Date) {
        type = .look
        collectionView.isHidden = false
        addEventButton.isHidden = false
        monthCollectionView.isHidden = true
        setTitle()
        selectTabDate(date: date)
        
        collectionView.reloadData()
    }
    
    private func handleWeather(_ weatherModel: WeatherModel) {
        let attributedString = createAttributedWithWeather(weatherModel)
        weatherText = attributedString
    }
    
    private func reload() {
        if type == .calendar {
            monthCollectionView.reloadData()
        } else {
            updateTab()
            collectionView.reloadData()
        }
    }
}

//MARK:- JTACMonthViewDelegate, JTACMonthViewDataSource
extension CalendarViewController: JTACMonthViewDelegate, JTACMonthViewDataSource {
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
    }
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendaryDayCell", for: indexPath) as! CalendaryDayCell
        if cellState.dateBelongsTo != .thisMonth {
            cell.isHidden = true
        } else {
            cell.isHidden = false
        }
        
        let eventsCount = viewModel.countOfEvents(date)
        let isWeekend = cellState.day == DaysOfWeek.sunday || cellState.day == DaysOfWeek.saturday
        cell.configure(cellState.text, Calendar.current.isDateInToday(date), isWeekend, eventsCount)
        return cell
    }
    
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: LanguageManager.manager.currentLanguge().key)
        let startDate = formatter.date(from: "2020 01 01")!
        let endDate = formatter.date(from: "2025 12 31")!
        let params = ConfigurationParameters(startDate: startDate, endDate: endDate, calendar: Calendar.current, generateInDates: .forAllMonths, generateOutDates: .off, firstDayOfWeek: .monday)
        return params
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        if navigationType == .default {
            setLookType(date)
        } else {
            let calendarEventCreateViewController = CalendarEventCreateViewController.initFromStoryboard() as CalendarEventCreateViewController
            if let setModel = viewModel.setModel {
                calendarEventCreateViewController.viewModel.setSetModel(setModel)
            }
            calendarEventCreateViewController.viewModel.setDate(date.timeIntervalSince1970)
            navigationController?.pushViewController(calendarEventCreateViewController, animated: true)
        }
    }
    
    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        let timezoneOffset =  TimeZone.current.secondsFromGMT()
        let timeInterval = range.start.timeIntervalSince1970 + Double(timezoneOffset)
        let date = Date(timeIntervalSince1970: TimeInterval(timeInterval))
        formatter.dateFormat = "MMM"
        formatter.locale = Locale(identifier: LanguageManager.manager.currentLanguge().key)
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "MonthReusableView", for: indexPath) as! MonthReusableView
        header.configureMonth(formatter.string(from: date).capitalized)
        return header
    }
    
    func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize? {
        return MonthSize(defaultSize: 155)
    }
    
    func calendar(_ calendar: JTACMonthView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        formatter.dateFormat = "yyyy"
        formatter.locale = Locale(identifier: LanguageManager.manager.currentLanguge().key)
        navigationTitle = formatter.string(from: date).capitalized
    }
}

//MARK:- UICollectionViewDataSource, UICollectionViewDelegate,
extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.countOfEvents(selectedDate)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let eventModel = viewModel.getEvent(indexPath.row, selectedDate)
        if eventModel?.setModel?.lookId != nil {
            let cell = collectionView.dequeueReusableCell(CalendarLookCollectionViewCell.self, indexPath: indexPath) as! CalendarLookCollectionViewCell
            cell.delegate = self
            if let model = eventModel {
                cell.configure(model)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(CalendarSetCollectionViewCell.self, indexPath: indexPath) as! CalendarSetCollectionViewCell
            cell.delegate = self
            if let model = eventModel {
                cell.configure(model)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 0
        let eventModel = viewModel.getEvent(indexPath.row, selectedDate)
        if eventModel?.setModel?.lookId != nil {
            height = lookCellHeight
            let item = (UIScreen.main.bounds.width / 5)
            height += 2 * ( item + itemPadding)
        } else {
            height = setCellHeight
            let item = (UIScreen.main.bounds.width - 2 * leftRightMargin  - 3 * itemPadding) / 4
            height += item
            if eventModel?.setModel?.itemModels?.count ?? 0 > 4 {
                height += item + itemPadding
            }
        }
        return CGSize(width: view.bounds.width, height: height)
    }
}

//MARK:- CalendarSetCollectionViewCellDelegate
extension CalendarViewController: CalendarSetCollectionViewCellDelegate, CalendarLookCollectionViewCellDelegate {
    func deleteAction(cell: CalendarLookCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        deleteAction(indexPath: indexPath)
    }
    
    func editAction(cell: CalendarLookCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        editAction(indexPath: indexPath)
    }
    
    func deleteAction(cell: CalendarSetCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        deleteAction(indexPath: indexPath)
    }
    
    func editAction(cell: CalendarSetCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        editAction(indexPath: indexPath)
    }
    
    private func editAction(indexPath: IndexPath) {
        guard let eventModel = viewModel.getEvent(indexPath.row, selectedDate) else { return }
        let calendarEventCreateViewController = CalendarEventCreateViewController.initFromStoryboard() as CalendarEventCreateViewController
        calendarEventCreateViewController.viewModel.setEventModel(eventModel)
        navigationController?.pushViewController(calendarEventCreateViewController, animated: true)
    }
    
    private func deleteAction(indexPath: IndexPath) {
        guard let eventModel = viewModel.getEvent(indexPath.row, selectedDate) else { return }
        AlertPresenter.presentInfoAlert(on: self, type: .deleteEvent(eventModel.name ?? ""), confirmButtonCompletion:  { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.deleteEvent(model: eventModel)
        })
    }
}

