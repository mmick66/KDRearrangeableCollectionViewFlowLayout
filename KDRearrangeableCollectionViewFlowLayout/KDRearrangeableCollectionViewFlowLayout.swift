//
//  KDRearrangeableCollectionViewFlowLayout.swift
//  KDRearrangeableCollectionViewFlowLayout
//
//  Created by Michael Michailidis on 16/03/2015.
//  Copyright (c) 2015 Karmadust. All rights reserved.
//

import UIKit

class KDRearrangeableCollectionViewFlowLayout: UICollectionViewFlowLayout, UIGestureRecognizerDelegate {
    
    
    struct Bundle {
        
        var offset : CGPoint = CGPointZero
        var sourceCell : UICollectionViewCell
        var representationImageView : UIView
        var currentIndexPath : NSIndexPath
        var sourceCollectionView : UICollectionView
        
        init(pointPressed: CGPoint, collectionView : UICollectionView, indexPath : NSIndexPath) {
            
            sourceCollectionView = collectionView
            
            sourceCell = sourceCollectionView.cellForItemAtIndexPath(indexPath) as UICollectionViewCell!
            
            offset = CGPointMake(pointPressed.x - sourceCell.frame.origin.x, pointPressed.y - sourceCell.frame.origin.y)
            
            representationImageView = sourceCell.snapshotViewAfterScreenUpdates(true)
            representationImageView.frame = sourceCell.frame
            
            currentIndexPath = indexPath
        
        }
        
        
    }
    
    var bundle : Bundle?
    
    
    override init() {
        super.init()
        self.setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    func setup() {
        
        if let collectionView = self.collectionView {

            let longPressGestureRecogniser = UILongPressGestureRecognizer(target: self, action: "handleGesture:")
        
            longPressGestureRecogniser.minimumPressDuration = 0.3
            longPressGestureRecogniser.delegate = self

            collectionView.addGestureRecognizer(longPressGestureRecogniser)
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
   
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let collectionView = self.collectionView {
           
            let pointInCollectionView = gestureRecognizer.locationInView(collectionView)
            
            if let indexPath = collectionView.indexPathForItemAtPoint(pointInCollectionView) {
                
                bundle = Bundle(pointPressed: pointInCollectionView, collectionView: collectionView, indexPath: indexPath)
                
            }
            
        }
        
        return bundle != nil
    }
    
    
    
    func handleGesture(gestureRecognizer: UILongPressGestureRecognizer) -> Void {
        
        
        
        // bundle as a condition inlcudes collectionView and canvas being non nil so it is better to check only for this and unwrap the rest
        if let bundle = self.bundle {
            
            let pointInCollectionView = gestureRecognizer.locationInView(self.collectionView)
            
            
            if gestureRecognizer.state == UIGestureRecognizerState.Began {
                
                bundle.sourceCell.hidden = true
                bundle.sourceCollectionView.addSubview(bundle.representationImageView)
                
                
            }
            
            
            if gestureRecognizer.state == UIGestureRecognizerState.Changed {
                
                var imageViewFrame = bundle.representationImageView.frame
                imageViewFrame.origin = CGPointMake(pointInCollectionView.x - bundle.offset.x, pointInCollectionView.y - bundle.offset.y)
                bundle.representationImageView.frame = imageViewFrame
                
                
                if let indexPath : NSIndexPath = bundle.sourceCollectionView.indexPathForItemAtPoint(pointInCollectionView) {
                    
                    //self.checkForDraggingAtTheEdgeAndAnimatePaging(df, gestureRecognizer: gestureRecognizer)
                    
                    if indexPath.isEqual(bundle.currentIndexPath) == false {
                        
                        // If we have a collection view controller that implements the delegate we call the method first
                        if let delegate = self.collectionView!.delegate as? KDRearrangeableCollectionViewDelegate {
                            delegate.moveDataItem(bundle.currentIndexPath, toIndexPath: indexPath)
                        }
                        
                        bundle.sourceCollectionView.moveItemAtIndexPath(bundle.currentIndexPath, toIndexPath: indexPath)
                        
                        self.bundle!.currentIndexPath = indexPath
                        
                    }
                    
                
                    
                }
                
                
            }
            
            if gestureRecognizer.state == UIGestureRecognizerState.Ended {
                
               
                bundle.sourceCell.hidden = false
                bundle.representationImageView.removeFromSuperview()
                
                if let delegate = self.collectionView!.delegate as? KDRearrangeableCollectionViewDelegate { // if we have a proper data source then we can reload and have the data displayed correctly
                    bundle.sourceCollectionView.reloadData()
                }
                
                self.bundle = nil
                
                
            }
            
            
        }
        
    }
    
}
