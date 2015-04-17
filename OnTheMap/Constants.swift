//
//  Constants.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/9/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    
    static let signUpURLString: String = "https://www.udacity.com/account/auth#!/signin"
    
    static let TimerIntervalRequests: NSTimeInterval = 0.5
    static let BatchRequestSize = 100 // try with 10
    
    struct UI {
        static let inactiveViewAlpha: CGFloat = 0.8
        static let activeViewAlpha: CGFloat = 1.0
        static let LEFT_PADDING_FOR_TEXTFIELD:CGFloat = 5
        static let KEYBOARD_MARGIN:CGFloat = 8
    }
    struct StoryboardID {
        static let MapAndTabView = "MapAndTabView"
        static let LocationDetailView = "LocationDetailView"
        
    }
}