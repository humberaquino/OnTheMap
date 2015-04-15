//
//  StudentLocationManager.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/12/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation


@objc protocol StudentLocationManagerDelegate {
    func studentLocationsDidFetch()
    func studentLocationsFetchError(error: NSError)
}

class StudentLocationManager: NSObject {
    
    private let parseClient = ParseClient()
    private var studentLocations: [StudentLocation]!
    
    var delegate: StudentLocationManagerDelegate?
    var refreshRequired = false
    
    var currentStudentLocations: [StudentLocation]? {
        return studentLocations
    }
    
    var udacityUser: UdacityUser?
    var myStudentLocation: StudentLocation?
    
    var studentLocationsNotInitialized = true
    
    func refreshStudentLocations() {
        parseClient.fetchStudentsLocation { (newStudentLocationList, error) -> Void in
            if let existingError = error {
                // Error while fetching
                self.performOnMainQueue {
                    self.delegate?.studentLocationsFetchError(existingError)
                }
                return
            }
            
            // Update the current list
            self.studentLocations = newStudentLocationList!
            
            // Check if my location is already posted
            self.initMyStudentLocationIfNecessary()
            
            // Notify about the success
            self.performOnMainQueue {
                self.delegate?.studentLocationsDidFetch()
            }
        }
    }
    
    // Search for a student location with my uniqueKey. If exist then sets myStudentLocation to it
    func initMyStudentLocationIfNecessary() {
        if myStudentLocation == nil {
            myStudentLocation = findStudentLocationWithUniqueKey(udacityUser!.userID)
        }
    }
    
    func submitStudentLocation(studentLocation: StudentLocation, completitionHandler: (success: Bool, error: NSError!) -> Void) {
        
        if myLocationExists() {
            // Overriding my location and mediaURL
            // TODO: a PUT
            parseClient.updateStudentLocation(studentLocation) { (success, updateError) in
                // Handle completition
                self.handleStudentLocationChange(studentLocation, requestError: updateError, completitionHandler: completitionHandler)
            }
            
            
        } else {
            // This is the first time I sumbit my location. Do a POST
            parseClient.createStudentLocation(studentLocation) { (objectId, createError) in
                if objectId != nil {
                    studentLocation.objectId = objectId
                }
                // Handle completition
                self.handleStudentLocationChange(studentLocation, requestError: createError, completitionHandler: completitionHandler)
                
            }
        }
    }
    
    // Handler used to check for request errors and do the completition in create and update methods
    func handleStudentLocationChange(studentLocation: StudentLocation, requestError: NSError!, completitionHandler:(success: Bool, error: NSError!) -> Void) {
        if let existingError = requestError {
            self.performOnMainQueue {
                completitionHandler(success: false, error: existingError)
            }
            return
        }
        // Success
        // Save the studentLocation with the assigned objectId
        self.myStudentLocation = studentLocation
        self.performOnMainQueue {
            completitionHandler(success: true, error: nil)
        }
    }
    
    // Used to refresh conditionally. Some part of the app can set refreshRequired to true and then
    // This method can be called when the screen will appear to start a refresh
    func refreshIfRequired(beforeRefresh: (() -> Void)?) {
        if refreshRequired {
            refreshRequired = false
            if beforeRefresh != nil {
                beforeRefresh!()
            }            
            refreshStudentLocations()
        }
    }
    
    
    // Checks if
    func myLocationExists() -> Bool {
        // Quick test
        if myStudentLocation != nil {
            return true
        }
        
        // No location in this session but perhaps is already in the list
        if studentLocations != nil && udacityUser != nil {
            if let studentFound = findStudentLocationWithUniqueKey(udacityUser!.userID) {
                return true
            }
        }
        return false
    }
    
    // MARK: - Utility functions
    
    func findStudentLocationWithUniqueKey(uniqueKey: String) -> StudentLocation? {
        for studentLocation in studentLocations {
            if studentLocation.uniqueKey == uniqueKey {
                // My key is already placed.
                return studentLocation
            }
        }
        return nil
    }
    
    // Singleton definition
    class var sharedInstance: StudentLocationManager {
        struct Static {
            static var instance: StudentLocationManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = StudentLocationManager()
        }
        
        return Static.instance!
    }
}
