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
    var date:NSDate = NSDate()
    var fbid:String = "nil"
    var platform:String = "nil"
    
    func dateString() -> String {
        return Message.dateFormatter.stringFromDate(date)
    }
    
}
