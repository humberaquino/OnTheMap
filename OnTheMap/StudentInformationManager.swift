//
//  StudentInformationManager.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/12/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation


@objc protocol StudentInformationManagerDelegate {
    func studentsInformationDidFetch()
    func studentsInformationFetchError(error: NSError)
}

class StudentInformationManager: NSObject {
    
    private let parseClient = ParseClient()
    private var studentsInformation: [StudentInformation]!
    
    var delegate: StudentInformationManagerDelegate?
    var refreshRequired = false
    
    var currentStudentsInformation: [StudentInformation]? {
        return studentsInformation
    }
    
    var udacityUser: UdacityUser?
    var myStudentInformation: StudentInformation?
    
    func refreshStudentsInformation() {
        parseClient.fetchStudentsInformation { (newStudentsInformationList, error) -> Void in
            if let existingError = error {
                // Error while fetching
                self.performOnMainQueue {
                    self.delegate?.studentsInformationFetchError(existingError)
                }
                return
            }
            
            // Update the current list
            self.studentsInformation = newStudentsInformationList!
            
            // Check if my location is already posted
            self.initMyStudentInformationIfNecessary()
            
            // Notify about the success
            self.performOnMainQueue {
                self.delegate?.studentsInformationDidFetch()
            }
        }
    }
    
    // Search for a student location with my uniqueKey. If exist then sets myStudentLocation to it
    func initMyStudentInformationIfNecessary() {
        if myStudentInformation == nil {
            myStudentInformation = findStudentInformationWithUniqueKey(udacityUser!.userID)
        }
    }
    
    func submitStudentInformation(studentInformation: StudentInformation, completitionHandler: (success: Bool, error: NSError!) -> Void) {
        
        if myStudentInformationExists() {
            // Overriding my location and mediaURL
            // TODO: a PUT
            parseClient.updateStudentInformation(studentInformation) { (success, updateError) in
                // Handle completition
                self.handleStudentInformationChange(studentInformation, requestError: updateError, completitionHandler: completitionHandler)
            }
            
            
        } else {
            // This is the first time I sumbit my location. Do a POST
            parseClient.createStudentInformation(studentInformation) { (objectId, createError) in
                if objectId != nil {
                    studentInformation.objectId = objectId
                }
                // Handle completition
                self.handleStudentInformationChange(studentInformation, requestError: createError, completitionHandler: completitionHandler)
                
            }
        }
    }
    
    // Handler used to check for request errors and do the completition in create and update methods
    func handleStudentInformationChange(studentInformation: StudentInformation, requestError: NSError!, completitionHandler:(success: Bool, error: NSError!) -> Void) {
        if let existingError = requestError {
            self.performOnMainQueue {
                completitionHandler(success: false, error: existingError)
            }
            return
        }
        // Success
        // Save the studentLocation with the assigned objectId
        self.myStudentInformation = studentInformation
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
            refreshStudentsInformation()
        }
    }
    
    
    // Checks if
    func myStudentInformationExists() -> Bool {
        // Quick test
        if myStudentInformation != nil {
            return true
        }
        
        // No location in this session but perhaps is already in the list
        if myStudentInformation != nil && udacityUser != nil {
            if let studentFound = findStudentInformationWithUniqueKey(udacityUser!.userID) {
                return true
            }
        }
        return false
    }
    
    // MARK: - Utility functions
    
    func findStudentInformationWithUniqueKey(uniqueKey: String) -> StudentInformation? {
        for studentInformation in studentsInformation {
            if studentInformation.uniqueKey == uniqueKey {
                // My key is already placed.
                return studentInformation
            }
        }
        return nil
    }
    
    // Singleton definition
    class var sharedInstance: StudentInformationManager {
        struct Static {
            static var instance: StudentInformationManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = StudentInformationManager()
        }
        
        return Static.instance!
    }
}
