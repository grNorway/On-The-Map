//
//  PinViewController.swift
//  On The Map
//
//  Created by scythe on 12/8/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class PinViewController: UIViewController {

    //Properties
    private struct Alerts{
        static let errorGenTitle = "Error"
        static let errorMsgLocationTxtEmpty = "Please Enter Your Location!"
        static let errorMsgUrlTxtEmpty = "Please Enter you URL and then Press Submit!"
    }
    
    @IBOutlet weak var stackView1: UIStackView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var stackView2: UIStackView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var findOnTheMap: UIButton!
    @IBOutlet weak var WhereAreYouLabel: UILabel!
    
    var student: StudentInformation?
    var coordinates : CLLocationCoordinate2D?
    var location : String?
    var objectID : String?
    
    private let textFieldDelegate = TextFieldSetup()
    
    //Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribeNotifications()
        tapGesture()
        setupWhereAreYouLabel()
        setupTextFields(textField: locationTextField, placeholderText: "Enter Your Location Here")
        setupTextFields(textField: urlTextField, placeholderText: "Enter Your URL")
        
        if Storage.sharedInstance().objectId == nil {
            
            //student = StudentInformation(firstname: "", lastname: "", mapString: "", mediaURL: "", uniqueKey: "", latitude: 0.0, longitude: 0.0, dateUpdated: Date())
            let dictionary = [String : AnyObject]()
            student = StudentInformation(dictionary: dictionary)
        }else{
            
            student = Storage.sharedInstance().studentInformation!
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeNotifications()
        
    }
    
    //addObservers for the keyboard
    private func subscribeNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    //Remove Observers
    private func unsubscribeNotifications(){
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    /*Checks the locationText if is "".If not unsubscribeNotificationKeyboard and calls
    geocodeLocation() to find the coordinated from the locationTextField */
    @IBAction func findLocation(_ sender: UIButton) {
        if locationTextField.text == "" {
            showAlertGlobal(title: Alerts.errorGenTitle, message: Alerts.errorMsgLocationTxtEmpty)
        }else{
            
            unsubscribeNotifications()
            
            location = locationTextField.text!
            print("LOCATION : \(location!)")
            geocodeLocation(location: locationTextField.text!)
            
        }
        
    }
    
    /* Geo-locate the address given String into coordinates  */
    private func geocodeLocation(location : String){
        let loadingView = HudView.hud(inView: view, animated: true)
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString( location, completionHandler: { (placemarks, error) in
             
            guard error == nil else{
                loadingView.removeFromSuperview()
                
                let errorString = self.checkError(error: error!)
                self.showAlertGlobal(title: Alerts.errorGenTitle, message: errorString)
                return
            }
            
            if let placemark = placemarks?.first {
                let annotation = MKPointAnnotation()
                annotation.coordinate.latitude = placemark.location!.coordinate.latitude
                annotation.coordinate.longitude = placemark.location!.coordinate.longitude
                
                self.coordinates = CLLocationCoordinate2D()
                self.coordinates!.latitude = annotation.coordinate.latitude
                self.coordinates!.longitude = annotation.coordinate.longitude
                
                self.mapView.addAnnotation(annotation)
                self.mapView.setRegion(MKCoordinateRegionMake(annotation.coordinate, MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)), animated: true)
            }
            
            loadingView.removeFromSuperview()
            
            print(self.coordinates!)
            self.stackView1.isHidden = true
            self.stackView2.isHidden = false
            self.submit.isHidden = false
            self.cancelButton.tintColor = UIColor(red: 74/255, green: 171/255, blue: 217/255, alpha: 1)
            
        })
    }
    
    
    /* Cancel and dismiss the PinViewController  */
    @IBAction func cancelButton(_ sender: UIButton) {
    
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /* Enable / Disable the UI according the needs of the functions */
    private func enableUI(enable: Bool){
        
        switch enable{
        case true:
           cancelButton.isEnabled = true
            submit.isEnabled = true
            findOnTheMap.isEnabled = true
        case false:
            cancelButton.isEnabled = false
            submit.isEnabled = false
            findOnTheMap.isEnabled = false
        }
        
    }
    
    //submits Data to ParseServer
    @IBAction func submitButton(_ sender : UIButton) {
        
        //Checks for empty TextField
        guard urlTextField.text != "" else{
            showAlertGlobal(title: Alerts.errorGenTitle, message: Alerts.errorMsgUrlTxtEmpty)
            return
        }
        
        let loadingView = HudView.hud(inView: view, animated: true)
 
        //Calls getPublicUserData() to get the personalInformation from UdacityServer
        UdacityClient.sharedInstance().getPublicUserData(userID: UdacityClient.sharedInstance().userID!) { (success, UserDataDict, errorString) in
            
            DispatchQueue.main.async {
 
                if success{
                    print("**** SUCCESS getPublicUserData")
                    guard let firstName = UserDataDict![UdacityClient.JSONResponseKeys.firstname] as? String else{
                        print("Unable to get personal information server Error1")
                        return
                    }
                    
                    guard let lastName = UserDataDict![UdacityClient.JSONResponseKeys.lastname] as? String else{
                        print("Unable to get personal information server Error2")
                        return
                    }
                    
                    self.student?.firstname = firstName
                    self.student?.lastname = lastName
                    self.student?.uniqueKey = UdacityClient.sharedInstance().userID!
                    
                    //Updates Storage.SharedInstance().user with the Data from UdacityServer
                    Storage.sharedInstance().user = UdacityUser(id: UdacityClient.sharedInstance().userID!, firstName: firstName, lastName: lastName)
                    self.updateStudentData()

                    
                    //Checks if we will use Post or Put by checking ObjectId
                    if Storage.sharedInstance().objectId == nil {
                        print("Found nil")
                        //Calls postStudentOnParse() to post data to ParseServer
                        ParseClient.sharedInstance().postStudentOnParse({ (success, objectID, errorString) in
                            DispatchQueue.main.async {
                                
                                
                                if success{
                                    print("Success Posting student on parse Server")

                                    Storage.sharedInstance().objectId = objectID!
                                    NotificationCenter.default.post(name: .putStudentOnParse, object: self)
                                    loadingView.removeFromSuperview()
                                    self.dismiss(animated: true, completion: nil)
                                }else{
                                    loadingView.removeFromSuperview()
                                    self.showAlertGlobal(title: Alerts.errorGenTitle, message: errorString!)
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                            
                        })

                    }else{
                        //We update the studentData()
                        self.updateStudentData()
                        print("Not nil")
                        
                        //Calls putStudentOnParse() to put(update) Data on ParseServer
                        ParseClient.sharedInstance().putStudentOnParse({ (success, errorString) in
                            
                            DispatchQueue.main.async {
                                
                            
                            if success{
                                print("Success PUT on parse function")
                                NotificationCenter.default.post(name: .putStudentOnParse, object: self)
                                loadingView.removeFromSuperview()
                                self.dismiss(animated: true, completion: nil)
                            }else{
                                print("Error on PUT on Parse \(errorString!)")
                                loadingView.removeFromSuperview()
                                self.showAlertGlobal(title: Alerts.errorGenTitle, message: errorString!)
                                self.dismiss(animated: true, completion: nil)
                            }
                                
                            }
                        })
                    }
                    
                }else{
                    loadingView.removeFromSuperview()
                    self.showAlertGlobal(title: Alerts.errorGenTitle, message: errorString!)
                }
            }
          
        }//----
 
    }
    
    
    //We update the student Data
    private func updateStudentData(){
        student?.latitude = coordinates!.latitude
        student?.longitude = coordinates!.longitude
        student?.dateUpdated = Date()
        student?.mapString = location!
        student?.mediaURL = urlTextField.text!
        
        Storage.sharedInstance().studentInformation = student!
     
    }
    
    //Setup the TextFields
    private func setupTextFields(textField:UITextField,placeholderText: String){
        textField.delegate = textFieldDelegate
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftView = paddingView
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText,
                                                             attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0/255, green: 180/255, blue: 230/255, alpha: 1)])
        
        textField.leftViewMode = UITextFieldViewMode.always
    }
    
    //Checks for the error.domain and code incase of geolocation being unable to find coordinates from LocationTextField.text
    private func checkError(error : Error) -> String{
        
        if let error = error as? NSError{
            
            if error.domain == kCLErrorDomain && error.code == 8 {
                return "Could not Find the Location you Enter. Please try a different one!"            
            }else if error.domain == kCLErrorDomain && error.code == 2 {
                return "The Internet connection appears to be offline"
            }
        }
        return error.localizedDescription
    }
    
    
    //Add a tapGesture on screen to remove keyboard from screen
    private func tapGesture(){
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(removeKeyboardGesture(byReactingTo:)))
        tapRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func removeKeyboardGesture(byReactingTo  tapRecognizer: UIGestureRecognizer){
        if tapRecognizer.state == .ended {
            resignTextFields()
            keyboardWillHide(nil)
        }
    }
    
    
    private func resignTextFields(){
        locationTextField.resignFirstResponder()
        urlTextField.resignFirstResponder()
    }
    
    
    //setup the text on WhereAreYouLabel
    private func setupWhereAreYouLabel(){
        let text = "Where are you Studying today?"
        let range = (text as NSString).range(of: "Studying")
        let UColor = UIColor(red: 37/255, green: 78/255, blue: 234/255, alpha: 1)
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UColor , range: range)
        attributedString.addAttributes([NSAttributedStringKey.foregroundColor : UColor,NSAttributedStringKey.font : UIFont(name:"HelveticaNeue-CondensedBlack", size: CGFloat(40))!], range: range)
        
        WhereAreYouLabel.attributedText = attributedString
    }

}

extension PinViewController{
    
    @objc func keyboardWillShow(_ notitication : Notification){
        view.frame.origin.y -= 50
    }
    
    @objc func keyboardWillHide(_ notification: Notification?){
        view.frame.origin.y = 0
    }
    
}
