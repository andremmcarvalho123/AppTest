//
//  SecondViewController.swift
//  AppTestBliss
//
//  Created by André Carvalho on 12/07/19.
//  Copyright © 2019 André Carvalho. All rights reserved.
//

import UIKit


class DetailListController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    

    @IBOutlet weak var tblList: UITableView!
    // Manager where all server calls are located
    let requestManager = RequestManager()
    // Array object of the question clicked
    var myQuestion = [Questions]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblList.dataSource = self
        tblList.delegate = self
        view.backgroundColor = UIColor.yellow
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0)
        {
            return 174.0
        }
        else if(indexPath.row == self.myQuestion[0].choices.count + 1)
        {
            return 50.0
        }
        else
        {
            return 115.0
        }
    }

    var textField: UITextField?
    
    func configurationTextField(textField: UITextField!) {
        if (textField) != nil {
            self.textField = textField!        //Save reference to the UITextField
            self.textField?.placeholder = "Email";
        }
    }
    
    func openAlertView() {
        let alert = UIAlertController(title: "Share", message: "Add the email to share", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:{ (UIAlertAction) in
            //Request an POST call to share with the server
            self.requestManager.shareQuestion(email: self.textField!.text!, questionId: self.myQuestion[0].id) { (result, error) in
                if(result == "OK")
                {
                    self.ShareSucessfull()
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    //Return that the Share was sucessfully made
    func ShareSucessfull ()
    {
        let alerts = UIAlertController(title: "Share", message: "You have shared this content sucessfully", preferredStyle: .alert)
        alerts.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
            self.tblList.allowsSelection = false
        }))
        self.present(alerts,animated: true, completion: nil)
    }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == self.myQuestion[0].choices.count + 1)
        {
            openAlertView()
            
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myQuestion[0].choices.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0 )
        {

           // self.tblList.register(DetailsInfoCell.classForCoder(), forCellReuseIdentifier: "DetailsInfoCell")
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsTitleTableViewCell") as! DetailsTitleTableViewCell
            //asynchronously load the image
            let url = URL(string: self.myQuestion[indexPath.row].image_url)
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    cell.TItleImageView?.image = UIImage(data: data!)
                }
            }
            cell.TitleLabel.text = self.myQuestion[indexPath.row].question
            cell.selectionStyle = .none
            
            return cell
        }
        else if (indexPath.row == self.myQuestion[0].choices.count + 1)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShareTableViewCell") as! ShareTableViewCell
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChoiceCell") as! ChoiceCell
            cell.ChoiceTitle.text = self.myQuestion[0].choices[indexPath.row - 1].choice
            cell.selectionStyle = .none
        
            
            
            //Convert to String so we can show it on our View
            let countAsString = String(self.myQuestion[0].choices[indexPath.row - 1].votes
            )
            
            cell.ChoiceVotesCountLabel.text = countAsString
            cell.ChoiceVotesButton.tag = indexPath.row - 1
            cell.ChoiceVotesButton.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
           
            return cell
        }
        
       
    }
    
    func RequestServerQuestion()
    {
        
        
        requestManager.updateQuestionData(questionId: self.myQuestion[0].id) { (result, error) in
            // Remove all object into our array
            self.myQuestion.removeAll()
            // Add the object with the new votes into the array
            self.myQuestion.append(result)
            
            
                // Ask for Async, so the reload dont seems to make the tableview break and we reload it to show the new vote count
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.tblList.reloadData()
                })
            
                self.removeSpinner()
                
            
        }
        
        
        
    }
    
    
    @objc func buttonClicked(sender:UIButton)
    {
        let buttonRow = sender.tag
        RequestServerQuestion()
    }
}



/*
 
 updateQuestionData
 
 
 */
