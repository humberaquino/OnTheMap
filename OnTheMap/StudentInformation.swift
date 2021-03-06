//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/11/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation
import CoreLocation


// Main model class used to hold student information to display on the map and the tabbed list
class StudentInformation: NSObject {

    var objectId: String?
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
    
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    var title: String {
        return "\(firstName) \(lastName)"
    }
    
    init(dictionary: [String: AnyObject]) {
        self.uniqueKey = dictionary["uniqueKey"] as! String
        self.firstName = dictionary["firstName"] as! String
        self.lastName = dictionary["lastName"] as! String
        self.mapString = dictionary["mapString"] as! String
        self.mediaURL = dictionary["mediaURL"] as! String
        self.latitude = dictionary["latitude"] as! Double
        self.longitude = dictionary["longitude"] as! Double
        super.init()
    }
    
    convenience init(objectId: String, dictionary: [String: AnyObject]) {
        self.init(dictionary: dictionary)
        self.objectId = objectId        
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
    
    
    // MARK: - Utility functions
    
    // Build a list of StudentInformation out of a proper jsonArray
    class func buildStudentInformationList(jsonArray: NSArray, inout error: NSError?) -> [StudentInformation]? {
        var resultList: [StudentInformation] = []
        
        jsonArray.enumerateObjectsUsingBlock { (element, IndexingGenerator, stop) -> Void in
            
            let studentInformationDictionary = element as! NSDictionary
            
            var jsonError: NSError? = nil
            var studentLocation = self.buildStudentInformation(studentInformationDictionary, error: &jsonError)
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
    
    // Build one StudentInformation out of a proper json
    class func buildStudentInformation(json: NSDictionary, inout error: NSError?) -> StudentInformation? {
        
        let dictionary = json as! [String: AnyObject]
        let objectId = json["objectId"] as! String

        let studentInformation = StudentInformation(objectId: objectId, dictionary: dictionary)
        
        return studentInformation
    }
    
    
}