//
//  ParseExtensions.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/17/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation

extension ParseClient {
    
    struct Constants {
        // MARK: URLs
        static let BaseURLSecure : String = "https://api.parse.com/"
    }
    
    // MARK: - Methods
    struct Methods {
        
        static let StudentLocation = "1/classes/StudentLocation"
        
    }
    
    struct ResponseCodes {
        static let Created = 201
        static let Updated = 200
    }
}