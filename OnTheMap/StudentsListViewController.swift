//
//  StudentsListViewController.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/13/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation
import UIKit

class StudentsListViewController: UITableViewController, StudentInformationManagerDelegate {
    
    var studentInformationManager: StudentInformationManager!
    
    var studentInformationList: [StudentInformation]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentInformationManager = StudentInformationManager.sharedInstance
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        studentInformationManager.delegate = self
        // Update list of students
        refreshStudentsInformation()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        studentInformationManager.delegate = nil
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentInformationCell") as! UITableViewCell
        
        let studentLocation = studentInformationList[indexPath.row]
        
        cell.textLabel?.text = studentLocation.title
        cell.detailTextLabel?.text = studentLocation.mediaURL
        cell.imageView?.image = UIImage(named: "pin")
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let existingList = studentInformationList {
            return existingList.count
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentInformation = studentInformationList[indexPath.row]
        if !URLUtils.openURL(string: studentInformation.mediaURL) {
            showMessageWithTitle("Error", message: "Could not open URL: \(studentInformation.mediaURL)")
        }
    }
    
    // MARK: - StudentLocationManagerDelegate
    
    func studentsInformationDidFetch() {
        refreshStudentsInformation()
    }
    
    func studentsInformationFetchError(error: NSError) {
        showMessageWithTitle("Error fetching the student locaitons", message: error.localizedDescription)
    }
    
    func refreshStudentsInformation () {
        studentInformationList = studentInformationManager.currentStudentsInformation
        tableView.reloadData()
    }
    
}