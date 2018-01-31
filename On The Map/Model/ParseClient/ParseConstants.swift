//
//  ParseConstants.swift
//  On The Map
//
//  Created by scythe on 11/29/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import Foundation

extension ParseClient {
    
    //MARK: - Constants
    struct Constants {
        
        //MARK: Parse Api Key
        static let parseApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let APIHTTPHeader = "X-Parse-REST-API-Key"
        
        //MARK: Parse Application ID
        static let parserApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let parserApplicationHTTPHeader = "X-Parse-Application-Id"
        
        //MARK: Parse application/Json
        static let XPARSEJSONValue = "application/json"
        static let XPARSEJSONHeader = "Content-Type"
        
        //MARK: URLs
        static let parseScheme = "https"
        static let parseHost = "parse.udacity.com"
        static let parsePath = "/parse/classes/StudentLocation"
        static let postStudentURL = "https://parse.udacity.com/parse/classes/StudentLocation"
        static let putStudent = "/{objectId}"
    }
    
    //MARK: Parameter Keys
    struct ParametersKeys {
        
        static let limit = "limit"
        static let order = "order"
    }
    
    //MARK: Parameter Values
    struct ParameterValues{
        
        static let limitValue = "100"
        static let orderValue = "-updatedAt"
    }
    
    //MARK: JSON Response Keys
    struct JSONRespnseKeys {
    
        static let parseResults = "results"
        static let objectID = "objectId"
    
    }
    
    //MARK: JSON BODY KEYS
    struct JSONBodyKeys {
        
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let uniqueKey = "uniqueKey"
        static let latitude = "latitude"
        static let longitude = "longitude"
    }
    
    struct Errors{
        
        static var status2xxError = "Status 2xx error. Contact supporting team!"
        static var internalError = "Internal Error. Contact Supporting Team!"
    }
    
    //MARK: POST METHOD
    struct Post {
//        static let XParseAPPlicationIDValue = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
//        static let XParseApplicationIDHeader = "X-Parse-Application-Id"
//
//        static let XPARSEAPIKEYValue = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
//        static let XPARSEAPIKEYHeader = "X-Parse-REST-API-Key"
        
        
        
    }
    
    
    
    
    
    
    
    
    
}
