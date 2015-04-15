//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/9/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    // MARK: - Constants
    struct Constants {
        
        // MARK: URLs
        static let BaseURLSecure : String = "https://www.udacity.com/"
        static let UdacitySkipChars = 5
    }
    
    // MARK: - Methods
    struct Methods {
        
        // MARK: Authentication
        static let Session = "api/session"
        
        // MARK: User data
        static let PublicUserData = "api/users/{id}"
    }
    
    // MARK: - URL Keys
    struct URLKeys {
        
        static let UserID = "id"
        
    }
    
    // MARK: - JSON Body Keys
    struct JSONBodyKeys {
        
        static let Username = "username"
        static let Password = "password"
        
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: Authorization
        static let Account = "account"
        static let Key = "key"
        static let Registered = "registered"
        static let User = "user"
        static let StatusMessage = "FIXME"
        static let FirstName = "first_name"
        static let LastName = "last_name"
        static let Error = "error"
    }
    
}