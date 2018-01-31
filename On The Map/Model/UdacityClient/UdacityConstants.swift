//
//  UdacityConstants.swift
//  On The Map
//
//  Created by scythe on 11/27/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

extension UdacityClient {
    
    //MARK: Constants
    struct Constants {
    
        //MARK: URL's
        static let udacityScheme = "https"
        static let udacityHost = "www.udacity.com"
        static let udacityPath = "/api"
    }
    
    //MARK: Methods
    struct Methods {
        static let udacitySession = "/session"
        static let udacityUserIDAccount = "/users/{id}"
    }
    
    
    struct JSONResponseKeys {
        
        //MARK: Authorization
        static let Session = "session"
        static let SessionID = "id"
        
        //MARK: USERID
        static let user = "user"
        static let firstname = "first_name"
        static let lastname = "last_name"
        
        //MARK: Account
        static let Account = "account"
        static let userID = "key"
        
    }
    
    struct ParameterKeys {
        static let userID = "id"
    }
    
    struct Errors {
        
        static let internalError = "Internal Error. Please contact the Supporting Team! "
        static let credentialError = "Account not found or invalid credentials."
        static let status2xxError = "Status Error 2xx: Please contact the Supporting Team! "
        
        
    }
    
    
    
}
