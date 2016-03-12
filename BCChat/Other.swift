//
//  Other.swift
//  BCChat
//
//  Created by Brian Wang on 3/12/16.
//  Copyright © 2016 BC. All rights reserved.
//

import Foundation

//===========================================================================
//MARK: - NSDATE COMPARISION EXTENSION
//===========================================================================
extension NSDate: Comparable { }

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.isEqualToDate(rhs)
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}