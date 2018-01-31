//
//  ParseClient.swift
//  On The Map
//
//  Created by scythe on 11/29/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class ParseClient {
   
    //MARK: Properties
    var session = URLSession.shared
    //var studentArrayLoaded : [StudentInformation] = []
    let dateFormatter = DateFormatter()
    
    enum httpMethod : String {
        case put = "PUT"
        case post = "POST"
    }

    
    //MARK: GET
     func taskForGetMethod(parameters : [String : AnyObject], completionHandlerForGet : @escaping (_ result : AnyObject? , _ error : NSError?) -> ()){
        
        let request = NSMutableURLRequest(url: parseURLFromParameters(parameters: parameters, withParametersExtension: nil))
        request.addValue(ParseClient.Constants.parserApplicationID, forHTTPHeaderField: ParseClient.Constants.parserApplicationHTTPHeader)
        request.addValue(ParseClient.Constants.parseApiKey, forHTTPHeaderField: ParseClient.Constants.APIHTTPHeader)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ errorString : String){
                print(errorString)
                let userInfo = [NSLocalizedDescriptionKey: errorString]
                completionHandlerForGet(nil, NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else{
                print("There was an error on the request : '\(request)'  ERROR : '\(String(describing: error))'")
                sendError(error!.localizedDescription)
                //ParseClient.Errors.errorNetwork = String(describing: error!)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else{
                sendError("\(ParseClient.Errors.status2xxError)")
                return
            }
            
            guard let data = data else{
                sendError("Data Not Found: \(ParseClient.Errors.internalError)")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandler: completionHandlerForGet)
   
        }
        task.resume()
        
    }
    

    func taskForPutPostMethod(method : String,httpMethod : String ,parameters : [String : AnyObject] ,jsonBody : String, completionHandlerForPutPostMethod : @escaping (_ result : AnyObject? , _ error : NSError?) -> () ){
        
        var request = URLRequest(url: parseURLFromParameters(parameters: parameters, withParametersExtension: method))
        request.httpMethod = httpMethod
        request.addValue(Constants.parserApplicationID, forHTTPHeaderField: Constants.parserApplicationHTTPHeader)
        request.addValue(Constants.parseApiKey, forHTTPHeaderField:Constants.APIHTTPHeader)
        request.addValue(Constants.XPARSEJSONValue, forHTTPHeaderField: Constants.XPARSEJSONHeader)
        request.httpBody = jsonBody.data(using: .utf8)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            print(request.url!)
            print(String(data: data!, encoding: .utf8)!)
            func sendError(_ errorString: String){
                print(errorString)
                let userInfo = [NSLocalizedDescriptionKey:errorString]
                completionHandlerForPutPostMethod(nil, NSError(domain: "completionHandlerForPutPostMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else {
                sendError(error!.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else{
                print(response!)
                sendError("Status Code Error 2xx")
                return
            }
            
            guard let data = data else{
                sendError("Data Error")
                return
            }
            
            
            
            self.convertDataWithCompletionHandler(data, completionHandler: completionHandlerForPutPostMethod)
            
        }
        task.resume()
    }
    /* Helpers */
    
    /* sorting the array in Descending order */
    func sortArray(array: [StudentInformation]) -> Bool {
        Storage.sharedInstance().students = array.sorted(by: { (student1, student2) -> Bool in
            
            if student1.dateUpdated != nil && student2.dateUpdated != nil{
                return student1.dateUpdated!.compare(student2.dateUpdated!) == .orderedDescending
                
            }else{
                //Since this is a Server Error (dateUpdated = nil) I am not sure If I need to have a UIAlert.!! ??
                print("*** sortArray : Server Error dateUpdated found nil Student1UpdatedDate:\(student1.dateUpdated!) , Student2UpdatedDate \(student2.dateUpdated!) ")

                return false
            }
        })
        return true
    }
    
    /* Return the URL for the taskForGetMethod */
    private func parseURLFromParameters(parameters : [String : AnyObject],withParametersExtension : String? = nil ) -> URL {
        
        var components = URLComponents()
        components.scheme = ParseClient.Constants.parseScheme
        components.host = ParseClient.Constants.parseHost
        components.path = ParseClient.Constants.parsePath + (withParametersExtension ?? "")
        
        components.queryItems = [URLQueryItem]()
        
        for (key,value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(queryItem)
        }
        
        return components.url!
    }
    
    func substituteKeyInMethod(_ method: String , key: String , value: String) -> String?{
        
        if method.range(of: "{\(key)}") != nil{
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        }else{
            return nil
        }
    }
    
    /* serialization data from data to JSON */
    private func convertDataWithCompletionHandler(_ data : Data , completionHandler : @escaping (_ result : AnyObject? , _ error : NSError?) -> ()){
        
        var parsedResult : AnyObject! = nil
        do{
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        }catch{
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse tha data from ParseServer into JSON"]
            completionHandler(nil, NSError(domain: "ConvertDataCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(parsedResult, nil)
    }
    
 
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }

    
}
















