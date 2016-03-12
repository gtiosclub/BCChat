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
    
    var name:String = "Anonymous"
    var message:String = ""
    var timeStamp:String = ""
    var uid:String = "nil"
    var platform:String = "nil"
    
    func date() -> NSDate {
        let t = NSTimeInterval.init(timeStamp)
        return NSDate(timeIntervalSince1970: t!/1000)
    }
    
    func dateString() -> String {
        return Message.dateFormatter.stringFromDate(date())
    }
    
}
