//
//  ListService.swift
//  todos-ios
//
//  Created by Daniel Mihai on 30/03/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import Foundation

protocol ListProtocolDelegate: class {
    func listsLoaded(lists: [List])
    func listsLoadFailed()
    func listCreated(list: List)
    func listCreationFailed(name: String)
    func listDeleted(list: List)
    func listDeletionFailed(list: List)
}

protocol ItemProtocolDelegate: class {
    func itemUpdated(item: Item)
    func itemDeleteFailed(item: Item)
    func itemCreated(item: Item)
    func itemCreationFailed(list: List)
    func listLoaded(list: List)
    func listLoadFailed()
}

class ListService {
    
    weak var listDelegate: ListProtocolDelegate?
    weak var itemDelegate: ItemProtocolDelegate?
    let dateFormatter = DateFormatter()
    
    let listsUrlTemplate = "https://stormy-fortress-66954.herokuapp.com/api/lists/"
    let itemsUrlTemplate = "https://stormy-fortress-66954.herokuapp.com/api/lists/items"
    
    func loadLists(token: String) {
        var request = URLRequest(url: URL(string: listsUrlTemplate + "index.json?token=" + token)!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                
                DispatchQueue.main.async {
                    self.listDelegate?.listsLoadFailed()
                }
                
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            
            if let responseJSON = responseJSON as? [[String: Any]] {
                var lists = [List]()
                for listJSON in responseJSON {
                    var items = [Item]()
                    if let itemsJSON = listJSON["items"] as? [[String: Any]] {
                        for itemJSON in itemsJSON {
                            items.append(self.createItem(json: itemJSON))
                        }
                    }
                    
                    lists.append(self.createList(json: listJSON, items: items))
                }
                
                DispatchQueue.main.async {
                    self.listDelegate?.listsLoaded(lists: lists)
                }
            }
        }
        
        task.resume()
    }
    
    func loadList(token: String, list: List) {
        var request = URLRequest(url: URL(string: listsUrlTemplate + "show.json?token=\(token)&id=\(list.id)")!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                
                DispatchQueue.main.async {
                    self.itemDelegate?.listLoadFailed()
                }
                
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            
            if let responseJSON = responseJSON as? [String: Any] {
                var items = [Item]()
                if let itemsJSON = responseJSON["items"] as? [[String: Any]] {
                    for itemJSON in itemsJSON {
                        items.append(self.createItem(json: itemJSON))
                    }
                }
                
                DispatchQueue.main.async {
                    self.itemDelegate?.listLoaded(list: self.createList(json: responseJSON, items: items))
                }
            }
        }
        
        task.resume()
    }
    
    func updateItem(token: String, list: List, item: Item) {
        let state = item.isDone ? "1" : "0"
        
        var request = URLRequest(url: URL(string: itemsUrlTemplate + "/toggle_state.json")!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["token": token, "list_id": "\(list.id)", "item_id": "\(item.id)", "state": state])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            
            if let responseJSON = responseJSON as? [String: Any] {
                if responseJSON["id"] != nil {
                    let returnedId = responseJSON["id"] as! Int
                    if returnedId == item.id {
                        DispatchQueue.main.async {
                            self.itemDelegate?.itemUpdated(item: self.createItem(json: responseJSON))
                        }
                    }
                }
            }
        }
        
        task.resume()
    }
    
    func deleteItem(token: String, list: List, item: Item) {
        let json = ["token": token, "list_id": "\(list.id)", "item_id": "\(item.id)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        var request = URLRequest(url: URL(string: itemsUrlTemplate + "/delete.json")!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                
                DispatchQueue.main.async {
                    self.itemDelegate?.itemDeleteFailed(item: item)
                }
            
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            
            if let responseJSON = responseJSON as? [String: Any] {
                if responseJSON["id"] != nil {
                    let returnedId = responseJSON["id"] as! Int
                    if returnedId == list.id {
                        NSLog("Item '\(item.name)' from list '\(list.name)' deleted.")
                    }
                }
            }
        }
        task.resume()
    }
    
    func createItem(token: String, list: List, itemName: String, dueDate: String) {
        var request = URLRequest(url: URL(string: itemsUrlTemplate + "/create.json")!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["token": token, "list_id": "\(list.id)", "name": itemName, "due_date": dueDate])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                
                DispatchQueue.main.async {
                    self.itemDelegate?.itemCreationFailed(list: list)
                }
                
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            
            if let responseJSON = responseJSON as? [String: Any] {
                if let _ = responseJSON["error_msg"] as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.itemDelegate?.itemCreationFailed(list: list)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.itemDelegate?.itemCreated(item: self.createItem(json: responseJSON))
                    }
                }
            }
        }
        
        task.resume()
    }
    
    func createList(token: String, name: String, userIds: [Int]) {
        var request = URLRequest(url: URL(string: listsUrlTemplate + "create.json")!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["token": token, "name": name, "user_ids": userIds])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                
                DispatchQueue.main.async {
                    self.listDelegate?.listCreationFailed(name: name)
                }
                
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                var items = [Item]()
                if let itemsJSON = responseJSON["items"] as? [[String: Any]] {
                    for itemJSON in itemsJSON {
                        items.append(self.createItem(json: itemJSON))
                    }
                }
                
                DispatchQueue.main.async {
                    self.listDelegate?.listCreated(list: self.createList(json: responseJSON, items: items))
                }
            }
        }
        
        task.resume()
    }
    
    func deleteList(token: String, list: List) {
        var request = URLRequest(url: URL(string: itemsUrlTemplate + "/delete.json")!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["token": token, "id": "\(list.id)"])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                
                DispatchQueue.main.async {
                    self.listDelegate?.listDeletionFailed(list: list)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                self.listDelegate?.listDeleted(list: list)
            }
        }
        task.resume()
    }
    
    private func parseDate(dateAsString: String) -> Date? {
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter.date(from: dateAsString)
    }
    
    private func formatDate(date: Date) -> String {
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter.string(from: date)
    }
    
    private func createItem(json: [String: Any]) -> Item {
        var completedBy: User? = nil
        if let completedByJSON = json["completed_by"] as? [String: Any] {
            completedBy = createCompletedByUser(json: completedByJSON)
        }
        
        return Item(
            id: (json["id"] as? Int)!,
            name: json["name"] as! String,
            dueDate: self.parseDate(dateAsString: json["due_date"] as! String),
            listId: (json["list_id"] as? Int)!,
            isDone: (json["is_done"] as? Bool)!,
            completedBy: completedBy,
            info: json["info"] as! String)
    }
    
    private func createCompletedByUser(json: [String: Any]) -> User {
        return User(
            id: (json["id"] as? Int)!,
            email: json["email"] as! String,
            firstName: json["first_name"] as! String,
            lastName: json["last_name"] as! String)
    }
    
    private func createList(json: [String: Any], items: [Item]) -> List {
        return List(
            id: (json["id"] as? Int)!,
            name: json["name"] as! String,
            createdAt: json["created_at"] as! String,
            items: items)
    }
}
