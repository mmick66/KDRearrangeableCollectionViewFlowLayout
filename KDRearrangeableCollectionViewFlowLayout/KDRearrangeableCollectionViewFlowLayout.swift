//
//  KDRearrangeableCollectionViewFlowLayout.swift
//  KDRearrangeableCollectionViewFlowLayout
//
//  Created by Michael Michailidis on 16/03/2015.
//  Copyright (c) 2015 Karmadust. All rights reserved.
//

import UIKit

@objc protocol KDRearrangeableCollectionViewDelegate : UICollectionViewDelegate {
    func moveDataItem(fromIndexPath : NSIndexPath, toIndexPath: NSIndexPath) -> Void
}

class KDRearrangeableCollectionViewFlowLayout: UICollectionViewFlowLayout, UIGestureRecognizerDelegate {
    
    var animating : Bool = false
    
    var collectionViewFrameInCanvas : CGRect = CGRectZero
    
    var hitTestRectagles = [String:CGRect]()
  
    var canvas : UIView? {
        didSet {
            if canvas != nil {
                self.calculateBorders()
            }
        }
    }
    
    struct Bundle {
        var offset : CGPoint = CGPointZero
        var sourceCell : UICollectionViewCell
        var representationImageView : UIView
        var currentIndexPath : NSIndexPath
    }
    var bundle : Bundle?
    
    
    override init() {
        super.init()
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    func setup() {
        
        if let collectionView = self.collectionView {

            let longPressGestureRecogniser = UILongPressGestureRecognizer(target: self, action: "handleGesture:")
        
            longPressGestureRecogniser.minimumPressDuration = 0.2
            longPressGestureRecogniser.delegate = self

            collectionView.addGestureRecognizer(longPressGestureRecogniser)
            
            if self.canvas == nil {
                
                self.canvas = self.collectionView!.superview
                
            }
            
            
        }
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        self.calculateBorders()
    }
    
    private func calculateBorders() {
        
        if let collectionView = self.collectionView {
            
            collectionViewFrameInCanvas = collectionView.frame
            
            
            if self.canvas != collectionView.superview {
                collectionViewFrameInCanvas = self.canvas!.convertRect(collectionViewFrameInCanvas, fromView: collectionView)
            }
            
            
            var leftRect : CGRect = collectionViewFrameInCanvas
            leftRect.size.width = 20.0
            hitTestRectagles["left"] = leftRect
            
            var topRect : CGRect = collectionViewFrameInCanvas
            topRect.size.height = 20.0
            hitTestRectagles["top"] = topRect
            
            var rightRect : CGRect = collectionViewFrameInCanvas
            rightRect.origin.x = rightRect.size.width - 20.0
            rightRect.size.width = 20.0
            hitTestRectagles["right"] = rightRect
            
            var bottomRect : CGRect = collectionViewFrameInCanvas
            bottomRect.origin.y = bottomRect.origin.y + rightRect.size.height - 20.0
            bottomRect.size.height = 20.0
            hitTestRectagles["bottom"] = bottomRect
            
           
            
            
        }
        
        
    }
    
    
    // MARK: - UIGestureRecognizerDelegate
   
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let ca = self.canvas {
            
            if let cv = self.collectionView {
                
                let pointPressedInCanvas = gestureRecognizer.locationInView(ca)
                
                for cell in cv.visibleCells() {
                    
                    let cellInCanvasFrame = ca.convertRect(cell.frame, fromView: cv)
                    
                    if CGRectContainsPoint(cellInCanvasFrame, pointPressedInCanvas ) {
                        
                        // apply any transformations to the cell
                        
                        if let kdcell = cell as? KDRearrangeableCollectionViewCell {
                            
                            kdcell.dragging = true
                        }
                        
                    
                        UIGraphicsBeginImageContextWithOptions(cell.bounds.size, cell.opaque, 0)
                        cell.layer.renderInContext(UIGraphicsGetCurrentContext()!)
                        let img = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        
                        let representationImage = UIImageView(image: img)
                        
                        representationImage.frame = cellInCanvasFrame
                        
                        let offset = CGPointMake(pointPressedInCanvas.x - cellInCanvasFrame.origin.x, pointPressedInCanvas.y - cellInCanvasFrame.origin.y)
                        
                        let indexPath : NSIndexPath = cv.indexPathForCell(cell as UICollectionViewCell)!
                        
                        self.bundle = Bundle(offset: offset, sourceCell: cell, representationImageView:representationImage, currentIndexPath: indexPath)
                        
                        
                        break
                    }
                    
                }
                
            }
            
        }
        return (self.bundle != nil)
    }
    
    
    
