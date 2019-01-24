//
//  ShoppingFormViewController.swift
//  Elias Family
//
//  Created by Abraham  Elias on 21/1/19.
//  Copyright © 2019 Abraham  Elias. All rights reserved.
//

import UIKit
// Needed for DB integration
import AWSCore
import AWSDynamoDB

class ShoppingFormViewController: UIViewController {
    // Outlets
    @IBOutlet weak var desc: UITextField!
    @IBOutlet weak var name: UITextField!
    
    let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func cancelButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func addButton(_ sender: UIButton) {
        if (name.text?.description.isEmpty)!{
            // Alert
            let msg = "You cannot have an empty title"
            let alert = UIAlertController(title: "Title Error", message: msg, preferredStyle: UIAlertController.Style.alert)
            // Add ok button and define press action
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            // Present the alert
            self.present(alert, animated: true, completion: nil)
            
        } else {
            // Build new item
            var newDesc = desc.text?.description
            if newDesc!.isEmpty{newDesc = "No description provided"}
            let newName = name.text?.description
            
            let newItem = ShoppingItem()
            newItem?._description = newDesc
            newItem?._title = newName
            newItem?._time = "\(Date().timeIntervalSince1970)"
            newItem?._userId = UIDevice.current.name
            newItem?._purchased = false
            
            // Upload to DB
            var success = true
            dynamoDBObjectMapper.save(newItem!).continueWith(block: { (task:AWSTask<AnyObject>!) -> Void in
                if let error = task.error as NSError? {
                    print("The request failed. Error: \(error)")
                    success = false
                }
            }).waitUntilFinished()
            if success {
                // Creating an alert
                DispatchQueue.main.async(execute: {
                    let alertWindow = UIWindow(frame: UIScreen.main.bounds)
                    alertWindow.rootViewController = UIViewController()
                    alertWindow.windowLevel = UIWindow.Level.alert + 1
                    
                    let alert2 = UIAlertController(title: "Success", message: "Your new item has been added.", preferredStyle: .alert)
                    let defaultAction2 = UIAlertAction(title: "OK", style: .default, handler: { action in
                    })
                    alert2.addAction(defaultAction2)
                    alertWindow.makeKeyAndVisible()
                    alertWindow.rootViewController?.present(alert2, animated: true, completion: nil)
                })
            }
            dismiss(animated: true, completion: nil)
        }
    }
}
