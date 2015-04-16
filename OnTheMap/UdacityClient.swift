//
//  HTTPClient.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/9/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation

// Udacity's HTTP client. Used for authentication
// Ref: https://docs.google.com/document/u/0/d/1PHrIYRhl3r5jvRkuLvL0k6Rmws3H7NO1UAMnF5SoKXs/pub?embedded=true
class UdacityClient : NSObject {
    
    let httpClient: HTTPClient

    
    override init() {
        httpClient = HTTPClient.sharedInstance
        super.init()
    }
    
    // MARK: - Main client methods. All completition handlers are executed on main queue
    
    func authToUdacityUsingFacebook(token: String, completitionHandler: (udacityUser: UdacityUser?, error: (title: String, message: String)?) -> Void) {
        
        loginToUdacityUsingFacebook(token) { (userID, loginError) -> Void in
            if let existingError = loginError {
                // Login error
                let errorTuple = ErrorUtils.errorToTuple(existingError)
                self.performOnMainQueue {
                    completitionHandler(udacityUser: nil, error: errorTuple)
                }
                return
            }
            
            self.getPublicUserData(userID!, userDataCompleteHandler: { (udacityUser, userDataError) -> Void in
                if let existingError = userDataError {
                    // getting public user data error
                    let errorTuple = ErrorUtils.errorToTuple(existingError)
                    self.performOnMainQueue {
                        completitionHandler(udacityUser: nil, error: errorTuple)
                    }
                    return
                }
                
                // Success
                completitionHandler(udacityUser: udacityUser, error: nil)
            })
            
        }
    }
    
    func authToUdacityDirectly(username: String, password: String, completitionHandler: (udacityUser: UdacityUser?, error: (title: String, message: String)?) -> Void) {
      
        loginToUdacityDirectly(username, password: password) { (userID, loginError) -> Void in
            if let existingError = loginError {
                // Login error
                let errorTuple = ErrorUtils.errorToTuple(existingError)
                self.performOnMainQueue {
                    completitionHandler(udacityUser: nil, error: errorTuple)
                }
                return
            }
            
            self.getPublicUserData(userID!, userDataCompleteHandler: { (udacityUser, userDataError) -> Void in
                if let existingError = userDataError {
                    // getting public user data error
                    let errorTuple = ErrorUtils.errorToTuple(existingError)
                    self.performOnMainQueue {
                        completitionHandler(udacityUser: nil, error: errorTuple)
                    }
                    return
                }
                
                // Success
                completitionHandler(udacityUser: udacityUser, error: nil)                
            })
            
        }
    }
    
    // For a logged user, gets it's udacity data
    func getPublicUserData(userID: String, userDataCompleteHandler: (udacityUser: UdacityUser?, error: NSError?) -> Void){
        
        // Success. Save the userID and notify the success
        let method = HTTPClient.subtituteKeyInMethod(Methods.PublicUserData, key: "id", value: userID)!
        
        // Get the user data unisg this ID
        httpClient.jsonSkipDataCharsTaskForGETMethod(Constants.BaseURLSecure, method: method,
            parameters: nil, headers: nil, skipChars: Constants.UdacitySkipChars) {
            (jsonResponse, response, error) -> Void in
            
            if let existingError = error {
                userDataCompleteHandler(udacityUser: nil, error: existingError)
                return
            }
            
            var userParseError: NSError? = nil
            if let udacityUser = self.parseUdacityUser(userID, json: jsonResponse, error: &userParseError) {
                // Add the ID to the udacity user
                
                self.performOnMainQueue {
                    userDataCompleteHandler(udacityUser: udacityUser, error: nil)
                }
                
            } else {
                // Error while parsing the Udacity user
                self.performOnMainQueue {
                    userDataCompleteHandler(udacityUser: nil, error: userParseError)
                }
                
            }
        }
       
    }
    
    // Login using a facebook token
    func loginToUdacityUsingFacebook(token: String, loginCompleteHandler: (userID: String?, error: NSError?) -> Void) {
        let jsonBody = [
            "facebook_mobile" : [
                "access_token": token
            ]
        ] as NSDictionary
        
        loginToUdacityUsingJSONBody(jsonBody, loginCompleteHandler: loginCompleteHandler)
    }
    
