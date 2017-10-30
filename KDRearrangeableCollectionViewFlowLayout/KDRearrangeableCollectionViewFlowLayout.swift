//
//  KDRearrangeableCollectionViewFlowLayout.swift
//  KDRearrangeableCollectionViewFlowLayout
//
//  Created by Michael Michailidis on 16/03/2015.
//  Copyright (c) 2015 Karmadust. All rights reserved.
//

import UIKit

protocol KDRearrangeableCollectionViewDelegate : UICollectionViewDelegate {
    func canMoveItem(at indexPath : IndexPath) -> Bool
    func moveDataItem(from source : IndexPath, to destination: IndexPath) -> Void
}

extension KDRearrangeableCollectionViewDelegate {
    func canMoveItem(at indexPath : IndexPath) -> Bool {
        return true
    }
}

enum KDDraggingAxis {
    case free
    case x
    case y
    case xy
}

class KDRearrangeableCollectionViewFlowLayout: UICollectionViewFlowLayout, UIGestureRecognizerDelegate {
    
    var animating : Bool = false
    
    var draggable : Bool = true
    
    
    
    var collectionViewFrameInCanvas : CGRect = CGRect.zero
    
    var hitTestRectagles = [String:CGRect]()
  
    var canvas : UIView? {
        didSet {
            if canvas != nil {
                self.calculateBorders()
            }
        }
    }
    
    var axis : KDDraggingAxis = .free
    
    struct Bundle {
        var offset : CGPoint = CGPoint.zero
        var sourceCell : UICollectionViewCell
        var representationImageView : UIView
        var currentIndexPath : IndexPath
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

            let longPressGestureRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(KDRearrangeableCollectionViewFlowLayout.handleGesture(_:)))
        
            longPressGestureRecogniser.minimumPressDuration = 0.2
            longPressGestureRecogniser.delegate = self

            collectionView.addGestureRecognizer(longPressGestureRecogniser)
            
