//
//  UICollectionViewExtension.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 6/7/20.
//

import Foundation
import UIKit

extension UICollectionView {
    func register(cell: UICollectionViewCell.Type) {
        let identifier = String(describing: cell)
        let nib = UINib(nibName: identifier, bundle: nil)
        register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(_ cell: UICollectionViewCell.Type, indexPath : IndexPath) -> T {
        let identifier = String(describing: cell)
        return dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! T
    }
    
    func updateInsets(horizontal: CGFloat = 16, vertical: CGFloat = 0, interItem: CGFloat = 16, interRow : CGFloat = 16, estimatedSize: CGSize? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil) {
          
          let viewFlowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout
          viewFlowLayout.sectionInset = UIEdgeInsets(top: vertical, left: left ?? horizontal, bottom: bottom ?? vertical, right: horizontal)
          viewFlowLayout.minimumLineSpacing = interItem
          viewFlowLayout.minimumInteritemSpacing = interRow
          if let estimatedItemSize = estimatedSize {
              viewFlowLayout.estimatedItemSize = estimatedItemSize
          }
          self.collectionViewLayout = viewFlowLayout
      }
}
