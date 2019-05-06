//
//  NewListViewController.swift
//  todos-ios
//
//  Created by Daniel Mihai on 07/04/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit

class NewListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TableViewCellDelegate, FriendsServiceDelegate {
    
    var friends = [SelectableUser]()
    var userService = UserService()
    var authenticationService = AuthenticationService()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var friendsTableView: UITableView!
    
    @IBAction func saveList(_ sender: Any) {
        var canSave = true
        
        if let listName = nameTextField.text {
            if listName.isEmpty {
                canSave = false
                
                addAlert(title: AlertLabels.nameTitle, message: AlertLabels.nameMessage)
            }
        }
        
        if canSave {
            performSegue(withIdentifier: Segues.CreateList, sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setDelegates()
        
        self.friendsTableView.separatorStyle = .none
        self.userService.loadFriends(token: authenticationService.getCachedToken())
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.SelectableFriend, for: indexPath) as! SelectableFriendCell
        let friend = self.friends[indexPath.row]
        
        cell.nameLabel.text = friend.firstName + " " + friend.lastName
        cell.stateImage.image = getStateImage(friend: friend)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
  
    internal func doubleTap(cell: UITableViewCell) {
        if let selectableFriendCell = cell as? SelectableFriendCell {
            let indexPath = selectableFriendCell.getIndexPath()
            let friend = friends[(indexPath?.row)!]
            
            friend.selected = !friend.selected
            selectableFriendCell.stateImage.image = getStateImage(friend: friend)
        }
    }
    
    internal func friendsLoaded(friends: [User]) {
        for friend in friends {
            self.friends.append(UserTranslator.translate(user: friend))
        }
        self.friendsTableView.reloadData()
    }
    
    internal func friendshipRemoved(friend: User) {
        //not needed
    }
    
    internal func friendshipRemovalFailed(friend: User) {
        //not needed
    }
    
    internal func friendshipAdded(friend: User) {
        //not needed
    }
    
    internal func friendshipAdditionFailed(friend: User) {
        //not needed
    }
    
    private func getStateImage(friend: SelectableUser) -> UIImage {
        return UIImage(named: friend.selected ? "icon-checked.png" : "icon-unchecked.png")!
    }
    
    private func addAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: ButtonLabels.ok, style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alertController, animated: false, completion: nil)
    }
    
    private func setDelegates() {
        self.userService.friendsServiceDelegate = self
        self.friendsTableView.delegate = self
        self.friendsTableView.dataSource = self
    }
}
