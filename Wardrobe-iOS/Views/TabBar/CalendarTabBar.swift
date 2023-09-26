//
//  CalendarTabBar.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/2/20.
//

import UIKit
import JTAppleCalendar

@objc protocol CalendarTabBarDelete: class {
    func didSetToday()
    func setMonthTitle(_ month: String)
    func selectDate(_ date: Date)
}

class CalendarTabBar: UIView {
    private let cornerRadius: CGFloat = 30
    private let formatter = DateFormatter()
    private var selectedDates = [Date]()
    private var type: CalendarViewType = .calendar
    private var firstTime: Bool = true
    weak var delegate: CalendarTabBarDelete?
    var viewModel: CalendarEventViewModel!
    var selectedCell: CalendaryWeakDayCell?
    lazy var selectedDayButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.contentHorizontalAlignment = .left
        button.setTitleColor(SCColors.titleColor, for: .normal)
        button.addTarget(self, action: #selector(todayButtonClick), for: .touchUpInside)
        addSubview(button)
        return button
    }()
    
    lazy var weakCollectionView: JTACMonthView = {
        let collection = JTACMonthView()
        collection.calendarDelegate = self
        collection.calendarDataSource = self
        collection.showsHorizontalScrollIndicator = false
        collection.isPagingEnabled = true
        collection.minimumInteritemSpacing = 0
        collection.minimumLineSpacing = 0
        collection.cellSize = self.bounds.width / 7
        collection.backgroundColor = SCColors.whiteColor
        collection.scrollDirection = .horizontal
        collection.isHidden = true
        collection.register(cell: CalendaryWeakDayCell.self)
        addSubview(collection)
        return collection
    }()
    
    //MARK:- Shadow view
    lazy var mainView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.addShadow()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var contentsLayer: UIView = {
        let view = UIView()
        view.backgroundColor = SCColors.whiteColor
        view.layer.cornerRadius = cornerRadius
        view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func setTodayDayTitle(_ text: String) {
        selectedDayButton.setTitle(text, for: .normal)
    }
    
    func setSelectedDate(_ date: Date) {
        formatter.dateFormat = "MMM"
        formatter.locale = Locale(identifier: LanguageManager.manager.currentLanguge().key)
        delegate?.setMonthTitle(formatter.string(from: date).capitalized)
        weakCollectionView.scrollToDate(firstDayOfWeek(date), animateScroll: false)
        weakCollectionView.selectDates([date], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: false)
        selectedDates.removeAll()
        selectedDates.append(date)
        weakCollectionView.reloadData()
    }
    
    func updateWeakCollection() {
        weakCollectionView.reloadData()
    }
    
    func setType(_ type: CalendarViewType) {
        self.type = type
        if type == .calendar {
            weakCollectionView.isHidden = true
            selectedDayButton.isHidden = false
        } else {
            weakCollectionView.isHidden = false
            selectedDayButton.isHidden = true
        }
    }
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    //MARK:- Overided functions
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addShadowConstarint()
    }
    
    private func commonInit() {
        backgroundColor = SCColors.whiteColor
        addConstraints()
        setupShadow()
    }
}

//MARK:- Button action
extension CalendarTabBar {
    @objc private func todayButtonClick() {
        delegate?.didSetToday()
    }
}

//MARK:- Constraint
extension CalendarTabBar {
    
    private func setupShadow() {
        addSubview(mainView)
        mainView.addSubview(contentsLayer)
        sendSubviewToBack(mainView)
    }
    
    private func addShadowConstarint() {
        var height: CGFloat = 50
        if type != .calendar {
            height = 95
        }
        
        mainView.removeConstraints(mainView.constraints)
        NSLayoutConstraint.activate([
            mainView.centerYAnchor.constraint(equalTo: centerYAnchor),
            mainView.centerXAnchor.constraint(equalTo: centerXAnchor),
            mainView.heightAnchor.constraint(equalToConstant: height),
            mainView.widthAnchor.constraint(equalToConstant:frame.width),
            contentsLayer.centerYAnchor.constraint(equalTo: mainView.centerYAnchor),
            contentsLayer.centerXAnchor.constraint(equalTo: mainView.centerXAnchor),
            contentsLayer.heightAnchor.constraint(equalTo: mainView.heightAnchor),
            contentsLayer.widthAnchor.constraint(equalTo: mainView.widthAnchor)
        ])
        
        if firstTime {
            firstTime = false
            return
        }
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }
    
    private func addConstraints() {
        selectedDayButton.translatesAutoresizingMaskIntoConstraints = false
        weakCollectionView.translatesAutoresizingMaskIntoConstraints = false
        selectedDayButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        selectedDayButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        selectedDayButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -21).isActive = true
        weakCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        weakCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
       // weakCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        weakCollectionView.heightAnchor.constraint(equalToConstant: 72).isActive = true
        weakCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -23).isActive = true
    }
}

//MARK:- JTACMonthViewDelegate, JTACMonthViewDataSource
extension CalendarTabBar: JTACMonthViewDelegate, JTACMonthViewDataSource {
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
    }
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendaryWeakDayCell", for: indexPath) as! CalendaryWeakDayCell
        let eventsCount = viewModel.countOfEvents(date)
        let isWeekend = cellState.day == DaysOfWeek.sunday || cellState.day == DaysOfWeek.saturday
        cell.configure(cellState.text, getWeeKText(day: cellState.day), isWeekend, eventsCount, isSelected: selectedDates.contains(date))
        return cell
    }
    
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale   = Locale(identifier: "en-EN")
        let startDate = formatter.date(from: "2020 01 01")!
        let endDate = formatter.date(from: "2025 12 31")!
        let params = ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 1,
        generateInDates: .forFirstMonthOnly,
        generateOutDates: .off, firstDayOfWeek: .monday,
        hasStrictBoundaries: false)
        return params
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        if let cell = cell as? CalendaryWeakDayCell {
            cell.select()
            selectedCell = cell
        }
        selectedDates.append(date)
        delegate?.selectDate(date)
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        if let index = selectedDates.firstIndex(of: date) {
            selectedDates.remove(at: index)
        }
        
        if let cell = cell as? CalendaryWeakDayCell {
            cell.deselect()
        } else {
            selectedCell?.deselect()
        }
    }
    
    func calendar(_ calendar: JTACMonthView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first?.date
        formatter.dateFormat = "MMM"
        if let date = date {
            delegate?.setMonthTitle(formatter.string(from: date))
        }
    }
    
    private func getWeeKText(day: DaysOfWeek) -> String {
        switch day {
        case .monday:
            return "M"
        case .sunday:
            return "S"
        case .tuesday:
            return "T"
        case .wednesday:
            return "W"
        case .thursday:
            return "T"
        case .friday:
            return "F"
        case .saturday:
            return "S"
        }
    }
    
    private func firstDayOfWeek(_ date: Date) -> Date {
        let weekDay = Calendar.current.component(.weekday, from: date)
        if weekDay == 2 { return date }
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = calendar.date(from: calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: date))!
        return date
    }
}
