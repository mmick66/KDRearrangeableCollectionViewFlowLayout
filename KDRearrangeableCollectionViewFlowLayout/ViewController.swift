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
    
    lazy var data : [String] = {
        
        var array = [String]()
        
        if let path = NSBundle.mainBundle().pathForResource("names", ofType: "txt") {
            
            
            if let content = String(contentsOfFile:path, encoding: NSUTF8StringEncoding, error: nil) {
                
                array = content.componentsSeparatedByString("\n") as [String]
                
                array = array.map({ (row : String) -> String in
                    
                    
                    let range = NSString(string: row).rangeOfString(" ")
                    
                    return NSString(string: row).substringToIndex(range.location) as String
                })
                
                
            }
        }
        return array
    }()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as CollectionViewCell
        let name = self.data[indexPath.item]
        cell.titleLabel.text = name
        return cell
    }
    
    
    // MARK: - KDRearrangeableCollectionViewDelegate
    func moveDataItem(fromIndexPath : NSIndexPath, toIndexPath: NSIndexPath) -> Void {
        
        let name = self.data[fromIndexPath.item]
        
        self.data.removeAtIndex(fromIndexPath.item)
        
        self.data.insert(name, atIndex: toIndexPath.item)
        
    }

}

