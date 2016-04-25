//
//  ViewController.swift
//  KDRearrangeableCollectionViewFlowLayout
//
//  Created by Michael Michailidis on 16/03/2015.
//  Copyright (c) 2015 Karmadust. All rights reserved.
//

import UIKit

class ViewController: UIViewController, KDRearrangeableCollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewRearrangeableLayout: KDRearrangeableCollectionViewFlowLayout!
    
    lazy var data : [[String]] = {
        
        var array = [[String]]()
        
        if let path = NSBundle.mainBundle().pathForResource("names", ofType: "txt") {
            
            if let content = try? String(contentsOfFile:path, encoding: NSUTF8StringEncoding) {
                
                let allNamesArray = content.componentsSeparatedByString("\n") as [String]
                
                var index = 0
                var section = 0
                
                for name in allNamesArray {
                    
                    if array.count <= section {
                        array.append([String]())
                    }
                    
                    let range = NSString(string: name).rangeOfString(" ")
                    
                    let clean = NSString(string: name).substringToIndex(range.location) as String
                    
                    array[section].append(clean)
                    
                    if index == 20 {
                        index = 0
                        section += 1
                    } else {
                        index += 1
                    }
                    
                }
                
                
            }
        }
        return array
    }()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.collectionViewRearrangeableLayout.draggable = true
        
        self.collectionViewRearrangeableLayout.axis = .Free
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return self.data.count
    }


    // MARK: - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data[section].count
    }
    

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell
        let name = self.data[indexPath.section][indexPath.item]
        cell.titleLabel.text = name
        return cell
        
    }
    
    
    // MARK: - KDRearrangeableCollectionViewDelegate
    func moveDataItem(fromIndexPath : NSIndexPath, toIndexPath: NSIndexPath) {
        
        let name = self.data[fromIndexPath.section][fromIndexPath.item]
        
        self.data[fromIndexPath.section].removeAtIndex(fromIndexPath.item)
        
        self.data[toIndexPath.section].insert(name, atIndex: toIndexPath.item)
        
    }

}




