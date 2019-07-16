//
//  InitialViewController.swift
//  AppTestBliss
//
//  Created by André Carvalho on 15/07/2019.
//  Copyright © 2019 André Carvalho. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    let requestManager = RequestManager()
    var ComeFromURL = false
    var urlID = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showSpinner(onView: self.view)
        self.CheckTheInternet()
        
    }
    
    
    //Check if the user have internet, if he have internet then make a server request to see the Health of the server. If not it will keep apearing an alert view so the user can retry the connection to the internet
    func CheckTheInternet ()
    {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            self.CheckServerHealth()
            
        }else{
            print("Internet Connection not Available!")
            let alert = UIAlertController(title: "Internet", message: "You dont have internet", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (UIAlertAction) in
                self.CheckTheInternet()
            }))
            self.present(alert,animated: true, completion: nil)
            
        }
    }
    //After we check the internet, if the user have internet, we will make a call to the server asking about his Health. If the server return OK we will check if the user comes from an URL it will open the details Screen, if not it will present the Questions TableView
    func CheckServerHealth()
    {
        //Request to check the server health
        requestManager.requestHealth { (result, error) in
            if(result == "OK")
            {
                
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "QuestionsViewController") as! QuestionsViewController
                let navController = UINavigationController(rootViewController: vc)
                if(self.ComeFromURL)
                {
                    vc.FromURL = true
                    vc.questionUrlID = self.urlID
                }
                self.present(navController, animated: true, completion: nil)
            }
            else
            {
                
                let alert = UIAlertController(title: "Server Health", message: "Fetching server health", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (UIAlertAction) in
                    self.CheckServerHealth()
                }))
                self.present(alert,animated: true, completion: nil)
                
            }
        }
    }
}
