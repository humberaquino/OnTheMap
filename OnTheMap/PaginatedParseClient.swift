//
//  PaginatedParseClient.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/16/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation

class PaginatedParseClient: NSObject {
    
    let limit = Constants.BatchRequestSize
    
    private var currentCount: Int!
    private var currentPage: Int!
    private var currentTotalPages: Int!
    
    private var paginationRunning = false
    private var requestRunning = false
    
    let parseClient: ParseClient
    
    init(parseClient: ParseClient) {
        self.parseClient = parseClient
    }
    
    // This is the definite callback
    var currentFetchComplete: ((result: [StudentInformation]?, error: NSError?) -> Void)!
    
    var timer: NSTimer!
    
    var resultList: [StudentInformation]!
    
    func fetchStudentInformationPaginated(fetchComplete: (result: [StudentInformation]?, error: NSError?) -> Void) -> Bool {
        if paginationRunning {
            // It's running. Skip the fetch
            return false
        }
        // Mark as running
        paginationRunning = true
        
        // Setup
        currentFetchComplete = nil
        timer = nil
        resultList = [StudentInformation]()
        
        // Get the total count
        parseClient.countStudentsInformation { (count, error) -> Void in
            self.performOnMainQueue({ () -> Void in
                if error != nil {
                    // Error after trying to count
                    fetchComplete(result: nil, error: error)
                    return
                }
                // Success. We know how much students we have.
                // E.g. 66 students and the pageSize is 10. We have 7 pages.
                self.setupCounters(count)
                
                self.currentFetchComplete = fetchComplete
                
                self.timer = NSTimer.scheduledTimerWithTimeInterval(Constants.TimerIntervalRequests, target: self, selector: "nextRequest:", userInfo: nil, repeats: true)
            })
            

            // Now the control is passed to the "nextRequest" method
            
        }
        
        return true
    }
    
    func nextRequest(timer:NSTimer!) {
        if requestRunning {
            // Do nothing. Just wait for the next turn
            return
        }
        requestRunning = true
        println("Page Loading: \(self.currentPage)")
        // TODO: Check that this is called in the main thread. Or at least what matters
        
        let currentSkip = currentPage * limit
        println("skip: \(currentSkip) limit: \(limit)")
        parseClient.fetchStudentsInformationPaginated(currentSkip, limit: limit) { (result, error) -> Void in
            self.performOnMainQueue({ () -> Void in
                if error != nil {
                    //                self.performOnMainQueue({ () -> Void in
                    self.timer.invalidate()
                    self.currentFetchComplete(result: nil, error: error)
                    self.paginationRunning = false
                    //                })
                    // TODO: Clean up the object state
                    return
                }
                
                println("Page loaded: \(self.currentPage): Total: \(result!.count)" )
                println()
                
                self.resultList.extend(result!)
                
                if self.allPagesDone() {
                    // DONE!
                    // Call the final completition callback. Stop everything
                    //                self.performOnMainQueue({ () -> Void in
                    self.timer.invalidate()
                    self.currentFetchComplete(result: self.resultList, error: nil)
                    self.paginationRunning = false
                    //                })
                } else {                    
                    // Increment the counter and allow the request to run
                    self.currentPage = self.currentPage + 1
                    self.requestRunning = false
                }
            })
            
        }
    }
    
    
    func allPagesDone() -> Bool {
        return self.currentPage == self.currentTotalPages - 1
    }
    
    // Configures the values that the object need to track the page requests
    func setupCounters(count: Int) {
        // Setup initial values
        currentPage = 0
        currentCount = 0
        
        // The elements total
        currentCount = count
        
        var totalPages = count/limit
        if count % limit != 0 {
            totalPages++
        }
        
        // The pages total
        currentTotalPages = totalPages
    }
        
}