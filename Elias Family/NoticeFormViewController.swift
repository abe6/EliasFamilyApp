//
//  NoticeFormViewController.swift
//  Elias Family
//
//  Created by Abraham  Elias on 19/1/19.
//  Copyright © 2019 Abraham  Elias. All rights reserved.
//

import UIKit
// Needed for DB integration
import AWSCore
import AWSDynamoDB

class NoticeFormViewController: UIViewController, UITextViewDelegate {
    //Links to objects
    @IBOutlet weak var titlee: UITextField!
    @IBOutlet weak var textBox: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textBox.text = "Write Your Message Here"
        textBox.textColor = UIColor.lightGray
        textBox.delegate = self
        
        datePicker.minimumDate = NSDate() as Date
        hideKeyboardWhenTappedAround()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func exitForm(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitForm(_ sender: UIButton) {
        let date = "\(Date().timeIntervalSince1970)"
        let expiry = "\(datePicker.date.timeIntervalSince1970 + 15000)"
        var title = titlee.text?.description ?? ""
        if title.isEmpty{title = "untitled"}
        let message = textBox.text.description
        let user = UIDevice.current.name
        
        let newNotice = HomeNotices()
        newNotice?._death = expiry
        newNotice?._time = date
        newNotice?._userId = user
        newNotice?._title = title
        newNotice?._message = message
        
        var success = true
        dynamoDBObjectMapper.save(newNotice!).continueWith(block: { (task:AWSTask<AnyObject>!) -> Void in
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
                
                let alert2 = UIAlertController(title: "Success", message: "Your notice has been posted.", preferredStyle: .alert)
                let defaultAction2 = UIAlertAction(title: "OK", style: .default, handler: { action in
                })
                alert2.addAction(defaultAction2)
                
                alertWindow.makeKeyAndVisible()
                
                alertWindow.rootViewController?.present(alert2, animated: true, completion: nil)
            })
        }
        dismiss(animated: true, completion: nil)
    }
    
    //Functions for setting and removing placeholder text in textbox
    func textViewDidBeginEditing(_ textBox: UITextView) {
        if textBox.textColor == UIColor.lightGray {
            textBox.text = nil
            textBox.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textBox: UITextView) {
        if textBox.text.isEmpty {
            textBox.text = "Write Your Message Here"
            textBox.textColor = UIColor.lightGray
        }
    }
}
