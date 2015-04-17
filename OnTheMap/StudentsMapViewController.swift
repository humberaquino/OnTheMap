//
//  StudentsMapViewController.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/11/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation
import UIKit
import MapKit

// View controller that handles the display of StudentInformation in tha map
class StudentsMapViewController: UIViewController, MKMapViewDelegate {

    let StudentPinIdentifier = "StudentPin"
    let DefineStudentInformationIdentifier = "DefineStudentInformation"
    let ConfirmationOverrideLocationMessage = "You have already posted a student location. Would you like to override your current Location?"
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var placePinButton: UIBarButtonItem!
    
    var studentInformationManager: StudentInformationManager!

    // Data source
    var currentStudentsInformation: [StudentInformation]!
    
    private var myContext: UnsafeMutablePointer<Void> = nil
    
    // MARK: View clifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
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
                reloadMap()
                refreshDone()
            }
        }
        
        // Observe the state of the students fetch
        studentInformationManager.addObserver(self, forKeyPath: StudentInformationManager.observableState, options: NSKeyValueObservingOptions.New, context: &myContext)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        studentInformationManager.removeObserver(self, forKeyPath: StudentInformationManager.observableState)
    }
    
    // MARK: - KVO
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &myContext {
            let newState = change[NSKeyValueChangeNewKey] as! String
            
            if newState == StudentInformationManagerState.Ready {
                // Success: Get the data and reload the map
                currentStudentsInformation = studentInformationManager.currentStudentsInformation
                refreshDone()
                reloadMap()
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
    
    // MARK: UI activity
    
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
    
    // MARK: MKMapViewDelegate
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(StudentPinIdentifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: StudentPinIdentifier)
            annotationView.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        let detailButton: UIButton = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIButton
        annotationView.rightCalloutAccessoryView = detailButton

        return annotationView
    }

    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if control == view.rightCalloutAccessoryView {
            if let mediaURL = view.annotation.subtitle {
                if !URLUtils.openURL(string: mediaURL) {
                    showMessageWithTitle("Error", message: "Could not open URL: \(mediaURL)")
                }
            } else {
                showMessageWithTitle("Info", message: "No mediaURL assigned for this user")
            }
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func placeStudentLocation(sender: UIBarButtonItem) {
        if StudentInformationManager.sharedInstance.myStudentInformationExists() {
            showConfirmation(ConfirmationOverrideLocationMessage, resolutionHandler: {
                (confirmed) in
                if confirmed {
                    self.performSegueWithIdentifier(self.DefineStudentInformationIdentifier, sender: self)
                }
            })
        }
    }
    
    @IBAction func reloadStudentInformationOnMap(sender: AnyObject) {
        refreshInProgress()        
        studentInformationManager.refreshIfPossible()
    }
    
    // MARK: - Map Utilities
    
    func reloadMap() {
        // Remove annotations
        println("Removing: \(self.mapView.annotations.count)")
        if self.mapView.annotations.count > 0 {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        
        println("Adding: \(currentStudentsInformation!.count)")
        for studentInformation in currentStudentsInformation! {
            addStudentToMapView(studentInformation)
        }        
    }

    func addStudentToMapView(studentInformation: StudentInformation) {
        let annotation = buildAnnotationUsingStudentInformation(studentInformation)
        mapView.addAnnotation(annotation)
    }
    
    func buildAnnotationUsingStudentInformation(studentInformation: StudentInformation) -> MKAnnotation {
        let location = CLLocationCoordinate2D(latitude: studentInformation.latitude, longitude: studentInformation.longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = studentInformation.title
        annotation.subtitle = studentInformation.mediaURL
        
        return annotation
    }
    
}