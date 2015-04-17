//
//  StudentInformationManager.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/12/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation
import CoreLocation

//@objc protocol StudentInformationManagerDelegate {
//    func studentsInformationDidFetch()
//    func studentsInformationFetchError(error: NSError)
//}


struct StudentInformationManagerState {
    static let New = "new"
    static let Fetching = "fetching"
    static let Ready = "ready"
    static let ReadyWithCountries = "readyWithContries"
    static let Error = "error"
}

class StudentInformationManager: NSObject {
    
    private let parseClient = ParseClient()
    private let paginatedParseClient: PaginatedParseClient
    
    private var studentsInformation: [StudentInformation]!
    private var countriesList: [CountryInformation]!
    
    dynamic var state: String = StudentInformationManagerState.New
    static let observableState = "state"
    
    
    var currentStudentsInformation: [StudentInformation]? {
        return studentsInformation
    }
    
    var currentCountriesList: [CountryInformation]? {
        return countriesList
    }
    
    var countryInformationMap: [String: Int?]!
    
    var currentError: NSError!
    
    var udacityUser: UdacityUser?
    var myStudentInformation: StudentInformation?
    
    
    override init() {
        self.paginatedParseClient = PaginatedParseClient(parseClient: self.parseClient)
        super.init()
    }
    
    func resetState() {
        studentsInformation = nil
        countriesList = nil
        currentError = nil
        udacityUser = nil
        myStudentInformation = nil
        countryInformationMap = nil
        self.state = StudentInformationManagerState.New
    }
    
    func refreshStudentsInformation() {
        
        self.currentError = nil
        self.state = StudentInformationManagerState.Fetching
        
        paginatedParseClient.fetchStudentInformationPaginated { (result, error) -> Void in
            if error != nil {
                self.currentError = error
                self.state = StudentInformationManagerState.Error
//                self.delegate?.studentsInformationFetchError(error!)
                return
            }
            // Update the current list
            self.studentsInformation = result!
            
            // Check if my location is already posted
            self.initMyStudentInformationIfNecessary()
            
            // Notify about the success
//            self.delegate?.studentsInformationDidFetch()
            self.state = StudentInformationManagerState.Ready
            
            self.refreshCountryInformationMap { (results, error) -> Void in
                if error != nil {
                    self.currentError = error
                    self.state = StudentInformationManagerState.Error
                    return
                }
                self.countriesList = results!
                self.state = StudentInformationManagerState.ReadyWithCountries
            }
            
        }
    }
    
    // Search for a student location with my uniqueKey. If exist then sets myStudentLocation to it
    func initMyStudentInformationIfNecessary() {
        if myStudentInformation == nil {
            myStudentInformation = findStudentInformationWithUniqueKey(udacityUser!.userID)
        }
    }
    
    func refreshCountryInformationMap(completionHandler: (results:[CountryInformation]!, error: NSError!) -> Void) {
        countryInformationMap = [String: Int?]()
        
        if  studentsInformation.count == 0 {
            completionHandler(results:[CountryInformation]() , error: nil)
            return
        }
        
        var remainingGeolocations = studentsInformation.count
        
        for student in studentsInformation {
            let geocoder = CLGeocoder()

            geocoder.reverseGeocodeLocation(student.location, completionHandler: { (placemarks, error) -> Void in
                if error != nil {
                    completionHandler(results:nil, error: error)
                    return
                }
                
                let placemark = placemarks.last as! CLPlacemark
                
                if self.countryInformationMap[placemark.country] == nil {
                    self.countryInformationMap[placemark.country] = 1
                } else {
                    let current = self.countryInformationMap[placemark.country]!!
                    self.countryInformationMap[placemark.country] = current + 1
                }
                
                remainingGeolocations--
                if (remainingGeolocations == 0) {
                    // Done
                    var results:[CountryInformation] = []
                    for (key, value) in self.countryInformationMap {
                        results.append(CountryInformation(name: key, count: value!))
                    }
                    
                    completionHandler(results:results, error: nil)
                }
            })
            
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
//    
//    // Refresh
//    func refreshIfNew() {
//        // FIXME: Do hte refresh only if is not running
//        
//        //        if refreshRequired {
//        //            refreshRequired = false
//        //            if beforeRefresh != nil {
//        //                beforeRefresh!()
//        //            }
//        if state == StudentInformationManagerState.New {
//            refreshStudentsInformation()
//        }
//    }
    
    func refreshIfPossible() {
        // FIXME: Do hte refresh only if is not running
        
//        if refreshRequired {
//            refreshRequired = false
//            if beforeRefresh != nil {
//                beforeRefresh!()
//            }  
        
        // Only fetch if New, ReadyWithCountries or Error
        if state == StudentInformationManagerState.New || state == StudentInformationManagerState.ReadyWithCountries || state == StudentInformationManagerState.Error {
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
