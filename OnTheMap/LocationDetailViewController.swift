//
//  LocationDetailViewController.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/11/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class LocationDetailViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {

    let DefaultShareLinkText = "Enter a link to share here"
    let NewStudentPinIdentifier = "NewStudentPin"
    
    @IBOutlet weak var linkToShareTextField: UITextField!
    
    @IBOutlet weak var visitLinkButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    
    var tapRecognizer: UITapGestureRecognizer!
    
    var coordinates: CLLocationCoordinate2D!
    
    var mapString: String!
    
    var studentInformationManager: StudentInformationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Round corners
        submitButton.layer.cornerRadius = 10;

        studentInformationManager = StudentInformationManager.sharedInstance
        
        mapView.delegate = self
        linkToShareTextField.delegate = self
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        view.removeGestureRecognizer(tapRecognizer)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Show the framed location
        
        
        let locationCoordinate = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: locationCoordinate, span: span)
        
        var annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        
        mapView.addAnnotation(annotation)
        
        mapView.setRegion(region, animated: true)
        
    }
    
    // MARK: - UITapGestureRecognizer
    
    func handleTapGesture(sender: UITapGestureRecognizer) {
        // Hide keyboard
        view.endEditing(true)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text == DefaultShareLinkText {
            // Clear existing text
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text.isEmpty {
            textField.text = DefaultShareLinkText
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        submitStudentLocation()
        return true
    }
    

    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var dequeuedAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(NewStudentPinIdentifier) as? MKPinAnnotationView
        
        if let annotationView = dequeuedAnnotationView {
             annotationView.annotation = annotation
        } else {
            dequeuedAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: NewStudentPinIdentifier)
            dequeuedAnnotationView!.draggable = true
            dequeuedAnnotationView!.animatesDrop = true
        }
        
        return dequeuedAnnotationView
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!,
        didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
            if newState == MKAnnotationViewDragState.Ending {
                let droppedAt = view.annotation.coordinate
                // Update coordinates
                coordinates = droppedAt
            }
    }
    
    // AMRK: - Actions
    
    @IBAction func submitAction(sender: UIButton) {
        submitStudentLocation()
    }
    
    @IBAction func cancelAction(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func visitLink(sender: UIButton) {
        let errorTuple = validMediaString()
        if let existErrorTuple = errorTuple {
            showMessageWithTitle(existErrorTuple.title , message: existErrorTuple.message)
        } else {
            self.performSegueWithIdentifier("PreviewShareLink", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PreviewShareLink" {
            let destination = segue.destinationViewController as! ShareLinkWebPreviewViewController
            destination.urlString = linkToShareTextField.text
        }
    }
    
    // MARK: - Behavior
    
    func submitStudentLocation() {
        
        let errorTuple = validMediaString()
        if let existErrorTuple = errorTuple {
            showMessageWithTitle(existErrorTuple.title , message: existErrorTuple.message)
            return
        }
        
        // Update student location with current coordinates
        var studentInformation = buildStudentInformation()
      
        // Use the StudentLocationManager to do the submit
        studentInformationManager.submitStudentInformation(studentInformation, completitionHandler: {
            (updatedStudentLocation, error) -> Void in
            if let existingError = error {
                self.showMessageWithTitle("Error submiting location", message: existingError.localizedDescription)
                return
            }
            
            // Success. Save my student location

            // FIXME: Remove this whe everything is working
            // studentLocation.objectId = objectId
            // StudentLocationManager.sharedInstance.myStudentLocation = studentLocation
            //
            
            // TODO: Add a refresh action here
//            StudentInformationManager.sharedInstance.refreshRequired = true
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    func validMediaString() -> (title: String, message: String)? {
        
        // Validate that the link provided exists and is a URL
        if let mediaString = linkToShareTextField.text {
            if !mediaString.isEmpty && mediaString != DefaultShareLinkText {
                if let url = NSURL(string: mediaString) {
                    if url.scheme != nil && url.host != nil {
                        // Success
                        // Ref: http://stackoverflow.com/a/5081447/223228
                        return nil
                    }
                    
                }
                // Invalid URL
                return (title: "Invalid URL", message: "The URL provided is not valid: \(mediaString)")
            }
        }
        // Media string empty
        return (title: "Invalid URL", message: "The media String is empty")
        
    }
    
    func buildStudentInformation() -> StudentInformation {
        let udacityUser = StudentInformationManager.sharedInstance.udacityUser!
        
        let mediaString = linkToShareTextField.text
        let latitude = coordinates.latitude
        let longitude = coordinates.longitude
        
        let dictionary: [String: AnyObject] = [
            "uniqueKey": udacityUser.userID,
            "firstName": udacityUser.firstName,
            "lastName": udacityUser.lastName,
            "mapString": mapString,
            "mediaURL": mediaString,
            "latitude": latitude,
            "longitude": longitude
        ]
        
        let studentInformation = StudentInformation(dictionary: dictionary)
        
        if let myStudentInformation = StudentInformationManager.sharedInstance.myStudentInformation {
            studentInformation.objectId = myStudentInformation.objectId
        }
        
        return studentInformation
    }
}