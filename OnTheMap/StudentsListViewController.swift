//
//  StudentsListViewController.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/13/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation
import UIKit

// View controller that handles the display of StudentInformation in tha List
class StudentsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var placePinButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var studentInformationManager: StudentInformationManager!
    
    var currentStudentsInformation: [StudentInformation]!
    
    private var myContext: UnsafeMutablePointer<Void> = nil
    
    // MARK: - View lyfecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentInformationManager = StudentInformationManager.sharedInstance
    }
   
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Update to the current list
        currentStudentsInformation = studentInformationManager.currentStudentsInformation
        if currentStudentsInformation == nil {
            // Uninitialized
            refreshInProgress()
            studentInformationManager.refreshIfPossible()
        } else {
            // Update control state
            if studentInformationManager.state == StudentInformationManagerState.Fetching {
                refreshInProgress()
            } else {
                self.tableView.reloadData()
                refreshDone()
            }
        }
        
        // Subscribe to know when the student list is ready
         studentInformationManager.addObserver(self, forKeyPath: StudentInformationManager.observableState, options: NSKeyValueObservingOptions.New, context: &myContext)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        studentInformationManager.removeObserver(self, forKeyPath: StudentInformationManager.observableState)
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &myContext {
            let newState = change[NSKeyValueChangeNewKey] as! String
            
            if newState == StudentInformationManagerState.Ready {
                // Success: Get the data and reload the map
                currentStudentsInformation = studentInformationManager.currentStudentsInformation
                refreshDone()
                tableView.reloadData()
            } else if newState == StudentInformationManagerState.Fetching {
                // Mark as in progress
                refreshInProgress()
            } else if newState == StudentInformationManagerState.Error {
                // Error in the fetching
                refreshDone()
                showMessageWithTitle("Error while updating the map", message: studentInformationManager.currentError.localizedDescription)
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    // MARK: - UI activity
    
    func refreshInProgress() {
        refreshButton.enabled = false
        placePinButton.enabled = false
        self.activityIndicator.startAnimating()
    }
    
    func refreshDone() {
        refreshButton.enabled = true
        placePinButton.enabled = true
        self.activityIndicator.stopAnimating()
    }
    
    // MARK: - UITableViewDAtaSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentInformationCell") as! UITableViewCell
        
        let studentLocation = currentStudentsInformation[indexPath.row]
        
        cell.textLabel?.text = studentLocation.title
        cell.detailTextLabel?.text = studentLocation.mediaURL
        cell.imageView?.image = UIImage(named: "pin")
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let existingList = currentStudentsInformation {
            return existingList.count
        } else {
            return 0
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentInformation = currentStudentsInformation[indexPath.row]
        if !URLUtils.openURL(string: studentInformation.mediaURL) {
            showMessageWithTitle("Error", message: "Could not open URL: \(studentInformation.mediaURL)")
        }
    }
    

    // MARK: - Actions
    
    @IBAction func reloadStudentInformationOnMap(sender: UIBarButtonItem) {
        refreshInProgress()
        studentInformationManager.refreshIfPossible()
    }
}