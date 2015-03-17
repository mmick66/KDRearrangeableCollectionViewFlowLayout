//
//  KDRearrangableCollectionViewDataSource.swift
//  DragAndDropCollectionViews
//
//  Created by Michael Michailidis on 16/03/2015.
//  Copyright (c) 2015 karmadust. All rights reserved.
//

import UIKit

@objc protocol KDRearrangeableCollectionViewDelegate : UICollectionViewDelegate {
    
    func moveDataItem(fromIndexPath : NSIndexPath, toIndexPath: NSIndexPath) -> Void
    
}

