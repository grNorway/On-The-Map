//
//  StudentsListTableViewViewController.swift
//  On The Map
//
//  Created by scythe on 12/19/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import UIKit

class StudentsListTableViewViewController: UIViewController,UITableViewDataSource , UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var loadingView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "udacityLargeLogo"))
        tableView.contentMode = .scaleAspectFill
        
        
    }
    
    /* Storage.sharedInstance().students.count is the number of students */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Storage.sharedInstance().students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let students = Storage.sharedInstance().students
        cell.imageView?.image = UIImage(named: "icon_pin")
        cell.textLabel?.text = "\(students[indexPath.row].firstname) \(students[indexPath.row].lastname)"
        
        if students[indexPath.row].mediaURL == "" {
            cell.detailTextLabel?.text = "Not available URL"
        }else{
            cell.detailTextLabel?.text = "\(students[indexPath.row].mediaURL)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openURL(urlString: Storage.sharedInstance().students[indexPath.row].mediaURL)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor(red: 31/255, green: 182/255, blue: 224/255, alpha: 0.8)
        cell.detailTextLabel?.textColor = UIColor(white: 0.9, alpha: 1)
        cell.textLabel?.textColor = UIColor(white: 1, alpha: 1)
        
    }
    
     func loadingIndicator(){
        loadingView = HudView.hud(inView: view, animated: true)
        
    }
    

}

