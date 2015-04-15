//
//  UIUtils.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/12/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation
import UIKit




// FIXME: MOve this to a nother file

extension NSObject {
    func performOnMainQueue(callback: () -> Void) {
        dispatch_async(dispatch_get_main_queue(), callback)
        return
    }
}

extension Dictionary {
    mutating func merge<K, V>(dict: [K: V]){
        for (k, v) in dict {
            self.updateValue(v as! Value, forKey: k as! Key)
        }
    }
}


