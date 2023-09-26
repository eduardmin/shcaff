//
//  CustomTabViewA.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 5/30/20.
//

import UIKit

protocol CustomTabViewDelegate : class {
    func handleTabBarClick(index : TabBarItemIndex)
}

enum TabBarItemIndex : Int {
    case home
    case search
    case wardrobe
    case calendar
}

struct TabBarItemModel {
    let title : String
    let image : String
    let selectedImage : String
}

class CustomTabView: UIView {
    
    @IBOutlet weak var radiusView: UIView!
    weak var delegate : CustomTabViewDelegate?
    private let leftRigthMargin : CGFloat = 20
    private let defaultWidth : CGFloat = 100
    private let selectedViewHeight : CGFloat = 40
    private let selectedViewTop : CGFloat = 7
    private var isFirst : Bool = true
    private  let itemModels : [TabBarItemIndex : TabBarItemModel] = [.home : TabBarItemModel(title: "Home", image: "home_item", selectedImage:"home_item"), .search : TabBarItemModel(title: "Search", image: "search_item", selectedImage:"search_item"), .wardrobe : TabBarItemModel(title: "Closet", image: "wardrobe_item", selectedImage:"wardrobe_item"), .calendar : TabBarItemModel(title: "Calendar", image: "calendar_item", selectedImage:"calendar_item")]
    
    public var selectedIndex : TabBarItemIndex = .home {
        didSet {
            if isFirst {
                self.selectItem()
                isFirst = false
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.selectItem()
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadow(false)
        radiusView.addSubview(selectedView)
        selectedIndex = .home
        addObserver()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged(notification:)), name: NSNotification.Name(rawValue: NotificationName.changeLanguage), object: nil)
    }
    
    @objc func languageChanged(notification:Notification)  {
        let items : [CustomTabBarItem] = [homeItem, searchItem, wardrobeItem, calendarItem]
        items.forEach { (item) in
            item.setModel(itemModel: itemModels[item.index]!)
        }
        selectItem()
    }
    
    lazy private var homeItem : CustomTabBarItem = {
        var item : CustomTabBarItem = CustomTabBarItem(frame: CGRect(x: 0, y: 0, width: defaultWidth, height: radiusView.frame.height))
        item.index = .home
        item.setModel(itemModel: itemModels[.home]!)
        item.delegate = self
        radiusView.addSubview(item)
        return item
    }()
    
    lazy private var searchItem : CustomTabBarItem = {
        var item : CustomTabBarItem = CustomTabBarItem(frame: CGRect(x: 0, y: 0, width: defaultWidth, height: radiusView.frame.height))
        item.index = .search
        item.delegate = self
        item.setModel(itemModel: itemModels[.search]!)
        radiusView.addSubview(item)
        return item
    }()
    
    lazy private var wardrobeItem : CustomTabBarItem = {
        var item : CustomTabBarItem = CustomTabBarItem(frame: CGRect(x: 0, y: 0, width: defaultWidth, height: radiusView.frame.height))
        item.index = .wardrobe
        item.delegate = self
        item.setModel(itemModel: itemModels[.wardrobe]!)
        radiusView.addSubview(item)
        return item
    }()
    
    lazy private var calendarItem : CustomTabBarItem = {
        var item : CustomTabBarItem = CustomTabBarItem(frame: CGRect(x: 0, y: 0, width: defaultWidth, height: radiusView.frame.height))
        item.index = .calendar
        item.delegate = self
        item.setModel(itemModel: itemModels[.calendar]!)
        radiusView.addSubview(item)
        return item
    }()
    
    lazy private var selectedView : UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 7, width: defaultWidth, height: selectedViewHeight))
        view.layer.cornerRadius = selectedViewHeight / 2
        view.backgroundColor = SCColors.secondaryGray
        
        return view
    }()
    
    class func instanceFromNib() -> CustomTabView {
        return UINib(nibName: "CustomTabView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CustomTabView
    }
    
    private func selectItem() {
        let items : [CustomTabBarItem] = [homeItem, searchItem, wardrobeItem, calendarItem]
        for item in items {
            if item.index == selectedIndex {
                item.select()
            } else {
                item.deselect()
            }
        }
        calculateItemSize()
    }
    
    //MARK:- Change size
    private func calculateItemSize() {
        let width = UIScreen.main.bounds.width
        var homeWidth  : CGFloat = 0
        var searchWidth  : CGFloat = 0
        var wardrobeWidth  : CGFloat = 0
        var calendarWidth  : CGFloat = 0
        
        switch selectedIndex {
        case .home:
            homeWidth = homeItem.selectedViewWidth + leftRigthMargin
            let itemWidth = (width - homeWidth - leftRigthMargin / 2) / 3
            searchWidth =  itemWidth
            wardrobeWidth = itemWidth
            calendarWidth = itemWidth + leftRigthMargin / 2
        case .search:
            searchWidth = searchItem.selectedViewWidth
            let itemWidth = (width - searchWidth - leftRigthMargin) / 3
            homeWidth = itemWidth + leftRigthMargin / 2
            wardrobeWidth = itemWidth
            calendarWidth = itemWidth + leftRigthMargin / 2
        case .wardrobe:
            wardrobeWidth = wardrobeItem.selectedViewWidth
            let itemWidth = (width - wardrobeWidth - leftRigthMargin) / 3
            homeWidth = itemWidth + leftRigthMargin / 2
            searchWidth = itemWidth
            calendarWidth = itemWidth + leftRigthMargin / 2
        case .calendar:
            calendarWidth = calendarItem.selectedViewWidth + leftRigthMargin
            let itemWidth = (width - calendarWidth - leftRigthMargin / 2) / 3
            homeWidth = itemWidth + leftRigthMargin / 2
            searchWidth = itemWidth
            wardrobeWidth = itemWidth
        }
        
        
        homeItem.setFrame(frame: CGRect(x: 0, y: 0, width: homeWidth, height: radiusView.frame.height))
        searchItem.setFrame(frame: CGRect(x: homeItem.frame.maxX, y: 0, width: searchWidth, height: radiusView.frame.height))
        wardrobeItem.setFrame(frame: CGRect(x: searchItem.frame.maxX, y: 0, width: wardrobeWidth, height: radiusView.frame.height))
        calendarItem.setFrame(frame: CGRect(x: wardrobeItem.frame.maxX, y: 0, width: calendarWidth, height: radiusView.frame.height))
        calculateSelectedViewSize()
        
    }
    
    func calculateSelectedViewSize() {
        switch selectedIndex {
        case .home:
            selectedView.frame = CGRect(x: homeItem.frame.minX + leftRigthMargin, y: selectedViewTop, width: homeItem.selectedViewWidth, height: selectedViewHeight)
        case .search:
            selectedView.frame = CGRect(x: searchItem.frame.minX, y: selectedViewTop, width: searchItem.selectedViewWidth, height: selectedViewHeight)
            
        case .wardrobe:
            selectedView.frame = CGRect(x: wardrobeItem.frame.minX, y: selectedViewTop, width: wardrobeItem.selectedViewWidth, height: selectedViewHeight)
            
        case .calendar:
            selectedView.frame = CGRect(x: calendarItem.frame.minX, y: selectedViewTop, width: calendarItem.selectedViewWidth, height: selectedViewHeight)
        }
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.radiusView.layer.masksToBounds = false
        self.radiusView.layer.cornerRadius = 30
    }
}

//MARK:- Item delegate

extension CustomTabView : CustomTabBarItemDelegate {
    func handleTabBarClick(index: TabBarItemIndex) {
        selectedIndex = index
        delegate?.handleTabBarClick(index: index)
    }
    
}
