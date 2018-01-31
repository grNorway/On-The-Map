//
//  ExtensionViewController.swift
//  On The Map
//
//  Created by scythe on 12/7/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func alertForNetworkUnavailability(){
        print("alertForNetworkUnavailability")
        guard ReachabilityManager.shared.reachabilityStatus != .notReachable else{
            self.showAlertGlobal(title: "Error", message: "Network Become Unreachable")
            return
        }
    }
    
    func showAlertGlobal(title: String , message : String){
 
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    /*Global Function that opens a url on Safari.
     Checks the url if it contains a "https://" so can connect to the web */
    
    func openURL(urlString : String) {
        
        var urlString = urlString
        if urlString.contains("https://"){
            if let url = URL(string:urlString){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                return
            }
        }else{
            urlString = "https://\(urlString)"
            if let url = URL(string: urlString){
                print(url)
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }else{
                print("\(urlString) is not a valid URL")
                return
            }
        }
        
    
        
        
       
    }
    

    
}