            if self.canvas == nil {
                
                self.canvas = self.collectionView!.superview
                
            }
            
            
        }
    }
    
    override func prepare() {
        super.prepare()
        self.calculateBorders()
    }
    
    fileprivate func calculateBorders() {
        
        if let collectionView = self.collectionView {
            
            collectionViewFrameInCanvas = collectionView.frame
            
            
            if self.canvas != collectionView.superview {
                collectionViewFrameInCanvas = self.canvas!.convert(collectionViewFrameInCanvas, from: collectionView)
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
   
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if draggable == false {
            return false
        }
        
        guard let ca = self.canvas else {
            return false
        }
        
        guard let cv = self.collectionView else {
            return false
        }
        
        let pointPressedInCanvas = gestureRecognizer.location(in: ca)
        
        for cell in cv.visibleCells {
            
            guard let indexPath:IndexPath = cv.indexPath(for: cell) else {
                return false
            }
            
            let cellInCanvasFrame = ca.convert(cell.frame, from: cv)
            
            if cellInCanvasFrame.contains(pointPressedInCanvas ) {
                
                if cv.delegate is KDRearrangeableCollectionViewDelegate {
                    let d = cv.delegate as! KDRearrangeableCollectionViewDelegate
                    if d.canMoveItem(at: indexPath) == false {
                        return false
                    }
                }
                
                if let kdcell = cell as? KDRearrangeableCollectionViewCell {
                    // Override he dragging setter to apply and change in style that you want
                    kdcell.dragging = true
                }
                
                UIGraphicsBeginImageContextWithOptions(cell.bounds.size, cell.isOpaque, 0)
                cell.layer.render(in: UIGraphicsGetCurrentContext()!)
                let img = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                let representationImage = UIImageView(image: img)
                
                representationImage.frame = cellInCanvasFrame
                
                let offset = CGPoint(x: pointPressedInCanvas.x - cellInCanvasFrame.origin.x, y: pointPressedInCanvas.y - cellInCanvasFrame.origin.y)
                
                self.bundle = Bundle(offset: offset, sourceCell: cell, representationImageView:representationImage, currentIndexPath: indexPath)
                
                break
            }
            
        }
        
        return (self.bundle != nil)
    }
    
    
    
    func checkForDraggingAtTheEdgeAndAnimatePaging(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        if self.animating == true {
            return
        }
        
        if let bundle = self.bundle {
            
           
            var nextPageRect : CGRect = self.collectionView!.bounds
            
            if self.scrollDirection == UICollectionViewScrollDirection.horizontal {
                
                if bundle.representationImageView.frame.intersects(hitTestRectagles["left"]!) {
                   
                    nextPageRect.origin.x -= nextPageRect.size.width
                    
                    if nextPageRect.origin.x < 0.0 {
                        
                        nextPageRect.origin.x = 0.0
                        
                    }
                    
                }
                else if bundle.representationImageView.frame.intersects(hitTestRectagles["right"]!) {
                  
                    nextPageRect.origin.x += nextPageRect.size.width
                    
                    if nextPageRect.origin.x + nextPageRect.size.width > self.collectionView!.contentSize.width {
                        
                        nextPageRect.origin.x = self.collectionView!.contentSize.width - nextPageRect.size.width
                        
                    }
                }
                
                
            }
            else if self.scrollDirection == UICollectionViewScrollDirection.vertical {
                
                
                if bundle.representationImageView.frame.intersects(hitTestRectagles["top"]!) {
                    
                    
                    nextPageRect.origin.y -= nextPageRect.size.height
                    
                    if nextPageRect.origin.y < 0.0 {
                        
                        nextPageRect.origin.y = 0.0
                        
                    }
                    
                }
                else if bundle.representationImageView.frame.intersects(hitTestRectagles["bottom"]!) {
                   
                    nextPageRect.origin.y += nextPageRect.size.height
                    
                    
                    if nextPageRect.origin.y + nextPageRect.size.height > self.collectionView!.contentSize.height {
                        
                        nextPageRect.origin.y = self.collectionView!.contentSize.height - nextPageRect.size.height
                        
                    }
                }
                
                
            }
            
            if !nextPageRect.equalTo(self.collectionView!.bounds){
                
                
                let delayTime = DispatchTime.now() + Double(Int64(0.8 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                
                DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                    
                    self.animating = false
                    
                    self.handleGesture(gestureRecognizer)
                    
                    
                });
                
                self.animating = true
                
                
                self.collectionView!.scrollRectToVisible(nextPageRect, animated: true)
                
            }
            
        }
        
      
    }
    
    @objc func handleGesture(_ gesture: UILongPressGestureRecognizer) -> Void {
        
    
        guard let bundle = self.bundle else {
            return
        }

        
        func endDraggingAction(_ bundle: Bundle) {
            
            bundle.sourceCell.isHidden = false
            
            if let kdcell = bundle.sourceCell as? KDRearrangeableCollectionViewCell {
                kdcell.dragging = false
            }
            
            bundle.representationImageView.removeFromSuperview()
            
            // if we have a proper data source then we can reload and have the data displayed correctly
            if let cv = self.collectionView, cv.delegate is KDRearrangeableCollectionViewDelegate {
                cv.reloadData()
            }
            
            self.bundle = nil
        }
        
        let dragPointOnCanvas = gesture.location(in: self.canvas)
        
        
        switch gesture.state {
            
            
        case .began:
            
            bundle.sourceCell.isHidden = true
            self.canvas?.addSubview(bundle.representationImageView)
            
            var imageViewFrame = bundle.representationImageView.frame
            var point = CGPoint.zero
            point.x = dragPointOnCanvas.x - bundle.offset.x
            point.y = dragPointOnCanvas.y - bundle.offset.y
            
            imageViewFrame.origin = point
            bundle.representationImageView.frame = imageViewFrame
            
            break
            
        case .changed:
            // Update the representation image
            var imageViewFrame = bundle.representationImageView.frame
            var point = CGPoint(x: dragPointOnCanvas.x - bundle.offset.x, y: dragPointOnCanvas.y - bundle.offset.y)
            if self.axis == .x {
                point.y = imageViewFrame.origin.y
            }
            if self.axis == .y {
                point.x = imageViewFrame.origin.x
            }
            
            
            imageViewFrame.origin = point
            bundle.representationImageView.frame = imageViewFrame
            
            
            var dragPointOnCollectionView = gesture.location(in: self.collectionView)
            
            if self.axis == .x {
                dragPointOnCollectionView.y = bundle.representationImageView.center.y
            }
            if self.axis == .y {
                dragPointOnCollectionView.x = bundle.representationImageView.center.x
            }
            
            
            
            
            if let indexPath : IndexPath = self.collectionView?.indexPathForItem(at: dragPointOnCollectionView) {
                
                self.checkForDraggingAtTheEdgeAndAnimatePaging(gesture)
                
                
                if (indexPath == bundle.currentIndexPath) == false {
                    
                    // If we have a collection view controller that implements the delegate we call the method first
                    if let delegate = self.collectionView!.delegate as? KDRearrangeableCollectionViewDelegate {
                        delegate.moveDataItem(from: bundle.currentIndexPath, to: indexPath)
                    }
                    
                    self.collectionView!.moveItem(at: bundle.currentIndexPath, to: indexPath)
                    
                    self.bundle!.currentIndexPath = indexPath
                    
                }
                
            }
            break
            
            
        case .ended:
            endDraggingAction(bundle)
            
            break
            
        case .cancelled:
            endDraggingAction(bundle)
            
            break
            
        case .failed:
            endDraggingAction(bundle)
            
            break
            
            
        case .possible:
            break
            
            
        }
        
    }
    
}





