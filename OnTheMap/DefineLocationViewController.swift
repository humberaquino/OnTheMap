//
//  DefineLocationViewController.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/11/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class DefineLocationViewController: UIViewController, UITextFieldDelegate {
    
    let DefaultLocationPhraseText = "Enter your location here"
    
    @IBOutlet weak var geolocationActivity: UIActivityIndicatorView!
    
    @IBOutlet weak var locationPhraseTextField: UITextField!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    
    var tapRecognizer: UITapGestureRecognizer!
    
     // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Round corners
        findOnTheMapButton.layer.cornerRadius = 10;
        
        // Delegate setup
        locationPhraseTextField.delegate = self
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTapGesture:")        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        view.addGestureRecognizer(tapRecognizer)
        self.geolocationActivity.stopAnimating()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        view.removeGestureRecognizer(tapRecognizer)
    }
    
    // MARK: - UITapGestureRecognizer
    
    func handleTapGesture(sender: UITapGestureRecognizer) {
        // Hide keyboard
        view.endEditing(true)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Clear existing text
        textField.text = ""
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text.isEmpty {
            textField.text = DefaultLocationPhraseText
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        findOnTheMapUsingPhrase()
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func findOnTheMapAction(sender: UIButton) {
        findOnTheMapUsingPhrase()
    }
    
    @IBAction func cancelAction(sender: UIButton) {
        // TODO: Cancel geolocation
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Mark: - Behavior methods
    
    func findOnTheMapUsingPhrase() {
        // Start the location service
        let searchPhrase = locationPhraseTextField.text
        if searchPhrase.isEmpty || searchPhrase == DefaultLocationPhraseText {
            showMessageWithTitle("No location entered", message: "Please specify a city, address or country to search for.")
            return
        }
        
        // Start the search
        let geocoder = CLGeocoder()
        geolocationActivity.startAnimating()
        geocoder.geocodeAddressString(searchPhrase, completionHandler: { (result, error) -> Void in
            self.geolocationActivity.stopAnimating()
            
            if error != nil {
                self.showMessageWithTitle("Geolocation failed", message: error.localizedDescription)
                return
            }
            
            if result.count == 0 {
                self.showMessageWithTitle("Geolocation complete without results", message: "No placemarks were found for search: \(searchPhrase)")
                return
            }
            // Ok, no errors and at least one palcemark. Let's use the first one
            let placemark = result[0] as! CLPlacemark
            
            let locationViewController = self.storyboard?.instantiateViewControllerWithIdentifier(Constants.StoryboardID.LocationDetailView) as! LocationDetailViewController
            
            locationViewController.coordinates = placemark.location.coordinate
            locationViewController.mapString = searchPhrase
            
            self.navigationController?.pushViewController(locationViewController, animated: true)
        })
    }
}