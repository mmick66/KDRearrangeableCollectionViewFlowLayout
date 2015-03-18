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
        var canvas : UIView
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
            
            if  let canvas = collectionView.superview {
                
                let pointPressed = gestureRecognizer.locationInView(canvas)
                
                if let indexPath = collectionView.indexPathForItemAtPoint(pointPressed) {
                    
                    let sourceCell = collectionView.cellForItemAtIndexPath(indexPath) as UICollectionViewCell!
                    
                    let cellFrameOnCanvas = collectionView.convertRect(sourceCell.frame, toView: canvas)
                    
                    let representationImageView = sourceCell.snapshotViewAfterScreenUpdates(true)
                    representationImageView.frame = cellFrameOnCanvas
                    
                    
                    let offset = CGPointMake(pointPressed.x - cellFrameOnCanvas.origin.x, pointPressed.y - cellFrameOnCanvas.origin.y)
                    
                    
                    bundle = Bundle(offset: offset,
                        sourceCell: sourceCell,
                        representationImageView: representationImageView,
                        currentIndexPath: indexPath,
                        canvas: canvas)
                    
                }
                
            }
            else {
                println("You need to add your collection view to the view hierarchy to implement the drag and drop action")
            }
           
        }
        
        return bundle != nil
    }
    
    
    
    func handleGesture(gesture: UILongPressGestureRecognizer) -> Void {
        
        
        
        // bundle as a condition inlcudes collectionView and canvas being non nil so it is better to check only for this and unwrap the rest
        if let bundle = self.bundle {
            
            let dragPointOnCanvas = gesture.locationInView(bundle.canvas)
            
            
            if gesture.state == UIGestureRecognizerState.Began {
                
                bundle.sourceCell.hidden = true
                bundle.canvas.addSubview(bundle.representationImageView)
                
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    bundle.representationImageView.alpha = 0.8
                });
                
            }
            
            
            if gesture.state == UIGestureRecognizerState.Changed {
                
                var imageViewFrame = bundle.representationImageView.frame
                var point = CGPointZero
                point.x = dragPointOnCanvas.x - bundle.offset.x
                point.y = dragPointOnCanvas.y - bundle.offset.y
                imageViewFrame.origin = point
                bundle.representationImageView.frame = imageViewFrame
                
                let dragPointOnCollectionView = gesture.locationInView(self.collectionView)
                
                if let indexPath : NSIndexPath = self.collectionView?.indexPathForItemAtPoint(dragPointOnCollectionView) {
                    
                    //self.checkForDraggingAtTheEdgeAndAnimatePaging(df, gestureRecognizer: gestureRecognizer)
                    
                    if indexPath.isEqual(bundle.currentIndexPath) == false {
                        
                        // If we have a collection view controller that implements the delegate we call the method first
                        if let delegate = self.collectionView!.delegate as? KDRearrangeableCollectionViewDelegate {
                            delegate.moveDataItem(bundle.currentIndexPath, toIndexPath: indexPath)
                        }
                        
                        self.collectionView!.moveItemAtIndexPath(bundle.currentIndexPath, toIndexPath: indexPath)
                        
                        self.bundle!.currentIndexPath = indexPath
                        
                    }
                    
                }
                
                
            }
            
            if gesture.state == UIGestureRecognizerState.Ended {
                
               
                bundle.sourceCell.hidden = false
                bundle.representationImageView.removeFromSuperview()
                
                if let delegate = self.collectionView?.delegate as? KDRearrangeableCollectionViewDelegate { // if we have a proper data source then we can reload and have the data displayed correctly
                    self.collectionView!.reloadData()
                }
                
                self.bundle = nil
                
                
            }
            
            
        }
        
    }
    
}
