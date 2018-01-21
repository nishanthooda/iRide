//
//  File.swift
//  iRide
//
//  Created by Nishant Hooda on 2018-01-14.
//  Copyright © 2018 Nishant Hooda. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol UberController: class {
    func canCallUber (delegateCalled: Bool)
    func driverAcceptedRequest (requestAccepted: Bool, driverName: String)
    func updateDriverLocation (lat: Double, long: Double)
}

class UberHandler {
    private static let _instance = UberHandler()
    
    static var Instance: UberHandler {
        return _instance
    }
    
    weak var delegate: UberController?
    
    func observeRiderMessages(){
        //RIDER REQUESTED UBER
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded){
            (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.rider {
                        self.rider_id = snapshot.key
                        self.delegate?.canCallUber(delegateCalled: true)
                    }
                }
            }
        }
        //RIDER CANCELLED UBER
        DBProvider.Instance.requestRef.observe(DataEventType.childRemoved){
            (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.rider {
                        self.delegate?.canCallUber(delegateCalled: false)
                    }
                }
            }
        }
        //Driver Accepted Uber
        DBProvider.Instance.requestAcceptedRed.observe(DataEventType.childAdded) {(snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String{
                    if self.driver == ""{
                        self.driver = name
                        self.delegate?.driverAcceptedRequest(requestAccepted: true, driverName: self.driver)
                    }
                }
            }
        }
        DBProvider.Instance.requestAcceptedRed.observe(DataEventType.childRemoved) {(snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if name == self.driver{
                        self.driver = ""
                        self.delegate?.driverAcceptedRequest(requestAccepted: false, driverName: name)
                    }
                }
            }
        }
        
        //DRIVER UPDATING LOCATION
        DBProvider.Instance.requestAcceptedRed.observe(DataEventType.childChanged) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String{
                    if name == self.driver{
                        if let lat = data[Constants.latitude] as? Double{
                            if let long = data[Constants.longitude] as? Double{
                                self.delegate?.updateDriverLocation(lat: lat, long: long)
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    var rider = ""
    var driver = ""
    var rider_id = ""
    
    func requestUber (latitude: Double, longitutde: Double){
        let data: Dictionary<String, Any> = [Constants.NAME: rider, Constants.latitude: latitude, Constants.longitude: longitutde];
        DBProvider.Instance.requestRef.childByAutoId().setValue(data)
    }//requestUber
    
    func cancelUber (){
        DBProvider.Instance.requestRef.child(rider_id).removeValue();
    }
    
    func updateRiderLocation(lat: Double, long: Double){
        DBProvider.Instance.requestRef.child(rider_id).updateChildValues([Constants.latitude: lat, Constants.longitude: long])
    }
}
