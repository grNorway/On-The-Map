//
//  Storage.swift
//  On The Map
//
//  Created by scythe on 12/5/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

/*  Here we can have organized both data from UdacityServer and ParseServer */

import Foundation


class Storage {
    
    var user : UdacityUser? = nil
    var studentInformation : StudentInformation? = nil
    var objectId : String? = nil
    var students = [StudentInformation]()
    
    
    class func sharedInstance() -> Storage {
        struct Singleton {
            static var sharedInstance = Storage()
        }
        return Singleton.sharedInstance
    }
}
