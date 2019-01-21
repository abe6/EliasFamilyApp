//
//  ShoppingListViewController.swift
//  Elias Family
//
//  Created by Abraham  Elias on 28/11/18.
//  Copyright © 2018 Abraham  Elias. All rights reserved.
//

import UIKit
// Needed for DB integration
import AWSCore
import AWSDynamoDB

class ShoppingListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // Outlet to the collection
    @IBOutlet weak var collectionView: UICollectionView!
    // Array that holds the items
    var items:[ShoppingItem] = []
    // Object Mapper
    let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fillArrayWithItems()
    }
    
    //Querys the DB and loads data
    func fillArrayWithItems() {
        // Only works if interent is available
        if Reachability.isConnectedToNetwork(){
            items.removeAll()
            
            let scanExpression = AWSDynamoDBScanExpression()
            
            dynamoDBObjectMapper.scan(ShoppingItem.self, expression: scanExpression).continueWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Void in
                if let error = task.error as NSError? {
                    print("The request failed. Error: \(error)")
                } else if let paginatedOutput = task.result {
                    for i in paginatedOutput.items as! [ShoppingItem] {
                        self.items.append(i) // adds all the results to the array
                    }
                }
                
            }).waitUntilFinished()
            // Sorts the array so newest item is at top
            items.sort {
                ($0._time! as NSString).doubleValue < ($1._time! as NSString).doubleValue
            }
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
    
    // Last cell tapped is set by function at bottom
    var lastClicked:ShoppingItem? = nil
    @IBAction func itemTrash(_ sender: UIButton) {
        if lastClicked != nil {
            // Build the alert
            let msg = "Are you sure youd like to delete the shopping item \(self.lastClicked?._title?.description ?? "")"
            let alert = UIAlertController(title: "Delete this shopping item?", message: msg, preferredStyle: UIAlertController.Style.alert)
            
            // add delete button and define action
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.default, handler: { (action) in
                // remove from db
                var success = true
                self.dynamoDBObjectMapper.remove(self.lastClicked!).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
                    if let error = task.error as NSError? {
                        print("The request failed. Error: \(error)")
                        success = false
                    }
                    return nil
                })
                alert.dismiss(animated: true, completion: nil)
                if success { // Alert
                    let msg = "The shopping item has been deleted"
                    let alert = UIAlertController(title: "Success", message: msg, preferredStyle: UIAlertController.Style.alert)
                    
                    // Add ok button and define press action
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    //remove from array
                    self.items.remove(at: self.items.lastIndex(of: self.lastClicked!)!)
                    self.lastClicked = nil
                    self.clearInfoDisplay()
                    self.collectionView.reloadData()
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
    
    
    
    // The below two function are necessary for the table
    // Number of rows in table = length of array
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    // This function runs for each cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // retrieve the feeding from the array
        let item = self.items[items.count - indexPath.row - 1]
        
        // create a cell of type ShoppingItemCelll, from the "Scell" template
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Scell", for: indexPath) as! ShoppingItemCell
        
        // setup the cell by passing it the notice we retrieved above
        cell.setUp(item: item)
        
        return cell
    }
    
    // Outlets for the below functions
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemDescription: UILabel!
    @IBOutlet weak var purchased: UILabel!
    @IBOutlet weak var addedBy: UILabel!
    @IBOutlet weak var addedOn: UILabel!
    
    func clearInfoDisplay(){
        itemName.text = "Item Name:"
        itemDescription.text = "Description:"
        addedBy.text = "Added By:"
        addedOn.text = "Added On:"
        purchased.text = "Purchased:"
    }
    // Runs when a cell has been tapped
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Detect which item was selected
        let i = (items.count - indexPath.row) - 1
        let item = items[i]
        
        lastClicked = item
        
        itemName.text = "Item Name: \(item._title?.description ?? "")"
        itemDescription.text = "Description: \(item._description?.description ?? "")"
        addedBy.text = "Added By: \(item._userId?.description ?? "")"
        
        let unixTstamp = (item._time! as NSString).doubleValue
        let time = TimeStuff.unixStampToTime(stamp: unixTstamp)
        addedOn.text = "Added On: \(time)"
        
        let pp = item._purchased?.boolValue
        if pp! {purchased.text = "Purchased: Yes"} else {purchased.text = "Purchased: No"}
    }
}
