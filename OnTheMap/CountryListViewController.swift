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
    
    var countryList: [CountryInformation]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countryList = []
    
        activityView.startAnimating()
        // Trying only once
        StudentInformationManager.sharedInstance.refreshCountryInformationMap { (results, error) -> Void in
            if error != nil {
                self.showMessageWithTitle("Error during geocoding", message: error.localizedDescription)
                return
            }
            self.countryList = results
            self.tableView.reloadData()
            self.activityView.stopAnimating()
        }
    }
            
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CountryInformationCell") as! UITableViewCell
        
        let countryInformation = countryList[indexPath.row]
        
        cell.textLabel?.text = countryInformation.name
        cell.detailTextLabel?.text = "\(countryInformation.count) students"
        
        return cell
    }
    
    
    
}