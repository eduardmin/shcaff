//
//  SCTabBar.swift
//  TabBar
//
//  Created by Mariam on 5/22/20.
//  Copyright © 2020 Mariam. All rights reserved.
//

import UIKit

protocol SCTabBarDelegate: class {
    func scTabBar(tabBar: SCTabBar, didSelectItemAt index: Int)
}

class SCTabBar: UIView {
    //MARK:- Constants
    private let inset: CGFloat = 34
    private let cornerRadius: CGFloat = 30
    private let viewInset: CGFloat = 20
    private let viewHeight: CGFloat = 3
    private let viewWidth: CGFloat = 20

    //MARK:- Public properties
    public weak var delegate: SCTabBarDelegate?
    public var tabBarSelectedTintColor: UIColor! { didSet { updateItemsColors() } }
    public var tabBarUnselectedTintColor: UIColor! { didSet { updateItemsColors() } }
    public var tabBarBackgroundColor: UIColor!  { didSet { backgroundColor = tabBarBackgroundColor } }

    //MARK:- Private properties
    private var selectedIndex: Int = 0
    private var titles: [String] = []
    private var items: [UIButton] = []
    private var selectedView: UIView = UIView()
    private var selectedViewLeadingConstraint: NSLayoutConstraint!
    
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
    //MARK:- Overided functions
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setSelectedItem(at: selectedIndex, animated: false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addShadowConstarint()
    }
    
    //MARK:- Public functions
    init(titles: [String]) {
        self.titles = titles
        super.init(frame: .zero)
        commonInit()
        addObserver()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged(notification:)), name: NSNotification.Name(rawValue: NotificationName.changeLanguage), object: nil)
    }
    
    @objc func languageChanged(notification:Notification)  {
        updateItemsTitle()
    }
    
    func select(index: Int) {
        if index >= items.count {
            return
        }
        setSelectedItem(at: index)
        selectedIndex = index
    }
    
    //MARK:- Actions
    @objc private func itemAction(_ sender: UIButton) {
        delegate?.scTabBar(tabBar: self, didSelectItemAt: sender.tag)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK:- Private functions
extension SCTabBar {
    private func commonInit() {
        tabBarBackgroundColor = .clear
        tabBarSelectedTintColor = SCColors.titleColor
        tabBarUnselectedTintColor = SCColors.titleColor.withAlphaComponent(0.5)

        addItems()
        addSelectedView()
        addShadowViews()
    }
    
    private func setSelectedItem(at index: Int, animated: Bool = true) {
        let previousSelectedItem = items[selectedIndex]
        previousSelectedItem.isSelected = false

        let selectedItem = items[index]
        selectedItem.isSelected = true
        
        animateSelectedView(toX: selectedItem.frame.midX, animated: animated)
    }
    
    private func animateSelectedView(toX position: CGFloat, animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.selectedViewLeadingConstraint.constant = position - self.viewInset / 2
                self.layoutIfNeeded()
            }
        } else {
            self.selectedViewLeadingConstraint.constant = position - self.viewInset / 2
            self.layoutIfNeeded()
        }
    }
    
    private func updateItemsColors() {
        for item in items {
            item.setTitleColor(tabBarUnselectedTintColor, for: .normal)
            item.setTitleColor(tabBarSelectedTintColor, for: .selected)
        }
    }

    private func addItems() {
        for index in 0...titles.count - 1 {
            let item = createItem(for: index)
            items.append(item)
            addItemConstraints(item: item)
        }
        updateItemsColors()
    }
    
    private func addSelectedView() {
        selectedView.backgroundColor = tabBarSelectedTintColor
        selectedView.layer.cornerRadius = viewHeight / 2
        addSubview(selectedView)
        
        let firstItem = items.first!
        selectedView.translatesAutoresizingMaskIntoConstraints = false
        selectedView.bottomAnchor.constraint(equalTo: firstItem.bottomAnchor).isActive = true
        selectedView.widthAnchor.constraint(equalToConstant: viewWidth).isActive = true
        selectedView.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true
        selectedViewLeadingConstraint = NSLayoutConstraint(item: selectedView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: inset + viewInset)
        selectedViewLeadingConstraint.isActive = true
    }

    private func createItem(for index: Int)  -> UIButton{
        let item = UIButton()
        item.tag = index
        item.setTitle(titles[index].localize(), for: .normal)
        item.addTarget(self, action: #selector(itemAction(_:)), for: .touchUpInside)
        item.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        return item
    }
    
    private func addItemConstraints(item: UIButton) {
        let index = item.tag
        addSubview(item)
        item.translatesAutoresizingMaskIntoConstraints = false
        item.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        item.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true

        if index == 0 {
            item.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset).isActive = true
        } else {
            let previousItem = items[index - 1]
            item.leadingAnchor.constraint(equalTo: previousItem.trailingAnchor, constant: 0).isActive = true
            item.widthAnchor.constraint(equalTo: previousItem.widthAnchor, constant: 0).isActive = true
        }
        
        if index == titles.count - 1 {
            item.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset).isActive = true
        }
    }
    
    private func updateItemsTitle() {
        for index in 0...items.count - 1 {
            let item = items[index]
            item.setTitle(titles[index].localize(), for: .normal)
        }
    }
}

//MARK:- Shadow constraint
extension SCTabBar {
    
    func addShadowViews() {
        addSubview(mainView)
        mainView.addSubview(contentsLayer)
        self.sendSubviewToBack(mainView)
    }
    
    func addShadowConstarint() {
        NSLayoutConstraint.activate([
            mainView.centerYAnchor.constraint(equalTo: centerYAnchor),
            mainView.centerXAnchor.constraint(equalTo: centerXAnchor),
            mainView.heightAnchor.constraint(equalToConstant: frame.height),
            mainView.widthAnchor.constraint(equalToConstant:frame.width),
            contentsLayer.centerYAnchor.constraint(equalTo: mainView.centerYAnchor),
            contentsLayer.centerXAnchor.constraint(equalTo: mainView.centerXAnchor),
            contentsLayer.heightAnchor.constraint(equalTo: mainView.heightAnchor),
            contentsLayer.widthAnchor.constraint(equalTo: mainView.widthAnchor)
        ])
    }
}

