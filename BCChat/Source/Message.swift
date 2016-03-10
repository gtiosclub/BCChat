//
//  Message.swift
//  BCChat
//
//  Created by Brian Wang on 3/9/16.
//  Copyright © 2016 BC. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Message {
    static var dateFormatter:NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "M/DD/YY h:mm a"
        return dateFormatter
    }()
    
    var username:String = "nil"
    var message:String = "nil"
    var date:String = Message.dateFormatter.stringFromDate(NSDate())
    
    func toDictionary() -> [String: AnyObject?] {
        return [
            "username":username,
            "message":message,
            "date":date
        ]
    }
    
}
