//
//  CollectionViewCell.swift
//  KDRearrangeableCollectionViewFlowLayout
//
//  Created by Michael Michailidis on 16/03/2015.
//  Copyright (c) 2015 Karmadust. All rights reserved.
//

import UIKit

class CollectionViewCell: KDRearrangeableCollectionViewCell {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.layer.cornerRadius = self.frame.size.width * 0.5
        self.clipsToBounds = true
    }
    
    
    

}