    // Username and password login
    func loginToUdacityDirectly(username: String, password: String, loginCompleteHandler: (userID: String?, error: NSError?) -> Void) {
        let jsonBody = [
            "udacity" : [
                "username": username,
                "password": password
            ]
        ] as NSDictionary
        
        loginToUdacityUsingJSONBody(jsonBody, loginCompleteHandler: loginCompleteHandler)
    }
    
    // Generic method used to login to udacity
    func loginToUdacityUsingJSONBody(jsonBody: NSDictionary, loginCompleteHandler: (userID: String?, error: NSError?) -> Void) {
        
        httpClient.jsonSkipDataCharsTaskForPOSTMethod(Constants.BaseURLSecure, method: Methods.Session, parameters: nil, headers: nil, body: jsonBody, skipChars: Constants.UdacitySkipChars) {
            (jsonResponse, response, error) -> Void in
            
            if let existingError = error {
                // Error: on POST
                self.performOnMainQueue {
                    loginCompleteHandler(userID: nil, error: existingError)
                }
                return
            }
            
            // Check response code
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if statusCode == 200 {
                // Success: Response OK
                var validationError: NSError? = nil
                if let userID = self.parseUserId(jsonResponse, error: &validationError) {
                    // Success
                    self.performOnMainQueue {
                        loginCompleteHandler(userID: userID, error: nil)
                    }
                } else {
                    // Error: Invalid JSON structure
                    self.performOnMainQueue {
                        loginCompleteHandler(userID: nil, error: validationError)
                    }
                }
            } else {
                // Unexpected response
                if let errorResponse = self.buildErrorFromJSONResponse(jsonResponse) {
                    self.performOnMainQueue {
                        loginCompleteHandler(userID: nil, error: errorResponse)
                    }
                } else {
                    // Could not parse JSON response 
                    self.performOnMainQueue {
                        let unexpectedError = ErrorUtils.errorUnexpectedWith("Could not parse error JSON response. Status code:\(statusCode)")
                        loginCompleteHandler(userID: nil, error: unexpectedError)
                    }
                }
            }
        }
    }
    
    // MARK: - Parse utilities
    

    func parseUdacityUser(userID: String, json: NSDictionary!, inout error: NSError?) -> UdacityUser? {
        var message = ""
        
        if json == nil {
            message = "The udacity user response is nil"
        } else {
            // Is a dictionary. Now check structure
            if let user = json[JSONResponseKeys.User] as? NSDictionary {
                
                let lastName = user[JSONResponseKeys.LastName] as! String
                let firstName = user[JSONResponseKeys.FirstName] as! String
                
                var udacityUser = UdacityUser(userID: userID, firstName: firstName, lastName: lastName)
                
                return udacityUser
            } else {
                message = "Invalid JSON Structure: \(json)"
            }
        }
        
        // Build error object and return as invalid (false)
        let userInfo = [NSLocalizedDescriptionKey : message]
        error =  NSError(domain: ErrorUtils.ErrorDomains.ServerError, code: ErrorUtils.ServerErrorCodes.UdacityJSONParsingError, userInfo: userInfo)
        return nil
    }
    
    func parseUserId(json: NSDictionary!, inout error: NSError?) -> String? {
        var message = ""
        
        if json == nil {
            message = "The JSON response is nil"
        } else {
            // Is a dictionary. Now check structure
            if let account = json[UdacityClient.JSONResponseKeys.Account] as? NSDictionary {
                if let registered = account[UdacityClient.JSONResponseKeys.Registered] as? Bool {
                    if let key = account[UdacityClient.JSONResponseKeys.Key] as? String {
                        // Success. Return the key value
                        return key
                    }
                }
               
            }
            message = "Invalid JSON Structure: \(json)"
        }
        
        // Build error object and return as invalid (false)
        let userInfo = [NSLocalizedDescriptionKey : message]
        error =  NSError(domain: ErrorUtils.ErrorDomains.ServerError, code: ErrorUtils.ServerErrorCodes.UdacityJSONParsingError, userInfo: userInfo)
        return nil
    }
    
    func buildErrorFromJSONResponse(json: NSDictionary) -> NSError? {
        if let errorMsg =  json[UdacityClient.JSONResponseKeys.Error] as? String {
            return ErrorUtils.errorUnexpectedWith(errorMsg)
        } else {
            return nil
        }
    }
}