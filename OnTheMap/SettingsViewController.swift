//
//  SettingsViewController.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/16/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var idCell: UITableViewCell!
    @IBOutlet weak var firstNameCell: UITableViewCell!
    @IBOutlet weak var lastNameCell: UITableViewCell!
    
    var udacityUser: UdacityUser!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        udacityUser = StudentInformationManager.sharedInstance.udacityUser!
        idCell.detailTextLabel?.text = udacityUser.userID
        firstNameCell.detailTextLabel?.text = udacityUser.firstName
        lastNameCell.detailTextLabel?.text = udacityUser.lastName
        
    }        
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            // Logout
            
            // If the token exist then logut from facebook
            if FBSDKAccessToken.currentAccessToken() != nil {
                let loginManager = FBSDKLoginManager()
                loginManager.logOut()
                
            }            

            self.dismissViewControllerAnimated(true, completion: nil)
        }        
    }
    
    
}