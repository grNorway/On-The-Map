//
//  MainTabBarController.swift
//  On The Map
//
//  Created by scythe on 12/5/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import UIKit


class MainTabBarController: UITabBarController {

    private struct Alerts {
        
        struct NetworkAlerts{
            static let errorTitle = "Error"
            static let errorLogOutMsg = "Unable To Log Out: "
        }
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "On The Map"
        refreshMap(nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.removeObserver(self, name:.putStudentOnParse, object: nil)
        
    }

    /* refresh the data on viewControllers[]
     1)refresh the map so if there are new pin location there will be shown
     2)refresh the tableView also so it can update the rows in case of a new location*/
    @IBAction func refreshMap(_ sender: UIBarButtonItem?) {
        (self.viewControllers![1] as! StudentsListTableViewViewController).loadingIndicator()
        
        ParseClient.sharedInstance().getStudentData { (success, errorString) in
            print("GetStudentData")
            DispatchQueue.main.async {
                if success{
                    print("Success Get Student Data")
                    (self.viewControllers![0] as! MapViewController).refreshMap()
                    
                    (self.viewControllers![1] as! StudentsListTableViewViewController).tableView?.beginUpdates()
                    
                    (self.viewControllers![1] as! StudentsListTableViewViewController).tableView?.endUpdates()
                    (self.viewControllers![1] as! StudentsListTableViewViewController).loadingView.removeFromSuperview()
                }else{
                    (self.viewControllers![1] as! StudentsListTableViewViewController).loadingView.removeFromSuperview()
                    self.showAlertGlobal(title: Alerts.NetworkAlerts.errorTitle, message: errorString!)
                    print("ERROR REFRESH MAP")
                }
            }
        }
    }
    
    /* calls PinViewController and checks if there has been already added an Location from the user */
    @IBAction func pinLocation(){

        if Storage.sharedInstance().user != nil {
            showAlertForPinViewController(title: "", message: "You have Already Posted a Student Location. Would You like to Overwrite Your Current Location?")
        }else{
            NotificationCenter.default.addObserver(self, selector: #selector(callRefresh), name: .putStudentOnParse , object: nil)
            let pinViewController = storyboard?.instantiateViewController(withIdentifier: "PinViewController") as! PinViewController
        present(pinViewController, animated: true, completion: nil)
        }
    }
    
    /* UIAlertController that inform the user if he has already post a location already and he want to overwrite it!  */
    func showAlertForPinViewController(title: String , message : String){
        let alertForPinViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let overwriteAction = UIAlertAction(title: "Overwrite", style: .default) { (action) in
            let pinViewController = self.storyboard?.instantiateViewController(withIdentifier: "PinViewController") as! PinViewController
            NotificationCenter.default.addObserver(self, selector: #selector(self.callRefresh), name: .putStudentOnParse , object: nil)
            self.present(pinViewController, animated: true, completion: nil)
            
        }
        
        alertForPinViewController.addAction(overwriteAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
            
        }
        
        alertForPinViewController.addAction(cancelAction)
        
        present(alertForPinViewController, animated: true, completion: nil)
    }
    
    //Calls refreshMap
    @objc func callRefresh(){
        refreshMap(nil)
    }

    //Log Out from the Udacityserver and Delete all the previous data that have been store.
    @IBAction func logOutButton(_ sender: UIBarButtonItem) {
        let loadingView = HudView.hud(inView: self.view, animated: true)
        
        UdacityClient.sharedInstance().udacityLogOut { (success, error) in
            
            DispatchQueue.main.async {
            
            if success{
                print("LOGOUT SUCCESS")
                self.deleteStorageData()
                loadingView.removeFromSuperview()
                self.dismiss(animated: true, completion: nil)
            }else{
                print(error!)
                loadingView.removeFromSuperview()
                self.showAlertGlobal(title: Alerts.NetworkAlerts.errorTitle, message: "\(Alerts.NetworkAlerts.errorLogOutMsg)\(error!)")
            }
            }
            
        }
    }
    
    //Deletes all the stored Data
    private func deleteStorageData(){
        Storage.sharedInstance().objectId = nil
        Storage.sharedInstance().studentInformation = nil
        Storage.sharedInstance().user = nil
        Storage.sharedInstance().students = [StudentInformation]()
    }
   
}


