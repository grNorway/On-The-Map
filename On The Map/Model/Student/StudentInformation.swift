//
//  StudentInformation.swift
//  On The Map
//
//  Created by scythe on 11/29/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

struct StudentInformation {
    
    var firstname : String
    var lastname : String
    var mapString : String
    var mediaURL : String
    var uniqueKey : String
    var latitude : Double
    var longitude: Double
    var dateUpdated : Date?
    let dateFormatter = DateFormatter()
    

    init(dictionary:[String : AnyObject]){
        
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let firstName = dictionary[ParseClient.JSONBodyKeys.firstName] as? String {
            self.firstname = firstName
        }else{
            self.firstname = ""
            print("Unable to find Key '\(ParseClient.JSONBodyKeys.firstName)' in dictionary '\(dictionary)'")
        }
        
        if let lastName = dictionary[ParseClient.JSONBodyKeys.lastName] as? String{
            self.lastname = lastName
        }else{
            self.lastname = ""
            print("Unable to find Key '\(ParseClient.JSONBodyKeys.lastName)' in dictionary '\(dictionary)'")
        }
        
        if let mapString = dictionary[ParseClient.JSONBodyKeys.mapString] as? String{
            self.mapString = mapString
        }else{
            self.mapString = ""
            print("Unable to find Key '\(ParseClient.JSONBodyKeys.mapString)' in dictionary '\(dictionary)'")
        }
        
        if let mediaURL = dictionary[ParseClient.JSONBodyKeys.mediaURL] as? String {
            self.mediaURL = mediaURL
        }else{
            self.mediaURL = ""
            print("Unable to find Key '\(ParseClient.JSONBodyKeys.mediaURL)' in dictionary '\(dictionary)'")
        }
        
        if let uniqueKey = dictionary[ParseClient.JSONBodyKeys.uniqueKey] as? String {
            self.uniqueKey = uniqueKey
        }else{
            self.uniqueKey = ""
            print("Unable to find Key '\(ParseClient.JSONBodyKeys.uniqueKey)' in dictionary '\(dictionary)'")
        }
        
        if let latitude = dictionary[ParseClient.JSONBodyKeys.latitude] as? Double {
            self.latitude = latitude
        }else{
            self.latitude = 0.0
            print("Unable to find Key '\(ParseClient.JSONBodyKeys.latitude)' in dictionary '\(dictionary)'")
        }
        
        if let longitude = dictionary[ParseClient.JSONBodyKeys.longitude] as? Double {
            self.longitude =  longitude
        }else{
            self.longitude = 0.0
            print("Unable to find Key '\(ParseClient.JSONBodyKeys.longitude)' in dictionary '\(dictionary)'")
        }
        
        if let date = dictionary["updatedAt"] as? String {
            
            if let dateUpdatedIntoDate = dateFormatter.date(from: date){
                self.dateUpdated = dateUpdatedIntoDate
            }else{
                self.dateUpdated = nil
                print("DATEFORMATTER EEEEERROR")
            }
        }else{
            self.dateUpdated = nil
            print("Unable to find Key 'updatedAt' in dictionary '\(dictionary)'")
        }

    }
}

extension StudentInformation : Equatable{
    static func ==(lhs: StudentInformation,rhs: StudentInformation) -> Bool{
        return lhs.mediaURL == rhs.mediaURL
    }
}
