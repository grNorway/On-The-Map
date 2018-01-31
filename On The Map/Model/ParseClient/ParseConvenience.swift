//
//  ParseConvenience.swift
//  On The Map
//
//  Created by scythe on 11/29/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import Foundation

extension ParseClient {
    
    
    /* Get function that gets called when the MapViewController 'viewWillLoad()' called and return the data from Parse/Udacity server to studentArrayLoaded  */
    func getStudentData( completionHandlerGetStudentDictionary: @escaping (_ success : Bool , _ errorString : String?) -> ()){
        
        getStudentsInfo { (success, studentArray, error) in
            print("getStudentsInfo")
            if success{
                
                self.parse(array: studentArray!, { (success, studentArrayFinished, errorString) in
                    print("parse")
                    if success {
                        if let array = studentArrayFinished  {
                            if self.sortArray(array: array){
                            
                                completionHandlerGetStudentDictionary(true, nil)
                            }else{
                                completionHandlerGetStudentDictionary(false,"Server Error. Contact Supporting Team!")
                            }
                            
                        }else{
                            
                        }
                    }else{
                        
                        completionHandlerGetStudentDictionary(false,errorString!)
                    }
                })
            }else{
                
                completionHandlerGetStudentDictionary(false, error!)
            }
        }
        
    }
    
    
    /* Conects to parse/udacity server and gets data ["results"] */
    func getStudentsInfo(_ completionHadnlerForGetStudentsInfo : @escaping (_ success : Bool , _ studentArray : [[String: AnyObject]]?, _ errorString : String?) -> ()){
    
        let parameters = [ParseClient.ParametersKeys.limit : ParseClient.ParameterValues.limitValue,
                          ParseClient.ParametersKeys.order : ParseClient.ParameterValues.orderValue]
        
        let _ = taskForGetMethod(parameters: parameters as [String: AnyObject]) { (result, error) in
            
            guard error == nil else{
                
                completionHadnlerForGetStudentsInfo(false,nil, error!.localizedDescription)
                return
            }
            
            if let resultsArray = result![ParseClient.JSONRespnseKeys.parseResults] as? [[String:AnyObject]] {
                completionHadnlerForGetStudentsInfo(true, resultsArray, nil)
            }else{
                print("There was no Key '\(ParseClient.JSONRespnseKeys.parseResults)' in \(result!)")
                completionHadnlerForGetStudentsInfo(false, nil, ParseClient.Errors.internalError )
            }
            
        }
        
    }
    
    /* Parse's the ResultsArray from server and calls the ParseStudent. When Parse sudent finishes it appends the results to  studentInfoArray and send this back if it is successfull */
    func parse(array studentArray : [[String: AnyObject]] ,_ completionHandlerForPARSE : @escaping(_ success:Bool , _ studentArrayFinished: [StudentInformation]? , _ errorString : String?) -> ()){
        
        if studentArray.isEmpty{
            print("The StudentArrayFrom Parse Server was empty")
            completionHandlerForPARSE(false, nil, ParseClient.Errors.internalError)
        }else{
            
        var studentInfoArray :[StudentInformation] = []
        
        for studentInfo in studentArray {
             parseStudent(studentDict: studentInfo, completionHandlerForParseStudent: { (student) in
    
                    studentInfoArray.append(student)
            })
        }
        completionHandlerForPARSE(true, studentInfoArray, nil)
        }        
    }
    
    
    /* Parsing each Dictionary into a StudentInformation object and send it back  */
    
    func parseStudent(studentDict : [String: AnyObject], completionHandlerForParseStudent: @escaping (_ student : StudentInformation ) -> ()){
 
        let student = StudentInformation(dictionary: studentDict)
        
        completionHandlerForParseStudent(student)
    }
    
    
    
    func postStudentOnParse( _ completionHandlerForPostStudentOnParse: @escaping (_ success: Bool ,_ objectID : String? , _ errorString : String? )->() ){
        print("POST STUDENT ON PARSE")
        let parameters = [String : AnyObject]()
        let jsonBody =  "{\"\(JSONBodyKeys.uniqueKey)\":\"\(Storage.sharedInstance().user!.id)\",\"\(JSONBodyKeys.firstName)\":\"\(Storage.sharedInstance().user!.firstName)\",\"\(JSONBodyKeys.lastName)\":\"\(Storage.sharedInstance().user!.lastName)\",\"\(JSONBodyKeys.mapString)\":\"\(Storage.sharedInstance().studentInformation!.mapString)\",\"\(JSONBodyKeys.mediaURL)\":\"\(Storage.sharedInstance().studentInformation!.mediaURL)\",\"\(JSONBodyKeys.latitude)\":\(Storage.sharedInstance().studentInformation!.latitude),\"\(JSONBodyKeys.longitude)\":\(Storage.sharedInstance().studentInformation!.longitude)}"
        

    
        let _ = taskForPutPostMethod(method: "", httpMethod: httpMethod.post.rawValue, parameters: parameters, jsonBody: jsonBody) { (result, error) in
        
            if let error = error {
                completionHandlerForPostStudentOnParse(false, nil, error.localizedDescription)
            }else{
                
                print("TASK POST RESULT : \(result!)")
                if let objectID = result![JSONRespnseKeys.objectID] as? String {
                    completionHandlerForPostStudentOnParse(true, objectID, nil)
                }else{
                    completionHandlerForPostStudentOnParse(false, nil, "Unable To find Key \(JSONRespnseKeys.objectID)")
                }
            }
        }
    
    }
    
    func putStudentOnParse(_ completionHandlerForPutStudentOnParse: @escaping (_ success : Bool , _ errorString : String?)->()){
       
        let parameters = [String : AnyObject]()
        let jsonBody = "{\"\(JSONBodyKeys.uniqueKey)\" : \"\(Storage.sharedInstance().studentInformation!.uniqueKey)\",\"\(JSONBodyKeys.firstName)\":\"\(Storage.sharedInstance().studentInformation!.firstname)\",\"\(JSONBodyKeys.lastName)\":\"\(Storage.sharedInstance().studentInformation!.lastname)\",\"\(JSONBodyKeys.mapString)\":\"\(Storage.sharedInstance().studentInformation!.mapString)\",\"\(JSONBodyKeys.mediaURL)\":\"\(Storage.sharedInstance().studentInformation!.mediaURL)\",\"\(JSONBodyKeys.latitude)\":\(Storage.sharedInstance().studentInformation!.latitude),\"\(JSONBodyKeys.longitude)\":\(Storage.sharedInstance().studentInformation!.longitude)}"
        
        var mutableMethod = Constants.putStudent
        mutableMethod = substituteKeyInMethod(mutableMethod, key: JSONRespnseKeys.objectID, value: Storage.sharedInstance().objectId!)!
 
            let _ = taskForPutPostMethod(method: mutableMethod, httpMethod: httpMethod.put.rawValue, parameters: parameters, jsonBody: jsonBody, completionHandlerForPutPostMethod: { (success, error) in
                
                if error != nil {
                    completionHandlerForPutStudentOnParse(false, error!.localizedDescription)
                }else{
                    completionHandlerForPutStudentOnParse(true, nil)
                }
            })
    
    }
    
   
    
}
