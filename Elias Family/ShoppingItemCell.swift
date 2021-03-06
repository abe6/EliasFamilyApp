//
//  ShoppingItemCell.swift
//  Elias Family
//
//  Created by Abraham  Elias on 21/1/19.
//  Copyright © 2019 Abraham  Elias. All rights reserved.
//

import UIKit

class ShoppingItemCell: UICollectionViewCell {
    // Links
    @IBOutlet weak var itemName: UILabel!
    
    func setUp(item: ShoppingItem){
        
        // Sets the text labels
        itemName.text = item._title?.description
        
        if (item._purchased?.boolValue) == true {
            self.backgroundColor = UIColor.darkGray
            itemName.textColor = UIColor.lightGray
        }else{
            self.backgroundColor = UIColor.white
            itemName.textColor = UIColor.darkGray
        }
        
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        
        self.layer.borderWidth = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
    }
}
