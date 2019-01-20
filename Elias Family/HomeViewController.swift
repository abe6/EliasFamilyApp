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
    // Run when a cell is tapped
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Detect which notice was selected
        let i = (notices.count - indexPath.row) - 1
        let notice = notices[i]
        
        if notice._userId?.description != UIDevice.current.name {
            let msg = "This is not your notice and so you can not edit it."
            let alert = UIAlertController(title: "No.", message: msg, preferredStyle: UIAlertController.Style.alert)
            
            // Add ok button and define press action
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            // Present the alert
            present(alert, animated: true, completion: nil)
            
        } else {
        
            // Build the alert
            let msg = "What would you like to do?"
            let alert = UIAlertController(title: "Change this note?", message: msg, preferredStyle: UIAlertController.Style.alert)
            
            // Add ok button and define press action
            alert.addAction(UIAlertAction(title: "Edit", style: UIAlertAction.Style.default, handler: { (action) in
                /// EDIT
                alert.dismiss(animated: true, completion: nil)
                self.editNotice(old: notice, i: i)
            }))
            
            // add delete button and define action
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.default, handler: { (action) in
                // remove from db
                var success = true
                self.dynamoDBObjectMapper.remove(notice).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
                    if let error = task.error as NSError? {
                        print("The request failed. Error: \(error)")
                        success = false
                    }
                    return nil
                })
                alert.dismiss(animated: true, completion: nil)
                if success { // Alert
                    let msg = "Your notice has been successfully deleted."
                    let alert = UIAlertController(title: "Success", message: msg, preferredStyle: UIAlertController.Style.alert)
                    
                    // Add ok button and define press action
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    //remove from array
                    self.notices.remove(at: i)
                    collectionView.reloadData()
                    // Present the alert
                    self.present(alert, animated: true, completion: nil)
                }
            }))
            
            // Add cancel button and define press action
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            // Present the alert
            present(alert, animated: true, completion: nil)
        }
    }
    
    // Edits a post
    func editNotice(old: HomeNotices, i: Int){
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Edit", message: "Edit your title and message below", preferredStyle: .alert)
        
        //2. Add the text field. first title, then message
        alert.addTextField { (textField) in
            textField.text = old._title?.description
        }
        alert.addTextField { (textField) in
            textField.text = old._message?.description
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let newTitle = alert?.textFields![0]
            let newMessage = alert?.textFields![1]
            
            old._message = newMessage?.text
            old._title = newTitle?.text
            
            var success = true
            self.dynamoDBObjectMapper.save(old).continueWith(block: { (task:AWSTask<AnyObject>!) -> Void in
                if let error = task.error as NSError? {
                    print("The request failed. Error: \(error)")
                    success = false
                }
            }).waitUntilFinished()
            if success { // Alert
                let msg = "Your notice has been successfully updated."
                let alert = UIAlertController(title: "Success", message: msg, preferredStyle: UIAlertController.Style.alert)
                
                // Add ok button and define press action
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                // Present the alert
                self.present(alert, animated: true, completion: nil)
                
                //update the array
                self.notices[i] = old
                self.collectionView.reloadData()
                
            }
            
            
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }

}
