//
//  PhotosLayout.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 27.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class PhotosLayout: UICollectionViewLayout {
    private let columnsCount = 2
    private var totalCellsHeight:CGFloat = 0
    private var cashedAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        let itemCount = collectionView.numberOfItems(inSection: 0)
        let cellWidth = collectionView.frame.width / 2
        let cellHeight = cellWidth + 100
        var lastX: CGFloat = 0
        var lastY: CGFloat = 0
        
        for index in 0..<itemCount {
            let indexPath = IndexPath(item: index, section: 0)
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attribute.frame = CGRect(x: lastX, y: lastY, width: cellWidth, height: cellHeight)
            
            if index % 2 == 0 {
                lastX += cellWidth
            } else {
                lastX = 0
                lastY += cellHeight
            }
            cashedAttributes[indexPath] = attribute
        }
        totalCellsHeight = lastY + cellHeight
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cashedAttributes.values.filter{
            return rect.intersects($0.frame)
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cashedAttributes[indexPath]
    }
    
    override var collectionViewContentSize: CGSize{
        return CGSize(width: collectionView?.frame.width ?? 0, height: totalCellsHeight)
    }
}
