//
//  ProgrammerCollectionViewCell.swift
//  BotApp
//
//  Created by lu on 19/01/2019.
//  Copyright © 2019 lu. All rights reserved.
//

import UIKit

class ProgrammerCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var labelTxt: UILabel!
    @IBOutlet weak var colorView: UIView!
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        setNeedsLayout()
        layoutIfNeeded()
        
        let size = colorView.systemLayoutSizeFitting(layoutAttributes.size)
        
        var frame = layoutAttributes.frame
        frame.size.height = ceil(size.height)
        layoutAttributes.frame = frame
        
        return layoutAttributes
    }
}
