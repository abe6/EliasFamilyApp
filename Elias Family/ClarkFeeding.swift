//
//  ClarkFeeding.swift
//  MySampleApp
//
//
// Copyright 2019 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
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
class ClarkFeeding: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _time: String?
    var _imageNum: String?
    
    class func dynamoDBTableName() -> String {

        return "eliasfamilyapp-mobilehub-1549786070-ClarkFeeding"
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
               "_imageNum" : "imageNum",
        ]
    }
}
