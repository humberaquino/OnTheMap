//
//  StudentsListViewController.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/13/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation
import UIKit

class StudentsListViewController: UITableViewController, StudentLocationManagerDelegate {
    
    var studentLocationManager: StudentLocationManager!
    
    var studentLocationList: [StudentLocation]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentLocationManager = StudentLocationManager.sharedInstance
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Update list of students
        refreshStudentLocations()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentInformationCell") as! UITableViewCell
        
        let studentLocation = studentLocationList![indexPath.row]
        
        cell.textLabel?.text = studentLocation.title
        cell.detailTextLabel?.text = studentLocation.mediaURL
        cell.imageView?.image = UIImage(named: "pin")
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let existingList = studentLocationList {
            return existingList.count
        } else {
            return 0
        }
    }
    
    
    func studentLocationsSuccessfulRefresh() {
        refreshStudentLocations()
    }
    
    func studentLocationsErrorWhileFetching(error: NSError) {
        showMessageWithTitle("Error fetching the student locaitons", message: error.localizedDescription)
    }
    
    func refreshStudentLocations () {
        studentLocationList = studentLocationManager.currentStudentLocations
        tableView.reloadData()
    }
    
}