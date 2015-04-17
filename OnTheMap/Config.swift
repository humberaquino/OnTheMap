//
//  Configu.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/17/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation


struct Config {
    
    struct Parse {
        static let ApplicationId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RestAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        // Amount of Students that a request will try to get in a single request to Parse
        static let BatchRequestSize = 100
    }
    
    struct Network {
        // Seconds between compound requests. E.g. PaginatedParseClient
        static let TimerIntervalRequests: NSTimeInterval = 0.5
        
        // Amount of seconds after a request timeouts
        static let RequestTimeoutSeconds = 30
    }
    
}