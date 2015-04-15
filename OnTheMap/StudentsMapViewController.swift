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

class StudentsMapViewController: UIViewController, MKMapViewDelegate, StudentInformationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let StudentPinIdentifier = "StudentPin"
    let DefineStudentInformationIdentifier = "DefineStudentInformation"
    
    let ConfirmationOverrideLocationMessage = "You have already posted a student location. Would you like to override your current Location?"
    
    var studentInformationManager: StudentInformationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        studentInformationManager = StudentInformationManager.sharedInstance
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        studentInformationManager.delegate = self
        
        studentInformationManager.refreshIfRequired({
            self.refreshInProgress()
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        studentInformationManager.delegate = nil
    }
    
    func refreshInProgress() {
        refreshButton.enabled = false
//        view.userInteractionEnabled = false
        self.activityIndicator.startAnimating()
    }
    
    func refreshDone() {
        refreshButton.enabled = true
//        view.userInteractionEnabled = true
        // Always set the alpha to Constants.UI.activeViewAlpha
//        view.alpha = Constants.UI.activeViewAlpha
        self.activityIndicator.stopAnimating()
    }
    
    
    func reloadMap() {
        // Remove annotations
        println("Removing: \(self.mapView.annotations.count)")
        if self.mapView.annotations.count > 0 {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        
        println("Adding: \(studentInformationManager.currentStudentsInformation!.count)")
        for studentInformation in studentInformationManager.currentStudentsInformation! {
            addStudentToMapView(studentInformation)
        }

    }
    
    // MARK: - StudentLocationManagerDelegate
    
    func studentsInformationDidFetch() {
        reloadMap()
        refreshDone()
    }
    
    func studentsInformationFetchError(error: NSError) {
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
        
        studentInformationManager.refreshStudentsInformation()
    }
    
    // MARK: - Map Utilities
    
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