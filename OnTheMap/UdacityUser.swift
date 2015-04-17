//
//  UdacityUser.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/12/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation

// Info that Udacity login provides after login
struct UdacityUser {
    let userID: String
    let firstName: String
    let lastName: String

    init(userID: String, firstName: String, lastName: String) {
        self.userID = userID
        self.firstName = firstName
        self.lastName = lastName
    }
}

