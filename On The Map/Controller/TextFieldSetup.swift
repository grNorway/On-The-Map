//
//  TextFieldSetup.swift
//  On The Map
//
//  Created by scythe on 11/27/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import UIKit

class TextFieldSetup: NSObject, UITextFieldDelegate {

    //TextField beginEditing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        NotificationCenter.default.post(name: .UIKeyboardWillShow, object: nil)
        textField.becomeFirstResponder()
        
    }
    
    //TextField returns
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        NotificationCenter.default.post(name: .UIKeyboardWillHide, object: nil)
        textField.resignFirstResponder()
        return true
    }
    
}
