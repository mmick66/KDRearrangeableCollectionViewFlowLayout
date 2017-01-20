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
        
        if let path = Bundle.main.path(forResource: "names", ofType: "txt") {
            
            if let content = try? String(contentsOfFile:path, encoding: String.Encoding.utf8) {
                
                let allNamesArray = content.components(separatedBy: "\n") as [String]
                
                var index = 0
                var section = 0
                
                for name in allNamesArray {
                    
                    if array.count <= section {
                        array.append([String]())
                    }
                    
                    let range = NSString(string: name).range(of: " ")
                    
                    let clean = NSString(string: name).substring(to: range.location) as String
                    
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
        
        self.collectionViewRearrangeableLayout.axis = .free
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return self.data.count
    }


    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data[section].count
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        let name = self.data[indexPath.section][indexPath.item]
        cell.titleLabel.text = name
        return cell
        
    }
    
    
    // MARK: - KDRearrangeableCollectionViewDelegate
    
    func canMoveItem(at indexPath: IndexPath) -> Bool {
        print(self.data[indexPath.section][indexPath.item])
        if self.data[indexPath.section][indexPath.item] == "THOMAS" {
            return false
        }
        return true
    }
    
    func moveDataItem(from source : IndexPath, to destination: IndexPath) -> Void {
        
        let name = self.data[source.section][source.item]
        
        self.data[source.section].remove(at: source.item)
        
        self.data[destination.section].insert(name, at: destination.item)
        
    }

}




