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

class StudentsMapViewController: UIViewController, MKMapViewDelegate, StudentLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let StudentPinIdentifier = "StudentPin"
    let DefineStudentLocationIdentifier = "DefineStudentLocation"
    
    let ConfirmationOverrideLocationMessage = "You have already posted a student location. Would you like to override your current Location?"
    
    var studentLocationManager: StudentLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        studentLocationManager = StudentLocationManager.sharedInstance
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        studentLocationManager.delegate = self
        
        studentLocationManager.refreshIfRequired({
            self.refreshInProgress()
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        studentLocationManager.delegate = nil
    }
    
    func refreshInProgress() {
        view.userInteractionEnabled = false
        self.activityIndicator.startAnimating()
    }
    
    func refreshInProgressWithAlpha() {
        view.alpha = Constants.UI.inactiveViewAlpha
        refreshInProgress()
    }
    
    func refreshDone() {
        view.userInteractionEnabled = true
        // Always set the alpha to Constants.UI.activeViewAlpha
        view.alpha = Constants.UI.activeViewAlpha
        self.activityIndicator.stopAnimating()
    }
        
    
    func reloadMap() {
        // Remove annotations
        println("Removing: \(self.mapView.annotations.count)")
        if self.mapView.annotations.count > 0 {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        
        println("Adding: \(studentLocationManager.currentStudentLocations!.count)")
        for studentLocation in studentLocationManager.currentStudentLocations! {
            addStudentToMapView(studentLocation)
        }

    }
    
    // MARK: - StudentLocationManagerDelegate
    
    func studentLocationsDidFetch() {
        reloadMap()
        refreshDone()
    }
    
    func studentLocationsFetchError(error: NSError) {
        showMessageWithTitle("Error while updating the map", message: error.localizedDescription)
        refreshDone()
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
                if !openURL(string: mediaURL) {
                    showMessageWithTitle("Error", message: "Could not open URL: \(mediaURL)")
                }
            } else {
                showMessageWithTitle("Info", message: "No mediaURL assigned for this user")
            }
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func placeStudentLocation(sender: UIBarButtonItem) {
        if StudentLocationManager.sharedInstance.myLocationExists() {
            showConfirmation(ConfirmationOverrideLocationMessage, resolutionHandler: {
                (confirmed) in
                if confirmed {
                    self.performSegueWithIdentifier(self.DefineStudentLocationIdentifier, sender: self)
                }
            })
        }
    }
    
    @IBAction func reloadStudentLocationsOnMap(sender: AnyObject) {
        refreshInProgressWithAlpha()
        // Force a refresh
        studentLocationManager.refreshStudentLocations()
    }
    
    // MARK: - Map Utilities
    
    func addStudentToMapView(studentLocation: StudentLocation) {
        let annotation = buildAnnotationUsingStudentLocation(studentLocation)
        mapView.addAnnotation(annotation)
    }
    
    func buildAnnotationUsingStudentLocation(studentLocation: StudentLocation) -> MKAnnotation {
        let location = CLLocationCoordinate2D(latitude: studentLocation.latitude, longitude: studentLocation.longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = studentLocation.title
        annotation.subtitle = studentLocation.mediaURL
        
        return annotation
    }
    
}