//
//  HomeViewController.swift
//  Elias Family
//
//  Created by Abraham  Elias on 28/11/18.
//  Copyright © 2018 Abraham  Elias. All rights reserved.
//

import UIKit
// Needed for DB integration
import AWSCore
import AWSDynamoDB

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // Outlet to the collection
    @IBOutlet weak var collectionView: UICollectionView!
    // Array that holds all the notices
    var notices:[HomeNotices] = []
    // Object mapper
    let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fillArrayWithNotices()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fillArrayWithNotices()
    }
    
    //Querys the DB and loads data
    func fillArrayWithNotices() {
        // Only works if interent is available
        if Reachability.isConnectedToNetwork(){
            notices.removeAll()
            
            let scanExpression = AWSDynamoDBScanExpression()
            
            dynamoDBObjectMapper.scan(HomeNotices.self, expression: scanExpression).continueWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Void in
                if let error = task.error as NSError? {
                    print("The request failed. Error: \(error)")
                } else if let paginatedOutput = task.result {
                    for n in paginatedOutput.items as! [HomeNotices] {
                        self.notices.append(n) // adds all the results to the notices array
                    }
                }
                
            }).waitUntilFinished()
            // Sorts the array so newest feeding is at top
            notices.sort {
                ($0._time! as NSString).doubleValue < ($1._time! as NSString).doubleValue
            }
            // Removes any notices that are expired
            notices = notices.filter{($0._death! as NSString).doubleValue > Date().timeIntervalSince1970}
            collectionView.reloadData()
            
        } else { // Generate connection alert if no internet
            // Build the alert
            let msg = "No internet connection. Unable to load feeding times."
            let alert = UIAlertController(title: "Connection Error", message: msg, preferredStyle: UIAlertController.Style.alert)
            
            // Add ok button and define press action
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            // Present the alert
            present(alert, animated: true, completion: nil)
        }
    }
    
    // The below two function are necessary for the table
    // Number of rows in table = length of array
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.notices.count
    }
    // This function runs for each cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // retrieve the feeding from the array
        let notice = self.notices[notices.count - indexPath.row - 1]
        
        // create a cell of type NoticeCell, from the "Ncell" template
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Ncell", for: indexPath) as! NoticeCell
        
        // setup the cell by passing it the notice we retrieved above
        cell.setUp(notice: notice)
        
        return cell
    }
    

}
