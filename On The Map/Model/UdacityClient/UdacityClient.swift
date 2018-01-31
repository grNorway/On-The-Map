//
//  UdacityClient.swift
//  On The Map
//
//  Created by scythe on 11/27/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import Foundation


class UdacityClient{
    
    //MARK: - Properties
    
    var session = URLSession.shared
    
    // Authentication
    var sessionID : String? = nil
    var username : String? = nil
    var password : String? = nil
    var userID : String? = nil
    
    
    //MARK: - Post
    
    func taskForPostMethod(_method : String,_ parameters : [String:AnyObject], jsonBody : String? , completionHandlerForPostUdacity : @escaping (_ result: AnyObject? ,_ error: NSError?) -> ()){
        
        //var parameters : [String : AnyObject] = [:]
        /* Build URL , configure the Request */
        let request = NSMutableURLRequest(url: udacityURLFromParameters( [:], withPathExtension: UdacityClient.Methods.udacitySession))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody?.data(using: .utf8)
        
        /* make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ errorString : String) {
                let userInfo = [NSLocalizedDescriptionKey: errorString]
                completionHandlerForPostUdacity(nil, NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else {
                sendError("\(error!.localizedDescription)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode ,statusCode != 403 else{
                sendError("\(UdacityClient.Errors.credentialError)")
                return
                
            }
            
            guard  statusCode >= 200 && statusCode <= 299  else {
                sendError("\(UdacityClient.Errors.status2xxError)")
                return
            }
            
            guard let data = data else{
                print("No data was contained in request : '\(String(describing: error?.localizedDescription))'")
                sendError("Data Not Found: \(UdacityClient.Errors.internalError)")
                return
            }
            
            
            let newData = self.rangeData(data: data)
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPostUdacity)
            
        }
        task.resume()
        
    }
    
    //MARK: Get
    
    func taskForGetMethod(_ method : String , _ parameters : [String : AnyObject] , completionHandlerForGetMethod : @escaping (_ result : AnyObject? , _ error: NSError?) -> ()){
        
        let request = NSMutableURLRequest(url: udacityURLFromParameters(parameters, withPathExtension: method))
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ errorString : String){
                print(errorString)
                let userInfo = [NSLocalizedDescriptionKey: errorString]
                completionHandlerForGetMethod(nil, NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else{
                print(error!)
                sendError(error!.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else{
                print(error!)
                sendError(UdacityClient.Errors.status2xxError)
                return
            }
            
            guard let data = data else{
                print(error!)
                sendError("\(UdacityClient.Errors.internalError) : Data")
                return
            }
            
            let newData = self.rangeData(data: data)
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForGetMethod)
            
        }
        task.resume()
        
    }
    
    func taskForLogOutMethod(_ method : String ,_ parameters: [String:AnyObject], completionHandlerForLogOutMethod : @escaping (_ result : AnyObject? , _ error: NSError?) -> ()){
        
        let request = NSMutableURLRequest(url: udacityURLFromParameters(parameters, withPathExtension: method))
        request.httpMethod = "DELETE"
        
        var xsrfCookie : HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies!{
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        if let xsrfCookie = xsrfCookie{
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ errorString : String){
                print(errorString)
                let userInfo = [NSLocalizedDescriptionKey: errorString]
                completionHandlerForLogOutMethod(nil, NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else{
                print(error!)
                sendError(error!.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else{
                print(error!)
                sendError(UdacityClient.Errors.status2xxError)
                return
            }
            
            guard let data = data else{
                print(error!)
                sendError("\(UdacityClient.Errors.internalError) : Data")
                return
            }
            
            let newData = self.rangeData(data: data)
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForLogOutMethod)
            
        }
        task.resume()
            
        
    }
    
    //MARK: Helpers
    
    private func rangeData(data: Data) -> Data{
        let range = Range(5..<data.count)
        return data.subdata(in: range)
        
    }
    
    func substituteKeyInMethod(_ method: String , key: String , value: String) -> String?{
        
        if method.range(of: "{\(key)}") != nil{
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        }else{
            return nil
        }
    }
    
    /* Build the URL and send the URL  */
    func udacityURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = UdacityClient.Constants.udacityScheme
        components.host = Constants.udacityHost
        components.path = Constants.udacityPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()

        for (key,value) in parameters{
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(queryItem)
        }
        
        return components.url!
    }
    
    
    /* Checks the StatusCode and returns the Error Message accodring the status Code */
    private func statusCodeSwitch(statusCode : Int) -> String{
        switch statusCode {
        case 403:
            return "Status Code : 403. Account not found or invalid credentials."
        default:
            return "Status code Error :The statusCode was not 2xx!"
        }
    }
    
    /* Helper function serialization of into JSON */
    func convertDataWithCompletionHandler(_ data : Data , completionHandlerForConvertData: (_ result: AnyObject?, _ error : NSError?) -> () ){
        
        var parsedResult : AnyObject! = nil
        do{
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        }catch{
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON : \(data)"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
        
    }
    
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
    
}
