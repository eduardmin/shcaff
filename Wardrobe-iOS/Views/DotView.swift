//
//  DotView.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 6/11/20.
//

import UIKit

class DotView: UIView {

    let dotHeight : CGFloat = 8
    let padding : CGFloat = 9
    lazy var dotStackView: UIStackView = {
           let stackView = UIStackView()
           stackView.spacing = padding
           stackView.alignment = .center
           stackView.translatesAutoresizingMaskIntoConstraints = false
           addSubview(stackView)
           return stackView
    }()
    private var dotBackroundColor: UIColor?
    private var dotSelectedColor: UIColor?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addConstraints()
    }
    
// MARK:- UI
    private func addConstraints() {
        addConstraints([NSLayoutConstraint(item: dotStackView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0), NSLayoutConstraint(item: dotStackView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: dotStackView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 10)
        ])
    }
    
// MARK:-Public func
    func configure(numberOfDots: Int, dotBackroundColor: UIColor? = nil, dotSelectedColor: UIColor? = nil, alignment: UIStackView.Alignment? = nil) {
        self.dotBackroundColor = dotBackroundColor
        self.dotSelectedColor = dotSelectedColor
        deleteAll()
        if let alignment = alignment {
            dotStackView.alignment = alignment
        }
        if numberOfDots > 1 {
            for i in 0..<numberOfDots {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.backgroundColor = dotBackroundColor ?? UIColor.white.withAlphaComponent(0.32)
                view.heightAnchor.constraint(equalToConstant: dotHeight).isActive = true
                view.widthAnchor.constraint(equalToConstant: dotHeight).isActive = true
                view.layer.cornerRadius = dotHeight / 2
                dotStackView.insertArrangedSubview(view, at: i)
            }
            let margin = padding * CGFloat((numberOfDots - 1))
            dotStackView.widthAnchor.constraint(equalToConstant: CGFloat(numberOfDots) * dotHeight + margin).isActive = true
        }
    }
    
    func selectIndex(index : Int) {
        for view in dotStackView.arrangedSubviews {
            if let _index = dotStackView.arrangedSubviews.firstIndex(of: view), _index == index {
                view.backgroundColor = dotSelectedColor ?? UIColor.white
            } else {
                view.backgroundColor = dotBackroundColor ?? UIColor.white.withAlphaComponent(0.32)
            }
        }
    }

    func deleteAll() {
        for view in dotStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
    }
}
