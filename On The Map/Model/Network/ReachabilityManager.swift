//
//  ReachabilityManager.swift
//  On The Map
//
//  Created by scythe on 11/28/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import Foundation
import UIKit
import ReachabilitySwift

class ReachabilityManager : NSObject{
    
    static let shared = ReachabilityManager()
    
    var isNetworkAvailable : Bool {
        return reachabilityStatus != .none
    }
    
    var reachabilityStatus : Reachability.NetworkStatus = .notReachable
    
    let reachability = Reachability()!
    
    func startMonitoring(){
        print("Reachability Notification Started")
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: ReachabilityChangedNotification, object: reachability)
        
        do{
            try reachability.startNotifier()
        }catch{
            print("Can not start Reachabilty Notifier")
        }
    }
    
    @objc func reachabilityChanged(notification: Notification) {
        let reachability = notification.object as! Reachability
        
        switch reachability.currentReachabilityStatus{
        case .notReachable:
            print("Network Become Unreachable")
            
        case .reachableViaWiFi:
            print("Network reachable though WiFi")
            reachabilityStatus = .reachableViaWiFi
        case .reachableViaWWAN:
            print("Network reachable though Cellular Data")
            reachabilityStatus = .reachableViaWWAN
        }
    }
    
    func stopMonitoring(){
        
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: reachability)
        print("Reachability Notification Stopped")
    }
    
    
    
    
    
    
}


