//
//  File.swift
//  iRide
//
//  Created by Nishant Hooda on 2018-01-14.
//  Copyright © 2018 Nishant Hooda. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DBProvider {
    private static let _instance = DBProvider()
    
    static var Instance: DBProvider{
        return _instance
    }
    
    var dbRef: DatabaseReference{
        return Database.database().reference()
    }
    
    var ridersRef: DatabaseReference{
        return dbRef.child(Constants.RIDERS)
    }
    
    
    var requestRef: DatabaseReference{
        return dbRef.child(Constants.UBER_REQUEST)
    }
    
    var requestAcceptedRed: DatabaseReference{
        return dbRef.child(Constants.UBER_ACCEPTED)
    }
    
    func saveUser(withEmail: String, password: String, withID: String){
        let data: Dictionary<String, Any> = [Constants.EMAIL: withEmail, Constants.PASSWORD: password, Constants.isRider: true]
        
        ridersRef.child(withID).child(Constants.DATA).setValue(data)
    }
    
}
