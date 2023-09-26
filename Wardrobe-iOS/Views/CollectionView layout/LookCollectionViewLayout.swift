//
//  LookCollectionViewLayout.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 5/2/20.
//

import UIKit

class LookCollectionViewLayout: UICollectionViewFlowLayout {
    private let loadingHeight: CGFloat = 50
    private let createLookHeight: CGFloat = 50
    var multipleHeights = [CGFloat]()
    var haveItems = [Bool]()
    var panding : CGFloat = 0
    var topMargin : CGFloat = 0
    var leftRightMargin : CGFloat = 0
    var contentHeight : CGFloat = 0
    var isCreateLook : Bool = false
    var isCustomCell : Bool = false
    var customCellHeight : CGFloat = 0
    var loadMore: Bool = false
    private var width : CGFloat {
        get {
            return collectionView!.bounds.width
        }
    }
    
    private var collectionAttributes : [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
    
    override var collectionViewContentSize: CGSize {
        get {
            return CGSize(width: width, height: contentHeight)
        }
    }
    
    override func prepare() {
        collectionAttributes.removeAll()
        var section = 0
        let margin = leftRightMargin
        let attributeWidth = (width - 2 * margin - panding) / 2

        if isCreateLook {
            let attributes : UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(row: 0, section: section))
            attributes.frame = CGRect(x: margin, y: panding + topMargin, width: width - 2 * margin, height: createLookHeight)
            collectionAttributes.append(attributes)
            section = 1
        }
        
        if isCustomCell {
            let attributes : UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(row: 0, section: section))
            attributes.frame = CGRect(x: 0, y: 0, width: collectionView!.bounds.width, height: customCellHeight)
            collectionAttributes.append(attributes)
            section = 1
        }
        
        for i in 0..<multipleHeights.count {
            let multipleHeight = multipleHeights[i]
            let index = i + section
            let indexPath = IndexPath(row: i, section: section)
            var x : CGFloat = 0
            if i % 2 == 0 {
                x = margin
            } else {
                x = attributeWidth + margin + panding
            }
            var y = panding + topMargin
            if index - 2 >= 0 {
                let attributes = collectionAttributes[index - 2]
                y = attributes.frame.maxY + panding
            }
            
            if isCustomCell && index < 2 {
                y = customCellHeight + panding
            }
            
            if isCreateLook && index < 2 {
                y = createLookHeight + 2 * panding + topMargin
            }
            
            var itemsHeight: CGFloat = 0
            if !haveItems.isEmpty {
                let haveItem = haveItems[i]
                if haveItem {
                    itemsHeight = (attributeWidth - 12) / 4 + 7
                }
            }
            
            let frame = CGRect(x: x, y: y, width: attributeWidth, height: attributeWidth * multipleHeight + itemsHeight)
            let attributes : UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
    
            collectionAttributes.append(attributes)
        }
        
        if loadMore {
            appendLoadingAttibutes()
        }
        
        if let lastAttributes = collectionAttributes.last {
            var maxY = lastAttributes.frame.maxY
            if collectionAttributes.count > 2 {
                let att = collectionAttributes[collectionAttributes.count - 2]
                if att.frame.maxY > maxY {
                    maxY = att.frame.maxY
                }
            }
            contentHeight = maxY
        }
    }
    
    private func appendLoadingAttibutes() {
        if let lastAttributes = collectionAttributes.last {
            var maxY = lastAttributes.frame.maxY
            if collectionAttributes.count >= 2 {
                let preMaxY = collectionAttributes[collectionAttributes.count - 2].frame.maxY
                maxY = max(maxY, preMaxY)
            }
            let indexPath = IndexPath(row: lastAttributes.indexPath.row + 1, section: lastAttributes.indexPath.section)
            let frame = CGRect(x: 0, y: maxY + panding, width: width, height: loadingHeight)
            let attributes : UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            collectionAttributes.append(attributes)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes : [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
        for attributes in collectionAttributes {
            if rect.intersects(attributes.frame)
            {
                layoutAttributes.append(attributes)
            }
        
        }
        return layoutAttributes
    }

    
}
