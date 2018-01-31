//
//  UdacityUser.swift
//  On The Map
//
//  Created by scythe on 12/5/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import Foundation

struct UdacityUser {
    
    var id : String = ""
    var firstName = ""
    var lastName = ""
    
    init(id : String,firstName : String , lastName : String) {
        self.firstName = firstName
        self.lastName = lastName
        self.id = id
    }
    
}
