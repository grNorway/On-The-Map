//
//  LoginViewController.swift
//  On The Map
//
//  Created by scythe on 11/27/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak private var emailTextField: UITextField!
    @IBOutlet weak private var passwordTextField: UITextField!
    @IBOutlet weak private var loginLabel: UILabel!
    @IBOutlet weak private var loginButton: UIButton!
    
    private let textFieldDelegate = TextFieldSetup()
    
    private enum errorsTextFields {
        case emailTextField
        case passwordTextField
        case bothTextFields
        case wrongCredentials
    }
    
    private struct Alerts {
        
        /* Error Titles */
        static let errorTitle = "Error"
        static let errorNetwork = "Network Error"
        
        /* Error Messages */
        static let emailAlertMsg = "Email can not be Empty. Please Enter your Email!"
        static let passwordAlertMsg = "Password can not be Empty. Please enter you Password!"
        static let bothTextAlertMsg = "Please fill in your Email and Password."
        static let networkAlertMsg = "The Internet Connection Appears to be Offline"
        static let credentialsAlertMsg = "Wrong Username or Passowrd. Please check you Username or Password and Login again!"
   
    }
    
    //MARK: Life Cicle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupTextFields(textField: emailTextField, placeholderText: "Email")
        setupTextFields(textField: passwordTextField, placeholderText: "Password")
        loginLabelUColor()
        tapGesture()
        subscribeNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeNotifications()
    }
    
    //Setup the placeHolder text in 15
    private func setupTextFields(textField : UITextField,placeholderText : String){
        
        textField.delegate = textFieldDelegate
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftView = paddingView
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText,
                                                             attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0/255, green: 180/255, blue: 230/255, alpha: 1)])
        
        textField.leftViewMode = UITextFieldViewMode.always
    }
    
    //Just change the color on Letter U on LoginLabel
    private func loginLabelUColor(){
        
        let text = "Login with Udacity"
        let range = (text as NSString).range(of: "U")
        let UColor = UIColor(red: 0/255, green: 180/255, blue: 230/255, alpha: 1)
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UColor , range: range)
        loginLabel.attributedText = attributedString
    }
    
    //Enables Observers
    private func subscribeNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    //Remove Observers
    private func unsubscribeNotifications(){
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }

   //Login Button
    @IBAction func loginButton(_ sender: UIButton?) {
        
        resignTextFields()
        if emailTextField.text == "" && passwordTextField.text == "" {
            
            ShowAlert(Alerts.errorTitle, Alerts.bothTextAlertMsg, errorTextField: .bothTextFields)
            
        }else if emailTextField.text == ""{
            ShowAlert(Alerts.errorTitle, Alerts.emailAlertMsg, errorTextField: .emailTextField)
        }else if passwordTextField.text == ""{
            ShowAlert(Alerts.errorTitle, Alerts.passwordAlertMsg, errorTextField: .passwordTextField)
        }else{
            let loadingView = HudView.hud(inView: view, animated: true)
            
            
           
            UdacityClient.sharedInstance().username = emailTextField.text!
            UdacityClient.sharedInstance().password = passwordTextField.text!
            
            UdacityClient.sharedInstance().authenticateWithUdacity({ (success, error) in
                
                DispatchQueue.main.async {
                    
                if success{
                    print("Success Connection To Udacity Server")
                    print(UdacityClient.sharedInstance().sessionID!)
                    print(UdacityClient.sharedInstance().userID!)
                    loadingView.removeFromSuperview()
                    
                    //Login to Next ViewController
                    self.performSegue(withIdentifier: "mapSegue", sender: self)
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                }else{
                    loadingView.removeFromSuperview()
                    print("Error Connnecting to Udacity Server")
                    print(error!)
                    
                    
                    self.ShowAlert(Alerts.errorTitle, error!, errorTextField: .wrongCredentials)
                }
                    
                }
            })
    
        }
        
    }
    
    /* Global UIAlertController  */
    private  func ShowAlert(_ title : String ,_ message : String, errorTextField : errorsTextFields){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            switch errorTextField {
            case .emailTextField :
                self.emailTextField.text = ""
            case .passwordTextField:
                self.passwordTextField.text = ""
            case .bothTextFields :
                
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
            case .wrongCredentials:
                self.emailTextField.clearButtonMode = .whileEditing
                self.passwordTextField.clearButtonMode = .whileEditing
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func resignTextFields(){
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    
    @IBAction func signUpButton(_ sender: UIButton) {
        openURL(urlString: "http://www.udacity.com")
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "mapSegue" {
//            let tabController = segue.destination as! UINavigationController
//            print("!!!!!")
//            alertForNetworkUnavailability()
//
//        }
    }
    
    private func tapGesture(){
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(removeKeyboardGesture(byReactingTo:)))
        tapRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func removeKeyboardGesture(byReactingTo tapRecognizer: UIGestureRecognizer){
        
        if tapRecognizer.state == .ended {
            resignTextFields()
            keyboardWillHide(nil)
        }
        
    }
    

}

extension LoginViewController {
    
    //TextField Setup / Notifications
    
    @objc func keyboardWillShow(_ notification : Notification){
        view.frame.origin.y -= getKeyboardHeight(notification)

    }

    func getKeyboardHeight(_ notification : Notification) -> CGFloat {

        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            return keyboardHeight
        }
        return 0
    }

    @objc func keyboardWillHide(_ notification : Notification?){
        view.frame.origin.y = 0
    }
    
}
































