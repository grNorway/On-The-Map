//
//  UdacityConvenience.swift
//  On The Map
//
//  Created by scythe on 11/28/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import UIKit
import Foundation


//MARK: - UdacityClient (Convenient Resource Methods)

extension UdacityClient {
    
    //MARK: - Authentication Get Method
    
    func authenticateWithUdacity(_ completionHandlerForAuth : @escaping (_ success : Bool , _ errorString : String?) -> () ){
        
        print("authenticateWithUdacity started")
        getSessionID { (_ success, _ sessionID, _ errorString) in
            if success{
                
                self.sessionID = sessionID
                print(sessionID!)
                self.getUserID({ (success, userID, errorString) in
                    if success{
                        self.userID = userID
                        completionHandlerForAuth(true, nil)
                    }else{
                        print("Unable to authenticate to Udacity (userID/Key)")
                        completionHandlerForAuth(false, errorString!)
                    }
                })
            }else{
                print("Unable to authenticate to Udacity (sessionID)")
                completionHandlerForAuth(false, errorString!)
            }
        }
    }
    
    /* Get the session ID */
    private func getSessionID(_ completionHandlerForSession: @escaping (_ success : Bool ,_ sessionID: String?,_ errorString : String? ) -> () ){
        print("get sessionIdD started")
        let jsonBody = "{\"udacity\": {\"username\": \"\(username!)\", \"password\": \"\(password!)\"}}"
        
        let _ = taskForPostMethod(_method: Methods.udacitySession, [:], jsonBody: jsonBody) { (result, error) in
         
            if error != nil {
                print(error!)
                //self.errorMessageAsign(error: error! )
                completionHandlerForSession(false, nil, error!.localizedDescription)
            }
            
            if let sessionArray = result?[UdacityClient.JSONResponseKeys.Session] as? [String:AnyObject] {
                if let sessionID = sessionArray[JSONResponseKeys.SessionID] as? String{
                    completionHandlerForSession(true, sessionID, nil)
                }else{
                    print("Error on getSessionID. Unable to find Key '\(JSONResponseKeys.SessionID)'")
                    completionHandlerForSession(false, nil, UdacityClient.Errors.internalError)
                }
            }else{
                print( "Error on getSessionID. Unable to find Key '\(JSONResponseKeys.Session)'")
                completionHandlerForSession(false, nil, UdacityClient.Errors.internalError)
            }
        }
    }
    
    /* Get the userID / Key */
    private func getUserID(_ completionHandlerForUserID : @escaping (_ success : Bool , _ userID: String? , _ errorString: String?) -> ()){
        
        let jsonBody = "{\"udacity\": {\"username\": \"\(username!)\", \"password\": \"\(password!)\"}}"
        
        let _ = taskForPostMethod(_method: Methods.udacitySession, [:], jsonBody: jsonBody) { (result, error) in
            
            guard error == nil else {
                print(error!)
                completionHandlerForUserID(false, nil, error!.localizedDescription)
                return
            }
            
            if let accountDict = result![JSONResponseKeys.Account] as? [String: AnyObject] {
                if let accountKey = accountDict[JSONResponseKeys.userID] as? String {
                    completionHandlerForUserID(true, accountKey, nil)
                }else{
                    print("Unable to find key '\(JSONResponseKeys.userID)'")
                    completionHandlerForUserID(false, nil, UdacityClient.Errors.internalError )
                }
            }else{
                print("Unable to find key '\(JSONResponseKeys.Account)'")
                completionHandlerForUserID(false, nil, UdacityClient.Errors.internalError)
            }
            
        }
    }
    
    func getPublicUserData(userID : String , _ completionHandlerForGetPuplicUserData : @escaping (_ success : Bool ,_ result: AnyObject?, _ errorString : String?) ->()){
        
        let parameters = [UdacityClient.ParameterKeys.userID : UdacityClient.sharedInstance().userID!]
        
        var mutableMethod : String = Methods.udacityUserIDAccount
        mutableMethod = substituteKeyInMethod(mutableMethod, key: UdacityClient.ParameterKeys.userID, value: String(UdacityClient.sharedInstance().userID!))!
        
        let _ = taskForGetMethod(mutableMethod, parameters as [String : AnyObject]) { (result, error) in
            
            if error != nil {
                print(error!)
                completionHandlerForGetPuplicUserData(false, nil, error!.localizedDescription)
            }else{
                
                if let userData = result![UdacityClient.JSONResponseKeys.user] as? [String:AnyObject]{
                    completionHandlerForGetPuplicUserData(true, userData as AnyObject, nil)
                }else{
                    print("USER KEY ERROR")
                    completionHandlerForGetPuplicUserData(false, nil, "Internal Error")
                }
                
            }
   
        }
        
    }
    
    
    func udacityLogOut(_ completiongHandlerForUdacityLogOut: @escaping (_ success : Bool , _ errorString : String?) -> ()){
        
        let parameters = [String:AnyObject]()
        let _ = taskForLogOutMethod(Methods.udacitySession, parameters) { (result, error) in
            
            if error != nil {
                print(error!.localizedDescription)
                completiongHandlerForUdacityLogOut(false, error!.localizedDescription)
            }else{
            guard let sessionDict = result![JSONResponseKeys.Session] as? [String : AnyObject] else{
                print("SessionDict Error : Could Not find the key \(JSONResponseKeys.Session) in Result : \(result!)")
                completiongHandlerForUdacityLogOut(false, "Internal Error ")
                return
            }
            
            guard let sessionID = sessionDict[JSONResponseKeys.SessionID] as? String else {
                print("SessionDict Error : Could Not find the key \(JSONResponseKeys.SessionID) in Result : \(result!)")
                completiongHandlerForUdacityLogOut(false, "Internal Error ")
                return
            }
                
                print("SESSIONID : \(sessionID)")
            completiongHandlerForUdacityLogOut(true, nil)
            print("LOGOUT DONE")
            }
        }
        
    }
    
    
    
    
}
























