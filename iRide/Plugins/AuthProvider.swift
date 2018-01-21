//
//  AuthProvider.swift
//  iRide
//
//  Created by Nishant Hooda on 2018-01-13.
//  Copyright © 2018 Nishant Hooda. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias LoginHandler = (_ msg: String?) -> Void;

struct LogInErrorCodes {
    static let INVALID_EMAIL = "Email not found, please sign up first"
    static let INVALID_PASSWORD = "Incorrect password, please enter the correct password!"
    static let EMAIL_IN_USE = "Email is already is use, please select a different email"
    static let WEAK_PASSWORD = "Password should be atleast 6 characters long"
    static let USER_NOT_FOUND = "No such user exists in the database"
    static let PROBLEM_CONNECTING = "Servers are currently down, please try again later"
}

class AuthProvider{
    private static let _instance = AuthProvider()
    
    static var Instance: AuthProvider{
        return _instance
    }
    
    func login(withEmail: String, password: String, loginHandler: LoginHandler?){
        Auth.auth().signIn(withEmail: withEmail, password: password, completion: {(user, error) in
            if error != nil {
                self.handleErrors(err: error! as NSError, loginHandler: loginHandler)
            }else{
                loginHandler?(nil)
            }
            
        })
    }//login Func
    
    func signUp(withEmail: String, password: String, loginHandler: LoginHandler?){
        Auth.auth().createUser(withEmail: withEmail, password: password, completion: {(user, error) in
            if error != nil {
                self.handleErrors(err: error! as NSError, loginHandler: loginHandler)
            }else{
                if user?.uid != nil{
                    //store user in db
                    DBProvider.Instance.saveUser(withEmail: withEmail, password: password, withID: user!.uid)
                    
                    //login user
                    self.login(withEmail: withEmail, password: password, loginHandler: loginHandler)
                }
            }
        })
    }//signup func
    
    func logOut () -> Bool{
        if Auth.auth().currentUser != nil{
            do{
                try Auth.auth().signOut()
                return true
            }catch {
                return false
            }
        }
        return true
    }
    
    private func handleErrors (err: NSError, loginHandler: LoginHandler?){
        
        if let errorCode = AuthErrorCode(rawValue: err.code){
            
            switch errorCode{
            case .wrongPassword:
                loginHandler?(LogInErrorCodes.INVALID_PASSWORD)
                break;
            case .invalidEmail:
                loginHandler?(LogInErrorCodes.INVALID_EMAIL)
                break
            case .userNotFound:
                loginHandler?(LogInErrorCodes.USER_NOT_FOUND)
                break
            case .weakPassword:
                loginHandler?(LogInErrorCodes.WEAK_PASSWORD)
                break
            case .emailAlreadyInUse:
                loginHandler?(LogInErrorCodes.EMAIL_IN_USE)
                break
            default:
                loginHandler?(LogInErrorCodes.PROBLEM_CONNECTING)
                break
            }
            
        }
    }//handleErrors
    
    
}
