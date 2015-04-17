//
//  HTTPClient.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/11/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation

// A "generic HTTP client" (at least for what this project currently needs) used by Udacity's and Parse's clients
class HTTPClient: NSObject {
    
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        // Override the timeout
        session.configuration.timeoutIntervalForRequest = Config.Network.TimerIntervalRequests
        super.init()
    }
    
    // MARK: -
    
    // MARK: POST JSON/NSDictionary based
    // All methods are JSON/NSDictionary based, which means that they receive and return NSDictionary objects
    // for the caller to handle it the way they need    

    func jsonSkipDataCharsTaskForPOSTMethod(baseURL: String,  method: String, parameters: [String : AnyObject]?, headers: [String: String]?, body: NSDictionary, skipChars: Int, taskCompleteHandler: (jsonResponse: NSDictionary!, response: NSURLResponse!, error: NSError!) -> Void) -> NSURLSessionDataTask! {
        
        // Parse the data body
        var dataError: NSError? = nil
        if let data = HTTPClient.dictionaryToData(body, error: &dataError) {
            // Success: NSDictionary to NSData complete
            
            let jsonPOSTHeaders = HTTPClient.jsonPOSTHeaders(headers)
            
            // Do POST task
            let task = skipDataCharsTaskForPOSTMethod(baseURL, method: method, parameters: parameters, headers: jsonPOSTHeaders, body: data, skipChars: skipChars) { (data, response, error) -> Void in
                if let existingError = error {
                    // Error: POST failed
                    taskCompleteHandler(jsonResponse: nil, response: response, error: error)
                    return
                }
                // Parse the data response
                var jsonError: NSError? = nil
                if let json = HTTPClient.dataToDictionary(data, error: &jsonError) {
                    // Success: parsing complete
                    taskCompleteHandler(jsonResponse: json, response: response, error: nil)
                } else {
                    // Error: Could not parse
                    taskCompleteHandler(jsonResponse: nil, response: response, error: jsonError)
                }
            }
            return task
        } else {
            // Error: Could not convert NSDictionary to NSData complete
            taskCompleteHandler(jsonResponse: nil, response: nil, error: dataError)
            return nil
        }
    }
    
    
    // POST Task method with a header dictionary and using JSON
    func jsonTaskForPOSTMethod(baseURL: String, method: String, parameters: [String : AnyObject]?, headers: [String: String]?, body: NSDictionary, taskCompleteHandler: (jsonResponse: NSDictionary!, response: NSURLResponse!, error: NSError!) -> Void) -> NSURLSessionDataTask! {
        
        let jsonPOSTHeaders = HTTPClient.jsonPOSTHeaders(headers)
        
        // Convert the NSDictioanry to NSData
        var jsonError: NSError? = nil
        if let data = HTTPClient.dictionaryToData(body, error: &jsonError) {

            // JSON Body is valid. Let's proceed to do the POST request
            let task = taskForPOSTMethod(baseURL, method: method, parameters: parameters, headers: jsonPOSTHeaders, body: data, taskCompleteHandler: { (data, response, error) -> Void in
                // POST Complete
                if let existingError = error {
                    // Error: During POST
                    taskCompleteHandler(jsonResponse: nil, response: response, error: existingError)
                    return
                }
                
                // Convert NSData to NSDictionary
                var dataError: NSError? = nil
                if let json = HTTPClient.dataToDictionary(data, error: &dataError) {
                    // Success
                    taskCompleteHandler(jsonResponse: json, response: response, error: nil)
                } else {
                    // Error while parsing json response
                    taskCompleteHandler(jsonResponse: nil, response: response, error: dataError)
                }
            })
            
            return task
        } else {
            // Error while converting the body JSON NSDictionary to NSData
            taskCompleteHandler(jsonResponse: nil, response: nil, error: jsonError)
            return nil
        }
    }
    
    
    // MARK: POST NSData based
    // All methods are NSData based, which means that they receive and return NSData objects for the caller to
    // handle the way they need
    
    // GET method that handles skipping characters in data response. Useful for Udacity responses.
    func skipDataCharsTaskForPOSTMethod(baseURL: String,  method: String, parameters: [String : AnyObject]?, headers: [String: String]?, body: NSData, skipChars: Int, taskCompleteHandler: (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void) -> NSURLSessionDataTask {
        
        let task = taskForPOSTMethod(baseURL, method: method, parameters: parameters, headers: headers, body:body) { (data, response, error) -> Void in
            self.handleSkipDataChars(skipChars, data: data, response: response, error: error, taskCompleteHandler: taskCompleteHandler)
        }
        
        return task
    }
    
    // The most generic POST task method
    func taskForPOSTMethod(baseURL: String, method: String, parameters: [String : AnyObject]?, headers: [String: String]?, body: NSData, taskCompleteHandler: (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void) -> NSURLSessionDataTask {
        
        // Build the URL and configure the request
        var urlString = baseURL + method
        
        // Concat the parameters if necesarry
        if let existingParameters = parameters {
            urlString += HTTPClient.escapedParameters(existingParameters)
        }
        
        // Build the Request
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = body
        
        // Add headers if necesary
        if let existingHeaders = headers {
            for (key, value) in existingHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Create the task
        let task = session.dataTaskWithRequest(request, completionHandler: taskCompleteHandler)
        
        // Start the request
        task.resume()
        
        return task
    }
    
    // MARK: -
    
    // MARK: PUT JSON/NSDictionary based
    // All methods are JSON/NSDictionary based, which means that they receive and return NSDictionary objects
    // for the caller to handle it the way they need
    
    // PUT Task method with a header dictionary and using JSON
    func jsonTaskForPUTMethod(baseURL: String, method: String, parameters: [String : AnyObject]?, headers: [String: String]?, body: NSDictionary, taskCompleteHandler: (jsonResponse: NSDictionary!, response: NSURLResponse!, error: NSError!) -> Void) -> NSURLSessionDataTask! {
        
        let jsonPOSTHeaders = HTTPClient.jsonPOSTHeaders(headers)
        
        // Convert the NSDictioanry to NSData
        var jsonError: NSError? = nil
        if let data = HTTPClient.dictionaryToData(body, error: &jsonError) {
            
            // JSON Body is valid. Let's proceed to do the PUT request
            let task = taskForPUTMethod(baseURL, method: method, parameters: parameters, headers: jsonPOSTHeaders, body: data, taskCompleteHandler: { (data, response, error) -> Void in
                // POST Complete
                if let existingError = error {
                    // Error: During PUT
                    taskCompleteHandler(jsonResponse: nil, response: response, error: existingError)
                    return
                }
                
                // Convert NSData to NSDictionary
                var dataError: NSError? = nil
                if let json = HTTPClient.dataToDictionary(data, error: &dataError) {
                    // Success
                    taskCompleteHandler(jsonResponse: json, response: response, error: nil)
                } else {
                    // Error while parsing json response
                    taskCompleteHandler(jsonResponse: nil, response: response, error: dataError)
                }
            })
            
            return task
        } else {
            // Error while converting the body JSON NSDictionary to NSData
            taskCompleteHandler(jsonResponse: nil, response: nil, error: jsonError)
            return nil
        }
    }
    
    
    // MARK: PUT NSData based
    // All methods are NSData based, which means that they receive and return NSData objects for the caller to
    // handle the way they need
    
    // The most generic PUT task method
    func taskForPUTMethod(baseURL: String, method: String, parameters: [String : AnyObject]?, headers: [String: String]?, body: NSData, taskCompleteHandler: (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void) -> NSURLSessionDataTask {
        
        // Build the URL and configure the request
        var urlString = baseURL + method
        
        // Concat the parameters if necesarry
        if let existingParameters = parameters {
            urlString += HTTPClient.escapedParameters(existingParameters)
        }
        
        // Build the Request
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "PUT"
        request.HTTPBody = body
        
        // Add headers if necesary
        if let existingHeaders = headers {
            for (key, value) in existingHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Create the task
        let task = session.dataTaskWithRequest(request, completionHandler: taskCompleteHandler)
        
        // Start the request
        task.resume()
        
        return task
    }
    
    // MARK: -
    
    // MARK: GET JSON/NSDictionary based
    // All methods are JSON/NSDictionary based, which means that they receive and return NSDictionary objects
    // for the caller to handle it the way they need
    
    func jsonSkipDataCharsTaskForGETMethod(baseURL: String,  method: String, parameters: [String : AnyObject]?, headers: [String: String]?, skipChars: Int, taskCompleteHandler: (jsonResponse: NSDictionary!, response: NSURLResponse!, error: NSError!) -> Void) -> NSURLSessionDataTask {

        let jsonGETHeaders = HTTPClient.jsonGETHeaders(headers)
        
        let task = skipDataCharsTaskForGETMethod(baseURL, method: method, parameters: parameters, headers: jsonGETHeaders, skipChars: skipChars) { (data, response, error) -> Void in
            if let existingError = error {
                // Error: GET failed
                taskCompleteHandler(jsonResponse: nil, response: response, error: error)
                return
            }
            // Parse the data response
            var jsonError: NSError? = nil
            if let json = HTTPClient.dataToDictionary(data, error: &jsonError) {
                // Success: parsing complete
                taskCompleteHandler(jsonResponse: json, response: response, error: nil)
            } else {
                // Error: Could not parse
                taskCompleteHandler(jsonResponse: nil, response: response, error: jsonError)
            }
        }
        return task
    }
    
    
    // GET Task method with a header dictionary
    func jsonTaskForGETMethod(baseURL: String, method: String, parameters: [String : AnyObject]?, headers: [String: String]?, taskCompleteHandler: (jsonResponse: NSDictionary!, response: NSURLResponse!, error: NSError!) -> Void) -> NSURLSessionDataTask {
        
        let jsonGETHeaders = HTTPClient.jsonGETHeaders(headers)
        
        let task = taskForGETMethod(baseURL, method: method, parameters: parameters, headers: jsonGETHeaders, taskCompleteHandler: { (data, response, error) -> Void in
            if let existingError = error {
                // Error: GET failed
                taskCompleteHandler(jsonResponse: nil, response: response, error: error)
                return
            }
            // Parse the data response
            var jsonError: NSError? = nil
            if let json = HTTPClient.dataToDictionary(data, error: &jsonError) {
                // Success: parsing complete
                taskCompleteHandler(jsonResponse: json, response: response, error: nil)
            } else {
                // Error: Could not parse
                taskCompleteHandler(jsonResponse: nil, response: response, error: jsonError)
            }
        })
        
        // Just return the task. It's already started
        return task
    }
    
    
    // MARK: GET NSData based
    // All methods are NSData based, which means that they receive and return NSData objects for the caller to
    // handle it the way they need
    
    
    // GET method that handles skipping characters in data response. Useful for Udacity responses.
    func skipDataCharsTaskForGETMethod(baseURL: String,  method: String, parameters: [String : AnyObject]?, headers: [String: String]?, skipChars: Int, taskCompleteHandler: (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void) -> NSURLSessionDataTask {
        let task = taskForGETMethod(baseURL, method: method, parameters: parameters, headers: headers) { (data, response, error) -> Void in
            self.handleSkipDataChars(skipChars, data: data, response: response, error: error, taskCompleteHandler: taskCompleteHandler)
        }
        return task
    }
    
    // The most generic GET task method
    func taskForGETMethod(baseURL: String, method: String, parameters: [String : AnyObject]?, headers: [String: String]?, taskCompleteHandler: (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void) -> NSURLSessionDataTask {
        
        // Build the URL and configure the request
        var urlString = baseURL + method
        
        // Concat the parameters if necesarry
        if let existingParameters = parameters {
            urlString += HTTPClient.escapedParameters(existingParameters)
        }
        
        // Build the URL and the Request
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        // Add headers to the request if necesary
        if let existingHeaders = headers {
            for (key, value) in existingHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Create the task
        let task = session.dataTaskWithRequest(request, completionHandler: taskCompleteHandler)
        
        // Start the request
        task.resume()
        
        return task
    }
    
    // MARK: - Utils
    
    // Utility method to hande skip chars
    func handleSkipDataChars(skipChars: Int, data: NSData!, response: NSURLResponse!, error: NSError!, taskCompleteHandler: (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void) {
        if let existingError = error {
            // Error in the GET request
            taskCompleteHandler(data: data, response: response, error: error)
            return
        }
        if data.length < skipChars + 1 {
            // Can't shift data
            let dataError = ErrorUtils.errorForDataShift(data, skipChars: skipChars)
            taskCompleteHandler(data: data, response: response, error: dataError)
            return
        }
        
        // Success
        let newData = data.subdataWithRange(NSMakeRange(skipChars, data.length - skipChars))
        taskCompleteHandler(data: newData, response: response, error: nil)
    }

 
    // Singleton definition
    class var sharedInstance: HTTPClient {
        struct Static {
            static var instance: HTTPClient?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = HTTPClient()
        }
        
        return Static.instance!
    }
}


