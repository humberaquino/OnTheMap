//
//  URLUtils.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/15/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation
import UIKit

struct URLUtils {
    // Opens a URL in the browser
    static func openURL(string urlString: String) -> Bool {
        if let url = NSURL(string: urlString) {
            UIApplication.sharedApplication().openURL(url)
            return true
        } else {
            return false
        }
    }
}