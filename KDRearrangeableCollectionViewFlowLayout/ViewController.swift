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
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as CollectionViewCell
        cell.titleLabel.text = String(indexPath.item)
        return cell
    }
    
    
    // MARK: - KDRearrangeableCollectionViewDelegate
    func moveDataItem(fromIndexPath : NSIndexPath, toIndexPath: NSIndexPath) -> Void {
        
        
        
    }

}

