//
//  FeedingCell.swift
//  Elias Family
//
//  Created by Abraham  Elias on 28/11/18.
//  Copyright © 2018 Abraham  Elias. All rights reserved.
//

import UIKit

class FeedingCell: UITableViewCell {
    
    // Connection to the text label
    @IBOutlet weak var cellText: UILabel!
    // Conenction to the image
    @IBOutlet weak var catImage: UIImageView!
    
    func setUp(feeding: ClarkFeeding){
        // Sets the text of the label to the date of the feeding
        let unixTstamp = (feeding._time! as NSString).doubleValue
        cellText.text = TimeStuff.unixStampToTime(stamp: unixTstamp)
        
        // Sets the image (default value 1)
        catImage.image = UIImage(named: "feed\(feeding._imageNum?.description ?? "1")")
    }
}

