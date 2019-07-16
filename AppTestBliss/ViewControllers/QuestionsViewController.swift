//
//  FirstViewController.swift
//  AppTestBliss
//
//  Created by André Carvalho on 12/07/19.
//  Copyright © 2019 André Carvalho. All rights reserved.
//

import UIKit


class QuestionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblList: UITableView!
    
    // Where all the calls are located
    let requestManager = RequestManager()
    //Limit of objects per call
    var limit = 10
    // offset at the start of the server call
    var offset = 0
    // offset of the first search it will increase depending on the values
    var offsetSearching = 0
    // Boolean to check if the app was opened throw an url
    var FromURL = false
    // The ID of the question opened throw the url
    var questionUrlID = 0
    // Object to pass if the app opened throw an url
    var QuestionToPass = [Questions]()
    // Boolean to check if the user is searching in the SearchBar
    var searching =  false
    // Variable to save the text the user write in the SearchBar
    var searchText = ""
    // Array object to help the Questions count so we can add 10,6,0 questions to the table
    var myQuestions = [Questions]()
    // Array object of the Question returned by the server
    var recordsArray:[Questions] = [Questions]()
    // Array object of returned Questions matching the SearchText from the server
    var searchQuestion = [Questions]()
    
    override func viewDidAppear(_ animated: Bool) {
        
        if(self.FromURL)
        {
            requestManager.retriveQuestionID(id: questionUrlID) { (URLQuestion, error) in
                
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailListController") as? DetailListController
                
                self.QuestionToPass.append(URLQuestion)
                
                vc?.myQuestion = self.QuestionToPass
                
                
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            self.FromURL = false
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CheckTheInternet ()
        self.showSpinner(onView: self.view)
        self.tblList.dataSource = self
        self.tblList.delegate = self
        self.searchBar.delegate = self
        RequestServerQuestion(limit: limit, offset: offset, filter: searchText)
        self.tblList.tableFooterView = UIView(frame: .zero)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard !searchText.isEmpty else {
            searchQuestion = recordsArray;
            searching = false
            self.searchText = ""
            self.tblList.reloadData()
           
            return
        }
        
        self.searchText = searchText
        searching = true
        //searchQuestion = recordsArray.filter{$0.question.contains(self.searchText)}
        RequestServerQuestion(limit: limit, offset: offset, filter: searchText)
        
          self.tblList.reloadData()
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searching == true {
            return self.searchQuestion.count
        }
        else
        {
          return self.recordsArray.count
        }
        
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell") as! QuestionCustomCellTableViewCell
        var imageUrl = ""
        var questionString = ""
        
        if(self.searching)
        {
            imageUrl = self.searchQuestion[indexPath.row].image_url
            questionString = self.searchQuestion[indexPath.row].question
        }
        else
        {
            
            imageUrl = self.recordsArray[indexPath.row].image_url
            //To test with ID's or Rows Numbers
            // var index = String(indexPath.row)
            //questionString = index
              questionString = self.recordsArray[indexPath.row].question
        }
        //asynchronously load the image
        let url = URL(string: imageUrl)
        if(!url!.absoluteString.isEmpty)
        {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!)
                
                DispatchQueue.main.async {
                    cell.QuestionImageView?.image = UIImage(data: data!)
                }
            }
            
        }
        
        
        cell.QuestionTextLabel?.text = questionString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailListController") as? DetailListController
        
        if(self.searching)
        {
            vc?.myQuestion = [self.searchQuestion[indexPath.row]]
          
        }
        else
        {
            vc?.myQuestion = [self.recordsArray[indexPath.row]]
            
        }
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(searching)
        {
            if indexPath.row == searchQuestion.count - 1
            {
                
                
                // We are at last cell and need to bring more record as there maybe are some pending records available to be shown (if there is not any more record it wont add to the table)
                //Lets recall the method again so it will add the returned value from the server if there are 10 or only 4, in this case it will return the searching results
                RequestServerQuestion(limit: self.limit, offset: self.offsetSearching, filter: searchText)
                
            }
        }
        else
        {
            if indexPath.row == recordsArray.count - 1
            {
                // We are at last cell and need to bring more record as there maybe are some pending records available to be shown (if there is not any more record it wont add to the table)
                //Lets recall the method again so it will add the returned value from the server if there are 10 or only 4
                RequestServerQuestion(limit: self.limit, offset: self.offset, filter: searchText)
                
            }
        }
    }
    
    
    //Request to get the questions from the server, had to add a verification if the user is searching in the tableview or just scrolling on it if searching is true means that the user is searching
    func RequestServerQuestion(limit: Int, offset: Int, filter: String)
    {
        
        if(self.searching)
        {
            requestManager.requestForQuestionData(limit: limit, offset: self.offset, filter: searchText) { (result, error) in
                
                
                self.myQuestions = result[0]
                
                var index = 0
                self.offsetSearching =  self.offsetSearching + 10
                let returnedLimit = self.myQuestions.count
                
                while index < returnedLimit {
                   
                        self.searchQuestion.append(self.myQuestions[index])
                    
                    
                    index = index + 1
                }
                
                // Ask for Async so the reload dont seems to make the tableview break
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.tblList.reloadData()
                })
                self.removeSpinner()
                
                
            }
        }
        else
        {
            requestManager.requestForQuestionData(limit: limit, offset: self.offsetSearching, filter: searchText) { (result, error) in
                
                
                self.myQuestions = result[0]
                
                var index = 0
                self.offset =  self.offset + 10
                let returnedLimit = self.myQuestions.count
                
                while index < returnedLimit {
                    
                    self.recordsArray.append(self.myQuestions[index])
                    
                    index = index + 1
                }
                
                // Ask for Async so the reload dont seems to make the tableview break
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.tblList.reloadData()
                })
                self.removeSpinner()
                
                
            }
        }
        
        
       
    }
    //Will run in background after each 5 secounds checking for internet, if there is no internet a popup will appear asking to retry
    func CheckTheInternet ()
    {
        
        
        DispatchQueue.background(delay: 5.0, completion: {
            //Do something in background
            self.CheckTheInternet ()
            if Reachability.isConnectedToNetwork(){
                print("Internet Connection Available!")
                
            }else{
                print("Internet Connection not Available!")
                let alert = UIAlertController(title: "Internet", message: "You dont have internet", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (UIAlertAction) in
                    self.CheckTheInternet()
                }))
                self.present(alert,animated: true, completion: nil)
                
            }
        })
        
        
    }
    
    @objc func loadTable() {
        tblList.reloadData()
        
    }
    //Perform a function after 1 secound so we can refresh our tableview in that away make the tableview run smoothly
    func loadMoreData()
    {
        self.perform(#selector(loadTable), with: nil, afterDelay: 1.0)
    }
    
}


// Created extension to add a spinner view to the main view to simulate a loading view
var vSpinner : UIView?

extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}


// Created extension to add the possibility to run a background method {
extension DispatchQueue {

    static func background(delay: Double = 0.0, background: (() -> Void)? = nil, completion:(() -> Void)? = nil)
    {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    
}

