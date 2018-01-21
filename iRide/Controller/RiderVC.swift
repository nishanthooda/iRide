//
//  RiderVC.swift
//  iRide
//
//  Created by Nishant Hooda on 2018-01-14.
//  Copyright © 2018 Nishant Hooda. All rights reserved.
//

import UIKit
import MapKit

class RiderVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UberController {
    
    @IBOutlet weak var riderMap: MKMapView!

    @IBOutlet weak var callUberButton: UIButton!
    
    
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    private var driverLocation: CLLocationCoordinate2D?
    
    private var timer = Timer();
    
    private var canCallUber = true
    private var riderCanceledRequest = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager()
        UberHandler.Instance.observeRiderMessages()
        UberHandler.Instance.delegate = self
        // Do any additional setup after loading the view.
    }
    
    private func initializeLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //if coordinate available
        if let location = locationManager.location?.coordinate{
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpanMake(0.01, 0.01))
            
            riderMap.setRegion(region, animated: true)
            
            riderMap.removeAnnotations(riderMap.annotations)
            
            if driverLocation != nil{
                if !canCallUber{
                    let driverAnnotation = MKPointAnnotation()
                    driverAnnotation.coordinate = driverLocation!
                    driverAnnotation.title = "Driver Location"
                    riderMap.addAnnotation(driverAnnotation)
                }
            }
            
            let annotation = MKPointAnnotation();
            annotation.coordinate = userLocation!
            annotation.title = "Driver Location"
            riderMap.addAnnotation(annotation)
        }
    }
    
    func updateDriverLocation(lat: Double, long: Double) {
        driverLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }

    @IBAction func callUber(_ sender: Any) {
        if userLocation != nil {
            if canCallUber{
                 UberHandler.Instance.requestUber(latitude: Double(userLocation!.latitude), longitutde: Double(userLocation!.longitude))
                
                timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(RiderVC.updateRiderLocation), userInfo: nil, repeats: true)
           
            }else {
                riderCanceledRequest = true
                UberHandler.Instance.cancelUber()
                timer.invalidate()
            }
        }
    }
    
    @objc func updateRiderLocation(){
        UberHandler.Instance.updateRiderLocation(lat: userLocation!.latitude, long: userLocation!.longitude)
    }
    
    func canCallUber (delegateCalled: Bool){
        if delegateCalled{
            callUberButton.setTitle("Cancel Uber", for: UIControlState.normal)
            canCallUber = false
        }else{
            callUberButton.setTitle("Call Uber", for: UIControlState.normal)
            canCallUber = true
        }
    }
    
    func driverAcceptedRequest(requestAccepted: Bool, driverName: String) {
        
        if !riderCanceledRequest{
            if requestAccepted {
                alertUser(title: "Uber Accepted", message: "\(driverName) accepted your Uber Request")
            }else {
                UberHandler.Instance.cancelUber()
                timer.invalidate()
                alertUser(title: "Uber Canceled", message: "\(driverName) canceled your Uber Request")
            }
        }
        riderCanceledRequest = false
    }
    
    @IBAction func logout(_ sender: Any) {
        if AuthProvider.Instance.logOut(){
            if !canCallUber {
                UberHandler.Instance.cancelUber()
                timer.invalidate()
            }
            
            dismiss(animated: true, completion: nil)
        }else{
            alertUser(title: "Error logging out", message: "Please try again later")
        }
    }
        
        private func alertUser(title: String, message: String){
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    
}
