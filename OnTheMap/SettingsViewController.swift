//
//  SettingsViewController.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/16/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation
import UIKit

// Settings controller used mainly for logging out
class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var idCell: UITableViewCell!
    @IBOutlet weak var firstNameCell: UITableViewCell!
    @IBOutlet weak var lastNameCell: UITableViewCell!
    
    var studentInformationManager: StudentInformationManager!
    
    var udacityUser: UdacityUser!
    
    // MARK: - View lyfecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentInformationManager = StudentInformationManager.sharedInstance
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        udacityUser = StudentInformationManager.sharedInstance.udacityUser!
        idCell.detailTextLabel?.text = udacityUser.userID
        firstNameCell.detailTextLabel?.text = udacityUser.firstName
        lastNameCell.detailTextLabel?.text = udacityUser.lastName
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            // Logout
            
            if studentInformationManager.state == StudentInformationManagerState.ReadyWithCountries {
                // If the token exist then logut from facebook
                if FBSDKAccessToken.currentAccessToken() != nil {
                    let loginManager = FBSDKLoginManager()
                    loginManager.logOut()
                }
                
                self.dismissViewControllerAnimated(true, completion: {
                    StudentInformationManager.sharedInstance.resetState()
                })
                
            } else {
                // Not the best solution but prevents the app from reseting the state during fetching
                showMessageWithTitle("Could not logout yet", message: "Please wait until the student inforrmation is completly fetched from the server and try again")
            }
            
        }
    }
    
    
}