//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/11/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation

class ParseClient: NSObject {

    let parseBaseHeaders = [
        "X-Parse-Application-Id": Constants.ParseApplicationId,
        "X-Parse-REST-API-Key": Constants.ParseRestAPIKey
    ]
    
    let httpClient: HTTPClient
    
    var userID : String? = nil
    
    override init() {
        httpClient = HTTPClient.sharedInstance
        super.init()
    }
    
    
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
    
    // FIXME: Deprecated
    func fetchStudentsInformation(fetchComplete: (result: [StudentInformation]?, error: NSError?) -> Void) {
        
        let parameters = [ "limit" : Constants.MaxStudentsInformation ]
        
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

extension ParseClient {
    // MARK: - Constants
    struct Constants {
        
        // MARK: URLs
        static let BaseURLSecure : String = "https://api.parse.com/"
        
        static let ParseApplicationId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ParseRestAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        static let MaxStudentsInformation = 100
    }
    //Parse Application ID = QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr
//    REST API Key = QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY
    
    // MARK: - Methods
    struct Methods {
        
        // MARK:
        static let StudentLocation = "1/classes/StudentLocation"
        
    }
    
    struct ResponseCodes {
        static let Created = 201
        static let Updated = 200
    }
}