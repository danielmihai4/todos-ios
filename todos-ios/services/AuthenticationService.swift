//
//  AuthenticationService.swift
//  todos-ios
//
//  Created by Daniel Mihai on 17/03/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol LoginDelegateProtocol: class {
    func pingSuccessful(token: String)
    func pingFailed()
    func loginSuccessful(token: String)
    func loginFailed()
}

protocol SignUpDelegateProtocol: class {
    func signUpSuccessful()
    func signUpFailed()
}

class AuthenticationService {
    weak var loginDelegate: LoginDelegateProtocol?
    weak var signUpDelegate: SignUpDelegateProtocol?
    
    let backendEndpoint = "https://stormy-fortress-66954.herokuapp.com/api/";
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var token: String? = nil
    
    func getCachedToken() -> String {
        if self.token == nil {
            self.token = loadToken()
        }
        
        return self.token!
    }
    
    func ping() {
        self.token = loadToken()
        
        if self.token == nil {
            return
        }
        
        let pingURL = URL(string: "https://stormy-fortress-66954.herokuapp.com/api/ping?token=" + token!)
        var request = URLRequest(url: pingURL!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                
                DispatchQueue.main.async {
                    self.loginDelegate?.pingFailed()
                }
                
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                if responseJSON["message"] != nil && responseJSON["message"] as! String == "pong" {
                    
                    DispatchQueue.main.async {
                        self.loginDelegate?.pingSuccessful(token: self.token!)
                    }
                }
            }
        }
        
        task.resume()            
    }
    
    func signUp(email: String, firstName: String, lastName: String, password: String) {
        var request = URLRequest(url: URL(string: backendEndpoint + "sign_up/")!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["email": email, "password": password, "first_name": firstName, "last_name": lastName])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                
                DispatchQueue.main.async {
                    self.signUpDelegate?.signUpFailed()
                }
                
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            
            if let responseJSON = responseJSON as? [String: Any] {
                if responseJSON["token"] != nil {
                    self.token = responseJSON["token"] as? String
                    DispatchQueue.main.async {
                        self.saveToken()
                        self.signUpDelegate?.signUpSuccessful()
                    }
                }
            }
        }
        
        task.resume()
    }
    
    func login(email: String, password: String){
        var request = URLRequest(url: URL(string: backendEndpoint + "login/")!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["email": email, "password": password])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                
                DispatchQueue.main.async {
                    self.loginDelegate?.loginFailed()
                }
                
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                if responseJSON["token"] != nil {
                    self.token = responseJSON["token"] as? String
                    self.saveToken()
                    
                    DispatchQueue.main.async {
                        self.loginDelegate?.loginSuccessful(token: self.token!)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    private func saveToken() {
        clearTokens()
        let authenticationTokenEntity = AuthenticationTokenEntity(context: context)
        
        authenticationTokenEntity.token = self.token
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        self.token = nil
    }
    
    private func loadToken() -> String? {
        var token: String? = nil
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AuthenticationTokenEntity")
        request.returnsObjectsAsFaults = false
        
        do {
            let databaseObject = try context.fetch(request).first
            
            if let authenticationTokenEntity = databaseObject as? AuthenticationTokenEntity {
                token = authenticationTokenEntity.token
            }
        } catch let error {
            print(error.localizedDescription)
            token = nil
        }
        
        return token
    }
    
    private func clearTokens() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AuthenticationTokenEntity")
        request.returnsObjectsAsFaults = false
        
        do {
            let databaseObjects = try context.fetch(request)
            
            for databaseObject in databaseObjects {
                if let authenticationTokenEntity = databaseObject as? AuthenticationTokenEntity {
                    context.delete(authenticationTokenEntity)
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
            
}

