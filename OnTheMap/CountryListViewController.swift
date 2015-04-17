//
//  CountryListViewController.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/15/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation
import UIKit

class CountryListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var studentInformationManager: StudentInformationManager!
    
    var currentCountryList: [CountryInformation]!
    
    private var myContext: UnsafeMutablePointer<Void> = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentInformationManager = StudentInformationManager.sharedInstance
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Update to the current list
        currentCountryList = studentInformationManager.currentCountriesList
        if currentCountryList == nil {
            // Uninitialized. Request update
            studentInformationManager.refreshIfPossible()
        }
        // Update control state
        if studentInformationManager.state == StudentInformationManagerState.Fetching || studentInformationManager.state == StudentInformationManagerState.Ready {
            refreshInProgress()
        } else {
            self.tableView.reloadData()
            refreshDone()
        }
        studentInformationManager.addObserver(self, forKeyPath: StudentInformationManager.observableState, options: NSKeyValueObservingOptions.New, context: &myContext)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        studentInformationManager.removeObserver(self, forKeyPath: StudentInformationManager.observableState)        
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &myContext {
            let newState = change[NSKeyValueChangeNewKey] as! String
            
            if newState == StudentInformationManagerState.ReadyWithCountries {
                // Success: Get the data and reload the map
                currentCountryList = studentInformationManager.currentCountriesList
                refreshDone()
                tableView.reloadData()
            } else if newState == StudentInformationManagerState.Error {
                // Error in the fetching
                refreshDone()
                showMessageWithTitle("Error while updating the map", message: studentInformationManager.currentError.localizedDescription)
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    func refreshInProgress() {
//        refreshButton.enabled = false
//        placePinButton.enabled = false
        //        view.userInteractionEnabled = false
        self.activityView.startAnimating()
    }
    
    func refreshDone() {
//        refreshButton.enabled = true
//        placePinButton.enabled = true
        //        view.userInteractionEnabled = true
        // Always set the alpha to Constants.UI.activeViewAlpha
        //        view.alpha = Constants.UI.activeViewAlpha
        self.activityView.stopAnimating()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentCountryList == nil {
            return 0
        } else {
            return currentCountryList.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CountryInformationCell") as! UITableViewCell
        
        let countryInformation = currentCountryList[indexPath.row]
        
        cell.textLabel?.text = countryInformation.name
        cell.detailTextLabel?.text = "\(countryInformation.count) students"
        
        return cell
    }
    
    
    
}