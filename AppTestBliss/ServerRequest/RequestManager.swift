//
//  RequestManager.swift
//  AppTestBliss
//
//  Created by André Carvalho on 13/07/2019.
//  Copyright © 2019 André Carvalho. All rights reserved.
//

import Foundation


struct Health : Decodable
{
    
    let status: String
    
}


struct Questions : Decodable
{
    
    let id: Int
    let question: String
    let image_url: String
    let choices: [Choice]
    
    init(json: [String: Any])
    {
        id = json["id"] as? Int ?? -1
        question = json["question"] as? String ?? ""
        image_url = json["image_url"] as? String ?? ""
        choices = ((json["choices"] as? [Choice])! )
    }
    
}


struct MyQuestion : Decodable
{
    
    let id: Int
    let question: String
    let image_url: String
    let choices: [Choice]
    
    
    
}

struct Choice : Decodable
{
    
    let votes: Int
    let choice: String
    
    
    
}

class RequestManager {
    var myQuestions = [Questions]()
    
    // I changed the signiture from my original question
    func requestForQuestionData(limit: Int,offset: Int, filter: String, completionHandler: @escaping (_ result: Array<[Questions]>, _ error: String) -> Void){
        
        
        let urlComponents = NSURLComponents(string: "https://private-bbbe9-blissrecruitmentapi.apiary-mock.com/questions")!
        let limitAsString = String(limit)
        let offsetAsString = String(offset)
        urlComponents.queryItems = [
            NSURLQueryItem(name: "limit", value: limitAsString),
            NSURLQueryItem(name: "offset", value: offsetAsString),
            NSURLQueryItem(name: "filter", value: filter),
            
            ] as [URLQueryItem]
        let url = urlComponents.url
        let ErrorToPass = "OK"
        
        URLSession.shared.dataTask(with: url!) {(data, response, error) in
            guard let data = data else { return }
        
            do {
                
                
                self.myQuestions = try JSONDecoder().decode([Questions].self, from: data)
                //self.tblList.reloadData()
                //self.removeSpinner()
                
                completionHandler([self.myQuestions], ErrorToPass ) // return data & close
                
            }catch let jsonErr {
                print("Failed to seriealize json:", jsonErr)
            }
            
            }.resume()
        
        
        
    }
    
    
    func retriveQuestionID(id: Int, completionHandler: @escaping (_ result: Questions, _ error: String) -> Void){
        
        let idAsString = String(id)
        
        let urlComponents = NSURLComponents(string: "https://private-bbbe9-blissrecruitmentapi.apiary-mock.com/questions/\(idAsString)")!
       
        let url = urlComponents.url
        let ErrorToPass = "OK"
        
        URLSession.shared.dataTask(with: url!) {(data, response, error) in
            guard let data = data else { return }
            
            do {
                
                
                let questionID = try JSONDecoder().decode(Questions.self, from: data)
                
                //self.tblList.reloadData()
                //self.removeSpinner()
                
                completionHandler(questionID, ErrorToPass ) // return data & close
                
            }catch let jsonErr {
                print("Failed to seriealize json:", jsonErr)
            }
            
            }.resume()
        
        
        
    }
    
    
    func requestHealth( completionHandler: @escaping (_ result: String, _ error: String) -> Void){
        
        
        let urlComponents = NSURLComponents(string: "https://private-bbbe9-blissrecruitmentapi.apiary-mock.com/health")!
        
        urlComponents.queryItems = [
            NSURLQueryItem(name: "limit", value: String(1)),
            NSURLQueryItem(name: "offset", value: String(1)),
            
            ] as [URLQueryItem]
        let url = urlComponents.url
        let ErrorToPass = "OK"
        
        URLSession.shared.dataTask(with: url!) {(data, response, error) in
            guard let data = data else { return }
           
            do {
                
                let statusHealth  = try JSONDecoder().decode(Health.self, from: data)
                
                //self.tblList.reloadData()
                //self.removeSpinner()
                
                completionHandler(statusHealth.status, ErrorToPass ) // return data & close
                
            }catch let jsonErr {
                print("Failed to seriealize json:", jsonErr)
            }
            
            }.resume()
        
        
        
    }
   
    
    func updateQuestionData(questionId: Int, completionHandler: @escaping (_ result: Questions, _ error: String) -> Void){
        
        let questionIdAsString = String(questionId)
        
        let urlComponents = NSURLComponents(string: "https://private-bbbe9-blissrecruitmentapi.apiary-mock.com/questions/\(questionIdAsString)")!
        
        let ErrorToPass = "OK"
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
    
        request.httpBody = """
         "{\n  \"id\": 1,\n  \"image_url\": \"https://dummyimage.com/600x400/000/fff.png&text=question+1+image+(600x400)\",\n  \"thumb_url\": \"https://dummyimage.com/120x120/000/fff.png&text=question+1+image+(120x120)\",\n  \"question\": \"Favourite programming language?\",\n  \"choices\": [\n    {\n      \"choice\": \"Swift\",\n      \"votes\": 1\n    },\n    {\n      \"choice\": \"Python\",\n      \"votes\": 0\n    },\n    {\n      \"choice\": \"Objective-C\",\n      \"votes\": 0\n    },\n    {\n      \"choice\": \"Ruby\",\n      \"votes\": 0\n    }\n  ]\n}"
         """.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            do {
                
                let questionID = try JSONDecoder().decode(Questions.self, from: data)
                
                
                completionHandler(questionID, ErrorToPass ) // return data & close
                
            }catch let jsonErr {
                print("Failed to seriealize json:", jsonErr)
            }
            
            }.resume()
        
        
        
    }
    
    func shareQuestion(email: String,questionId: Int, completionHandler: @escaping (_ result: String, _ error: String) -> Void){
        let questionIdAsString = String(questionId)
        let content_url = "blissrecruitment://questions?question_id=\(questionIdAsString)"
        
        let urlComponents = NSURLComponents(string: "https://private-anon-a17253afcc-blissrecruitmentapi.apiary-mock.com/share?")!
        
        urlComponents.queryItems = [
            NSURLQueryItem(name: "destination_email", value: questionIdAsString),
            NSURLQueryItem(name: "content_url", value: content_url),
            
            ] as [URLQueryItem]
        
        let ErrorToPass = "OK"
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
             
            do {
                
                let statusHealth  = try JSONDecoder().decode(Health.self, from: data)
                
                completionHandler(statusHealth.status, ErrorToPass ) // return data close
                
            }catch let jsonErr {
                print("Failed to seriealize json:", jsonErr)
            }
            
            }.resume()
        
        
        
    }
    
    
    
    
    
    
}

