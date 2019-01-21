//
//  ShoppingItem.swift
//  MySampleApp
//
//
// Copyright 2018 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.21
//

import Foundation
import UIKit
import AWSDynamoDB

@objcMembers
class ShoppingItem: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _time: String?
    var _description: String?
    var _purchased: NSNumber?
    var _title: String?
    
    class func dynamoDBTableName() -> String {

        return "eliasfamilyapp-mobilehub-1549786070-ShoppingItem"
    }
    
    class func hashKeyAttribute() -> String {

        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {

        return "_time"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
               "_userId" : "userId",
               "_time" : "time",
               "_description" : "description",
               "_purchased" : "purchased",
               "_title" : "title",
        ]
    }
}