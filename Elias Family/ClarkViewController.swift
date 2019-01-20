//
//  ClarkViewController.swift
//  Elias Family
//
//  Created by Abraham  Elias on 28/11/18.
//  Copyright © 2018 Abraham  Elias. All rights reserved.
//

import UIKit

// Needed for DB integration
import AWSCore
import AWSDynamoDB

class ClarkViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
    
    // FUNCTION RUN WHEN "I FED HIM" IS CLICKED
    @IBAction func addFeedClick(_ sender: UIButton) {
        // Determines how long ago the last feeding was
        let lastFedAt = Date(timeIntervalSince1970: (feedings.last?._time! as! NSString).doubleValue)
        let timeAgo = lastFedAt.timeIntervalSinceNow.magnitude
        
        // Build the alert
        let msg = "Last Feeding time was \(timeAgo.format(using: [.hour, .minute])!) ago."
        let alert = UIAlertController(title: "Are you sure?", message: msg, preferredStyle: UIAlertController.Style.alert)
        
        // Add ok button and define press action
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (action) in
            self.addToDatabase()
            alert.dismiss(animated: true, completion: nil)
        }))
        // Add cancel button and define press action
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        // Present the alert
        present(alert, animated: true, completion: nil)
    }
    
    // Array that holds all the feeding times
    var feedings:[ClarkFeeding] = []
    // Link to the table
    @IBOutlet weak var tableView: UITableView!
    // Pull to refresh obj
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillArrayWithFeedings()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    // Called when pulled to refresh
    @objc func refresh(_ sender: Any) {
        fillArrayWithFeedings()
        refreshControl.endRefreshing()
        print("Refreshed")
    }
    
    //Querys the DB and loads data
    func fillArrayWithFeedings() {
        // Only works if interent is available
        if Reachability.isConnectedToNetwork(){
            feedings.removeAll()
            
            let scanExpression = AWSDynamoDBScanExpression()
            scanExpression.limit = 10

            dynamoDBObjectMapper.scan(ClarkFeeding.self, expression: scanExpression).continueWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Void in
                if let error = task.error as NSError? {
                    print("The request failed. Error: \(error)")
                } else if let paginatedOutput = task.result {
                    for f in paginatedOutput.items as! [ClarkFeeding] {
                        self.feedings.append(f) // adds all the results to the feedings array
                    }
                }
                
            }).waitUntilFinished()
            // Sorts the array so newest feeding is at top
            feedings.sort {
                ($0._time! as NSString).doubleValue < ($1._time! as NSString).doubleValue
            }
            tableView.reloadData()
            
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
    
    // Generates a new feeding using the current time and the phones name
    // and uploads it to DynamoDB
    func addToDatabase(){
        let newFeeding = ClarkFeeding()
        newFeeding?._userId = UIDevice.current.name
        newFeeding?._time = "\(Date().timeIntervalSince1970)"
        
        var success = true
        dynamoDBObjectMapper.save(newFeeding!).continueWith(block: { (task:AWSTask<AnyObject>!) -> Void in
            if let error = task.error as NSError? {
                print("The request failed. Error: \(error)")
                success = false
            }
        }).waitUntilFinished()
        // After upload is done, add it to array and reload table
        if success {
            feedings.append(newFeeding!)
            tableView.reloadData()
        }
    }
    
    
    // The below two function are necessary for the table
    // Number of rows in table = length of array
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feedings.count
    }
    // This function runs for each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // retrieve the feeding from the array
        let feeding = self.feedings[feedings.count - indexPath.row - 1]
        // create a cell of type FeedingCell, from the "Fcell" template
        let cell = tableView.dequeueReusableCell(withIdentifier: "Fcell") as! FeedingCell
        // setup the cell by passing it the feeding we retrieved above
        cell.setUp(feeding: feeding)

        return cell
    }
    

}