    func checkForDraggingAtTheEdgeAndAnimatePaging(gestureRecognizer: UILongPressGestureRecognizer) {
        
        if self.animating == true {
            return
        }
        
        if let bundle = self.bundle {
            
           
            var nextPageRect : CGRect = self.collectionView!.bounds
            
            if self.scrollDirection == UICollectionViewScrollDirection.Horizontal {
                
                if CGRectIntersectsRect(bundle.representationImageView.frame, hitTestRectagles["left"]!) {
                   
                    nextPageRect.origin.x -= nextPageRect.size.width
                    
                    if nextPageRect.origin.x < 0.0 {
                        
                        nextPageRect.origin.x = 0.0
                        
                    }
                    
                }
                else if CGRectIntersectsRect(bundle.representationImageView.frame, hitTestRectagles["right"]!) {
                  
                    nextPageRect.origin.x += nextPageRect.size.width
                    
                    if nextPageRect.origin.x + nextPageRect.size.width > self.collectionView!.contentSize.width {
                        
                        nextPageRect.origin.x = self.collectionView!.contentSize.width - nextPageRect.size.width
                        
                    }
                }
                
                
            }
            else if self.scrollDirection == UICollectionViewScrollDirection.Vertical {
                
                
                if CGRectIntersectsRect(bundle.representationImageView.frame, hitTestRectagles["top"]!) {
                    
                    
                    nextPageRect.origin.y -= nextPageRect.size.height
                    
                    if nextPageRect.origin.y < 0.0 {
                        
                        nextPageRect.origin.y = 0.0
                        
                    }
                    
                }
                else if CGRectIntersectsRect(bundle.representationImageView.frame, hitTestRectagles["bottom"]!) {
                   
                    nextPageRect.origin.y += nextPageRect.size.height
                    
                    
                    if nextPageRect.origin.y + nextPageRect.size.height > self.collectionView!.contentSize.height {
                        
                        nextPageRect.origin.y = self.collectionView!.contentSize.height - nextPageRect.size.height
                        
                    }
                }
                
                
            }
            
            if !CGRectEqualToRect(nextPageRect, self.collectionView!.bounds){
                
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.8 * Double(NSEC_PER_SEC)))
                
                dispatch_after(delayTime, dispatch_get_main_queue(), {
                    
                    self.animating = false
                    
                    self.handleGesture(gestureRecognizer)
                    
                    
                });
                
                self.animating = true
                
                
                self.collectionView!.scrollRectToVisible(nextPageRect, animated: true)
                
            }
            
        }
        
      
    }
    
    func handleGesture(gesture: UILongPressGestureRecognizer) -> Void {
        
    
        if let bundle = self.bundle {
            
            let dragPointOnCanvas = gesture.locationInView(self.canvas)
            
            
            if gesture.state == UIGestureRecognizerState.Began {
                
                bundle.sourceCell.hidden = true
                self.canvas?.addSubview(bundle.representationImageView)

                
            }
            
            
            if gesture.state == UIGestureRecognizerState.Changed {
                
                // Update the representation image
                var imageViewFrame = bundle.representationImageView.frame
                var point = CGPointZero
                point.x = dragPointOnCanvas.x - bundle.offset.x
                point.y = dragPointOnCanvas.y - bundle.offset.y
                imageViewFrame.origin = point
                bundle.representationImageView.frame = imageViewFrame
                
                
                let dragPointOnCollectionView = gesture.locationInView(self.collectionView)
                
                
                if let indexPath : NSIndexPath = self.collectionView?.indexPathForItemAtPoint(dragPointOnCollectionView) {
                    
                    
                    
                    self.checkForDraggingAtTheEdgeAndAnimatePaging(gesture)
                    
                    
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
                
                if let kdcell = bundle.sourceCell as? KDRearrangeableCollectionViewCell {
                    kdcell.dragging = false
                }
                
                bundle.representationImageView.removeFromSuperview()
                
                if let _ = self.collectionView?.delegate as? KDRearrangeableCollectionViewDelegate { // if we have a proper data source then we can reload and have the data displayed correctly
                    self.collectionView!.reloadData()
                }
                
                self.bundle = nil
                
                
            }
            
            
        }
        
    }
    
}
