//
//  AlbumCollectionViewLayout.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/22/20.
//

import UIKit

class AlbumCollectionViewLayout: UICollectionViewLayout {
    var panding: CGFloat = 0
    var count: Int = 0
    private var width : CGFloat
    {
        get
        {
            return collectionView!.bounds.width
        }
    }
    
    private var height : CGFloat
    {
        get
        {
            return ((width / 3) * 2).rounded(.down)
        }
    }
    
    override var collectionViewContentSize: CGSize{
        get
        {
            return CGSize(width: width, height: height)
        }
    }
    
    private var collectionAttributes : [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
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
    
    override func prepare() {
       collectionAttributes.removeAll()
         
        switch count {
        case 1:
            let indexPath = IndexPath(row: 0, section: 0)
            let attributes : UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(x: 0, y: 0, width: width, height: height)
            collectionAttributes.append(attributes)
        case 2:
            for i in 0..<2 {
            let indexPath = IndexPath(row: i, section: 0)
                let attributes : UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: CGFloat(i) * (width / 2 + panding), y: 0, width: width / 2, height: height)
                collectionAttributes.append(attributes)
            }
        case 3:
            for i in 0..<3 {
                let indexPath = IndexPath(row: i, section: 0)
                let attributes : UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                if i == 0 {
                    attributes.frame = CGRect(x: 0, y: 0, width: height, height: height)
                } else {
                    attributes.frame = CGRect(x: height + panding, y: (CGFloat(i) - 1) * (height / 2 + panding), width: height / 2, height: height / 2 - (CGFloat(i) - 1) * panding)
                }
                collectionAttributes.append(attributes)
            }
        default:
            break
        }
    }
}
