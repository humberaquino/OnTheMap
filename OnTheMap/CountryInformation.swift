//
//  CountryInformation.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/15/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation

class CountryInformation: NSObject {
    
    let name: String
    let count: Int
    
    init(name: String, count: Int) {
        self.name = name
        self.count = count
    }
    
}