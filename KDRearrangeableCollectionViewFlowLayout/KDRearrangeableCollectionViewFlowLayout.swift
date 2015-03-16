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
        
        func move(point : CGPoint) {
            var imageViewFrame = representationImageView.frame
            imageViewFrame.origin = CGPointMake(point.x - offset.x, point.y - offset.y)
            representationImageView.frame = imageViewFrame
        }
        
        func contact(view : UIView?) -> Bool {
            
            if let viewToCompare = view {
                
                return CGRectIntersectsRect(representationImageView.frame, viewToCompare.frame)
                
            }
            
            return false
            
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
        
        let longPressGestureRecogniser = UILongPressGestureRecognizer(target: self, action: "handleGesture:")
        
        longPressGestureRecogniser.minimumPressDuration = 0.3
        longPressGestureRecogniser.delegate = self
        
        if let collectionView = self.collectionView {
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
        if let df = self.bundle {
            
            let pointInCollectionView = gestureRecognizer.locationInView(self.collectionView)
            
            
            if gestureRecognizer.state == UIGestureRecognizerState.Began {
                
                df.sourceCell.hidden = true
                df.sourceCollectionView.addSubview(df.representationImageView)
                
                
            }
            
            
            if gestureRecognizer.state == UIGestureRecognizerState.Changed {
                
                df.move(pointInCollectionView)
                
                
                if let indexPath : NSIndexPath = df.sourceCollectionView.indexPathForItemAtPoint(pointInCollectionView) {
                    
                    //self.checkForDraggingAtTheEdgeAndAnimatePaging(df, gestureRecognizer: gestureRecognizer)
                    
                    if indexPath.isEqual(df.currentIndexPath) == false {
                        
                        // If we have a collection view controller that implements the delegate we call the method first
                        if let delegate = self.collectionView!.delegate as? KDRearrangeableCollectionViewDelegate {
                            delegate.moveDataItem(df.currentIndexPath, toIndexPath: indexPath)
                        }
                        
                        df.sourceCollectionView.moveItemAtIndexPath(df.currentIndexPath, toIndexPath: indexPath)
                        
                        bundle!.currentIndexPath = indexPath
                        
                    }
                    
                
                    
                }
                
                
            }
            
            if gestureRecognizer.state == UIGestureRecognizerState.Ended {
                
               
                df.sourceCell.hidden = false
                df.representationImageView.removeFromSuperview()
                
                if let delegate = self.collectionView!.delegate as? KDRearrangeableCollectionViewDelegate { // if we have a proper data source then we can reload and have the data displayed correctly
                    df.sourceCollectionView.reloadData()
                }
                
                bundle = nil
                
                
            }
            
            
        }
        
    }
    
}
