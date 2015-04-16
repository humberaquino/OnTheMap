//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/8/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    var tapRecognizer: UITapGestureRecognizer!
    
    var udacityClient: UdacityClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        udacityClient = UdacityClient()
        
        // Initialization
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        
        // Delegate setup
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Setup the UI looks
        emailTextField.leftPaddingOf(Constants.UI.LEFT_PADDING_FOR_TEXTFIELD)
        passwordTextField.leftPaddingOf(Constants.UI.LEFT_PADDING_FOR_TEXTFIELD)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardDismissRecognizer()
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardDismissRecognizer()
        unsubscribeToKeyboardNotifications()
    }
    
    
    @IBAction func signUpAction(sender: UIButton) {
        if !URLUtils.openURL(string: Constants.signUpURLString) {
            showMessageWithTitle("Error", message: "Could not open URL: \(Constants.signUpURLString)")
        }
    }
    
    
    @IBAction func loginAction(sender: UIButton) {
        doLogin()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        doLogin()
        return true
    }
    
    func doLogin() {
        // Disabling the login button
        loginInProgress(true)
        
        let username = emailTextField.text
        let password = passwordTextField.text
        
        // Check that username and pasword are not empty
        if username.isEmpty || password.isEmpty {
            showMessageWithTitle("Credentials required", message: "The login process requires an email and a password")
            self.loginInProgress(false)
            return
        }
        
        udacityClient.loginToUdacityAndGetPublicUserData(username, password: password) { (udacityUser, error) -> Void in
            if let existingErrorTuple = error {
                // Login error. Inform the user
                
                //self.showMessageWithTitle(existingErrorTuple.title, message: existingErrorTuple.message)
                self.presentCatastrophicView(existingErrorTuple)
                self.loginInProgress(false)
            } else {
                // Success. Show the Map view
                StudentInformationManager.sharedInstance.udacityUser = udacityUser
                StudentInformationManager.sharedInstance.refreshRequired = true
                self.presentMapAndTabView()
            }            
        }
    }
    
    func presentMapAndTabView() {
        let mapAndTabController = self.storyboard?.instantiateViewControllerWithIdentifier(Constants.StoryboardID.MapAndTabView) as! UITabBarController
        
        self.presentViewController(mapAndTabController, animated: true, completion: nil)
    }
    
   
    
    func loginInProgress(inProgress: Bool) {
        if inProgress {
            view.userInteractionEnabled = false

            self.activityView.alpha = 0
            self.activityView.startAnimating()
            
            UIView.animateWithDuration(0.8, animations: { () -> Void in
                self.view.alpha = Constants.UI.inactiveViewAlpha
                self.loginButton.alpha = 0
                self.activityView.alpha = 1
            })
            
        } else {
            view.userInteractionEnabled = true
            view.alpha = Constants.UI.activeViewAlpha
            activityView.stopAnimating()
            self.loginButton.alpha = 1
        }
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        if let currentTextField = getCurrentTextField() {
            let currentTextFieldY = currentTextField.frame.origin.y
            let currentTextFieldHeight = currentTextField.bounds.height
            let keyboardHeight = getKeyboardHeight(notification)
            let screenHeight = UIScreen.mainScreen().bounds.height
            
            // Detect if the keyboard is obstructing the current textfield
            if (currentTextFieldY + currentTextFieldHeight + keyboardHeight) >= screenHeight {
                let visibleSection = screenHeight - keyboardHeight
                let textFieldBottom = currentTextFieldY + currentTextFieldHeight + Constants.UI.KEYBOARD_MARGIN
                let displacement = textFieldBottom - visibleSection
                self.view.frame.origin.y = -displacement
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        // origin is 0
        self.view.frame.origin.y = 0
    }
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func getCurrentTextField() -> UITextField? {
        if emailTextField.isFirstResponder() {
            return emailTextField
        } else if passwordTextField.isFirstResponder() {
            return passwordTextField
        } else {
            return nil
        }
    }
  
    
    func presentCatastrophicView(errorTuple: (title: String, message: String)) {
        let catastrophicViewController = storyboard?.instantiateViewControllerWithIdentifier("CatastrophicView") as! CatastrophicViewController
        
        catastrophicViewController.message = (top: errorTuple.title, bottom: errorTuple.message)
        
        presentViewController(catastrophicViewController, animated: true, completion: nil)
    }
}

