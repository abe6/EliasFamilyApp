//
//  NoticeCell.swift
//  Elias Family
//
//  Created by Abraham  Elias on 19/1/19.
//  Copyright © 2019 Abraham  Elias. All rights reserved.
//

import UIKit

class NoticeCell: UICollectionViewCell {
    // Links
    
    @IBOutlet weak var Title: UILabel!
    @IBOutlet weak var Author: UILabel!
    @IBOutlet weak var Message: UILabel!
    @IBOutlet weak var Time: UILabel!
    
    func setUp(notice: HomeNotices){
        // Sets the text labels
        let unixTstamp = (notice._time! as NSString).doubleValue
        Time.text = TimeStuff.unixStampToTime(stamp: unixTstamp)
        Title.text = notice._title
        Author.text = "By: \(notice._userId ?? "")"
        
        Message.text = notice._message
        Message.sizeToFit()
        
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }
}
