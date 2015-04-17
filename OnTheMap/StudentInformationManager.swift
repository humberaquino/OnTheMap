//
//  StudentInformationManager.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/12/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation
import CoreLocation


// Struct used to define the possible states of the student information manager
// StudentInformationManager.sharedInstance.state is obserbable by any interface that depends on 
// Student information. E.g. Maps, Lists, etc
struct StudentInformationManagerState {
    static let New = "new"
    static let Fetching = "fetching"
    static let Ready = "ready"
    static let ReadyWithCountries = "readyWithContries"
    static let Error = "error"
}

// This manager is a singleton facade used to get all StudentInformation from Parse
// and save or updaet a student location
class StudentInformationManager: NSObject {
    // Constant used in the KVO KeyPath
    static let observableState = "state"
    
    // Parse clients
    private let parseClient = ParseClient()
    private let paginatedParseClient: PaginatedParseClient
    
    // The current students list. Used by the Map and tabbed lists
    private var studentsInformation: [StudentInformation]!
    // Public getter. Just to have some peace of mind and be sure that 
    // no other object is messing with studentsInformation
    var currentStudentsInformation: [StudentInformation]? {
        return studentsInformation
    }
    // The current country information list. Used by the Country list tab
    private var countriesList: [CountryInformation]!
    // Same here for countriesList
    var currentCountriesList: [CountryInformation]? {
        return countriesList
    }
    
    // KVO property used to let observers know about the state of the Student Information fetching
    dynamic var state: String = StudentInformationManagerState.New
    
    // Utility property to recolect country information in method refreshCountryInformationMap
    private var countryInformationMap: [String: Int?]!
    
    // The current error. Can be readed to know what happened to the fetching
    var currentError: NSError!
    
    // My udacity used and Student information
    var udacityUser: UdacityUser?
    var myStudentInformation: StudentInformation?
    
    
    override init() {
        self.paginatedParseClient = PaginatedParseClient(parseClient: self.parseClient)
        super.init()
    }
    
   
    // MARK: - Public Refresh request
    
    // This method can be called by the app to try to refresh the app if possible.
    // can be called any number of times
    func refreshIfPossible() {
        // Only fetch if New, ReadyWithCountries or Error
        if state == StudentInformationManagerState.New || state == StudentInformationManagerState.ReadyWithCountries || state == StudentInformationManagerState.Error {
            refreshStudentsInformation()
        }
    }
    
    // This is the actual function that does the refresh. Must not be called if is already running
    // This is very important and that's the readon I marked it as private
    private func refreshStudentsInformation() {
        // Init state and error
        self.currentError = nil
        self.state = StudentInformationManagerState.Fetching
        
        paginatedParseClient.fetchStudentInformationPaginated { (result, error) -> Void in
            if error != nil {
                // Some error during the paginated fetching
                self.currentError = error
                self.state = StudentInformationManagerState.Error
                return
            }
            // Update the current list
            self.studentsInformation = result!
            
            // Check if my location is already posted
            self.initMyStudentInformationIfNecessary()
            
            // Mark as ready
            self.state = StudentInformationManagerState.Ready
            
            // Start building the country dictionary
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
    
    func submitStudentInformation(studentInformation: StudentInformation, completitionHandler: (success: Bool, error: NSError!) -> Void) {
        if myStudentInformationExists() {
            // Overriding my location and mediaURL. Do a PUT
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
    
    // Used to loads the Country information
    func refreshCountryInformationMap(completionHandler: (results:[CountryInformation]!, error: NSError!) -> Void) {
        countryInformationMap = [String: Int?]()
        
        if studentsInformation.count == 0 {
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
               
                // One less and check for completion
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
    
    // MARK: - Handlers
    
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
    
    // MARK: - Utility functions
    
    // Check if my student information exists. Used to know if the app has to create or update 
    // my student information
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
    
    // Search for a student location with my uniqueKey. If exist then sets myStudentLocation to it
    func initMyStudentInformationIfNecessary() {
        if myStudentInformation == nil {
            myStudentInformation = findStudentInformationWithUniqueKey(udacityUser!.userID)
        }
    }
    
    func findStudentInformationWithUniqueKey(uniqueKey: String) -> StudentInformation? {
        for studentInformation in studentsInformation {
            if studentInformation.uniqueKey == uniqueKey {
                // My key is already placed.
                return studentInformation
            }
        }
        return nil
    }
    
    // Reset the internal state to have a clean singleton after logout
    func resetState() {
        studentsInformation = nil
        countriesList = nil
        currentError = nil
        udacityUser = nil
        myStudentInformation = nil
        countryInformationMap = nil
        self.state = StudentInformationManagerState.New
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
