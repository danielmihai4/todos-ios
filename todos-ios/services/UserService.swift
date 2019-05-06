//
//  UserService.swift
//  todos-ios
//
//  Created by Daniel Mihai on 07/04/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import Foundation

protocol UserServiceDelegate: class {
    func usersLoaded(users: [SelectableUser])
}

protocol FriendsServiceDelegate: class {
    func friendsLoaded(friends: [User])
    func friendshipRemoved(friend: User)
    func friendshipRemovalFailed(friend: User)
    func friendshipAdded(friend: User)
    func friendshipAdditionFailed(friend: User)
}

class UserService {
    
    weak var userServiceDelegate: UserServiceDelegate?
    weak var friendsServiceDelegate: FriendsServiceDelegate?
    
    let usersTemplateURL = "https://stormy-fortress-66954.herokuapp.com/api/users/"
    
    func searchUsers(token: String, query: String) {
        var request = URLRequest(url: URL(string: usersTemplateURL + "search_users.json")!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["token": token, "query": query])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [[String: Any]] {
                var users = [SelectableUser]()
                for userJSON in responseJSON {
                    users.append(self.createSelectableUser(json: userJSON))
                }
                
                DispatchQueue.main.async {
                    self.userServiceDelegate?.usersLoaded(users: users)
                }
            }
        }
        
        task.resume()
    }
    
    func loadFriends(token: String) {
        var request = URLRequest(url: URL(string: usersTemplateURL + "friends.json?token=" + token)!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            
            if let responseJSON = responseJSON as? [[String: Any]] {
                var friends = [User]()
                for friendJSON in responseJSON {
                    friends.append(self.createUser(json: friendJSON))
                }
                
                DispatchQueue.main.async {
                    self.friendsServiceDelegate?.friendsLoaded(friends: friends)
                }
            }
        }
        
        task.resume()
    }
    
    func addFriendship(token: String, friend: User) {
        var request = URLRequest(url: URL(string: usersTemplateURL + "add_friendship.json")!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["token": token, "user_id": friend.id])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                
                DispatchQueue.main.async {
                    self.friendsServiceDelegate?.friendshipAdditionFailed(friend: friend)
                }
                
                return
            }

            DispatchQueue.main.async {
                self.friendsServiceDelegate?.friendshipAdded(friend: friend)
            }
        }
        
        task.resume()
    }
    
    func removeFriendship(token: String, friend: User) {
        var request = URLRequest(url: URL(string: usersTemplateURL + "remove_friendship.json")!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["token": token, "user_id": "\(friend.id)"])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                
                self.friendsServiceDelegate?.friendshipRemovalFailed(friend: friend)
                
                return
            }
            
            DispatchQueue.main.async {
                self.friendsServiceDelegate?.friendshipRemoved(friend: friend)
            }
        }
        
        task.resume()
    }
    
    private func createSelectableUser(json: [String: Any]) -> SelectableUser {
        return SelectableUser(
            id: (json["id"] as? Int)!,
            email: json["email"] as! String,
            firstName: json["first_name"] as! String,
            lastName: json["last_name"] as! String,
            selected: false)
    }
    
    private func createUser(json: [String: Any]) -> User {
        return User(
            id: (json["id"] as? Int)!,
            email: json["email"] as! String,
            firstName: json["first_name"] as! String,
            lastName: json["last_name"] as! String)
    }
    
}
