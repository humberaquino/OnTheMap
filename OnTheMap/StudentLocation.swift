//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/11/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation

class StudentLocation: NSObject {

    var objectId: String?
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
    
    var title: String {
        return "\(firstName) \(lastName)"
    }
    
    
    
    init(objectId: String?, uniqueKey: String,
        firstName: String, lastName: String,
        mapString: String, mediaURL: String,
        latitude: Double, longitude: Double) {
            self.objectId = objectId
            self.uniqueKey = uniqueKey
            self.firstName = firstName
            self.lastName = lastName
            self.mapString = mapString
            self.mediaURL = mediaURL
            self.latitude = latitude
            self.longitude = longitude
            super.init()
    }
    
    convenience init( uniqueKey: String,
        firstName: String, lastName: String,
        mapString: String, mediaURL: String,
        latitude: Double, longitude: Double) {
            self.init(objectId: nil, uniqueKey: uniqueKey,
                firstName: firstName, lastName: lastName,
                mapString: mapString, mediaURL: mediaURL,
                latitude: latitude, longitude: longitude)
    }
    
    func toJSON() -> NSDictionary {
        var jsonDictionary = [
            "uniqueKey": uniqueKey,
            "firstName": firstName,
            "lastName": lastName,
            "mapString": mapString,
            "mediaURL": mediaURL,
            "latitude": latitude,
            "longitude": longitude
        ] as NSMutableDictionary
        
        if objectId != nil {
            jsonDictionary.setValue(objectId!, forKey: "objectId")
        }
        
        return jsonDictionary
    }
    
    
    
    class func buildStudentLocationList(jsonArray: NSArray, inout error: NSError?) -> [StudentLocation]? {
        var resultList: [StudentLocation] = []
        
        jsonArray.enumerateObjectsUsingBlock { (element, IndexingGenerator, stop) -> Void in
            
            let studentLocationDictionary = element as! NSDictionary
            
            var jsonError: NSError? = nil
            var studentLocation = self.buildStudentLocation(studentLocationDictionary, error: &jsonError)
            if let existingError = jsonError {
                error = existingError
                // Stop the iteration
                stop.initialize(true)
                return
            }
            
           resultList.append(studentLocation!)
        }
        return resultList
    }
    
    class func buildStudentLocation(json: NSDictionary, inout error: NSError?) -> StudentLocation? {
        
        let objectId = json["objectId"] as! String
        let uniqueKey = json["uniqueKey"] as! String
        let firstName = json["firstName"] as! String
        let lastName = json["lastName"] as! String
        let mapString = json["mapString"] as! String
        let mediaURL = json["mediaURL"] as! String
        
        // TODO: Parse with NSNumberFormatter
        
        let latitude = json["latitude"] as! Double
        let longitude = json["longitude"] as! Double

        let studentLocation = StudentLocation(objectId: objectId, uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude)
        
        return studentLocation
    }
    
}