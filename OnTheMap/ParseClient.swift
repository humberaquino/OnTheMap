//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/11/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation

// Client used to do single requests to the Parse API
class ParseClient: NSObject {

    let parseBaseHeaders = [
        "X-Parse-Application-Id": Config.Parse.ApplicationId,
        "X-Parse-REST-API-Key": Config.Parse.RestAPIKey
    ]
    
    let httpClient: HTTPClient    
    
    override init() {
        httpClient = HTTPClient.sharedInstance
        super.init()
    }
    
    
    // Fetch StudentInformation paginated using the Parse API
    func fetchStudentsInformationPaginated(skip: Int, limit: Int, fetchComplete: (result: [StudentInformation]?, error: NSError?) -> Void) {
        
        let parameters = [
            "limit" : limit,
            "skip": skip
        ]
        
        httpClient.jsonTaskForGETMethod(Constants.BaseURLSecure, method: Methods.StudentLocation ,
            parameters: parameters, headers: parseBaseHeaders, taskCompleteHandler: { (jsonResponse, response, taskError) in
                if let existingError = taskError {
                    // Error during the GET request/response
                    fetchComplete(result: nil, error: existingError)
                    return
                }
                
                // Asume a "results" array in the JSON response
                let resultsArray = jsonResponse["results"] as! NSArray
                
                // Build StudentLocation array based on the JSON response
                var buildError: NSError? = nil
                var studentLocations:[StudentInformation]? = StudentInformation.buildStudentInformationList(resultsArray, error: &buildError)
                
                if let existingError = buildError {
                    // Error while building the array og StudentLocations. Check the JSON Response and buildStudentLocationList method
                    fetchComplete(result: nil, error: existingError)
                    return
                }
                
                // Success
                fetchComplete(result: studentLocations, error: nil)
        })
        
    }
    
    // Count the amount of Students
    func countStudentsInformation(fetchComplete: (count: Int!, error: NSError!) -> Void) {

        let parameters = [
            "limit" : 0,
            "count": 1
        ]
        
        httpClient.jsonTaskForGETMethod(Constants.BaseURLSecure, method: Methods.StudentLocation ,
            parameters: parameters, headers: parseBaseHeaders, taskCompleteHandler: { (jsonResponse, response, taskError) in
                if let existingError = taskError {
                    // Error during the GET request/response
                    fetchComplete(count: nil, error: existingError)
                    return
                }
                
                // Asume count is a Integer
                let count = jsonResponse["count"] as! Int
                
                // Success
                fetchComplete(count: count, error: nil)
        })

    }
        
    // Do a PSOT to create a Student information
    func createStudentInformation(studentLocation: StudentInformation, completitionHandler: (objectId: String!, error: NSError!) -> Void) {
       
        
        let jsonBody = studentLocation.toJSON()
        
        httpClient.jsonTaskForPOSTMethod(Constants.BaseURLSecure, method: Methods.StudentLocation,
            parameters: nil, headers: parseBaseHeaders, body: jsonBody) {
                (jsonResponse, response, error) -> Void in
                if let existingError = error {
                    completitionHandler(objectId: nil, error: existingError)
                    return
                }
                let httpResponse = response as! NSHTTPURLResponse
                
                if httpResponse.statusCode == ParseClient.ResponseCodes.Created {
                    // Student lotation Created
                    if let objectId = jsonResponse["objectId"] as? String {
                        // Success
                        completitionHandler(objectId: objectId, error: nil)
                    } else {
                        let unexpectedError = ErrorUtils.errorUnexpectedWith("Student location created but no objectId returned")
                        completitionHandler(objectId: nil, error: unexpectedError)
                    }
                } else {
                    // Unexpected error
                    let unexpectedError = ErrorUtils.errorUnexpectedWith("Server status code response is \(httpResponse.statusCode)")
                    completitionHandler(objectId: nil, error: unexpectedError)
                }
                
        }

    }
    
    // Do a PUT to update the student information
    func updateStudentInformation(studentInformation: StudentInformation, completitionHandler: (success: Bool, error: NSError!) -> Void) {
        
        
        let jsonBody = studentInformation.toJSON()
        
        let method = "\(Methods.StudentLocation)/\(studentInformation.objectId!)"
        
        httpClient.jsonTaskForPUTMethod(Constants.BaseURLSecure, method: method, parameters: nil, headers: parseBaseHeaders, body: jsonBody) {
                (jsonResponse, response, error) -> Void in
                if let existingError = error {
                    completitionHandler(success: false, error: existingError)
                    return
                }
                let httpResponse = response as! NSHTTPURLResponse
                
                if httpResponse.statusCode == ParseClient.ResponseCodes.Updated {
                    // Student lotation updated
                    completitionHandler(success: true, error: nil)
                } else {
                    // Unexpected error
                    let unexpectedError = ErrorUtils.errorUnexpectedWith("Server status code response is \(httpResponse.statusCode)")
                    completitionHandler(success: false, error: unexpectedError)
                }
        }
    }
    
}
