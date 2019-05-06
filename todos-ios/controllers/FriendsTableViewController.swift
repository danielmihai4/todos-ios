//
//  FriendsTableViewController.swift
//  todos-ios
//
//  Created by Daniel Mihai on 06/05/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit

class FriendsTableViewController: UITableViewController, FriendsServiceDelegate {
    
    var friends = [User]()
    var authenticationService = AuthenticationService()
    var userService = UserService()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .none
        self.userService.friendsServiceDelegate = self
        self.userService.loadFriends(token: authenticationService.getCachedToken())
        self.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: UIControlEvents.valueChanged)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.Friend) as! FriendViewCell
        let friend = self.friends[indexPath.row]
        
        cell.nameLabel.text = "\(friend.firstName) \(friend.lastName)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            self.displayDeletionConfirmation(friend: self.friends[indexPath.row])
        }
    }
    
    internal func friendsLoaded(friends: [User]) {
        self.friends = friends
        self.tableView.reloadData()
        
        if (self.refreshControl?.isRefreshing)! {
            self.refreshControl?.endRefreshing()
        }
    }
    
    internal func friendshipRemoved(friend: User) {
        self.friends = self.friends.filter { $0.id != friend.id}
        self.tableView.reloadData()
    }
    
    internal func friendshipRemovalFailed(friend: User) {
        //TODO: implement
    }
    
    internal func friendshipAdded(friend: User) {
        self.friends.append(friend)
        self.tableView.reloadData()
    }
    
    internal func friendshipAdditionFailed(friend: User) {
        //TODO: implement
    }
    
    private func displayDeletionConfirmation(friend: User) {
        let dialogMessage = UIAlertController(title: AlertLabels.confirmTitle, message: AlertLabels.removeFriendshipMessage, preferredStyle: .alert)
        let cancel = UIAlertAction(title: ButtonLabels.cancel, style: .cancel, handler: nil)
        let ok = UIAlertAction(title: ButtonLabels.ok, style: .default, handler: { (action) -> Void in
            self.userService.removeFriendship(token: self.authenticationService.getCachedToken(), friend: UserTranslator.translate(user: friend))
        });
        
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    @objc func refresh(_ sender:Any) {
        self.userService.loadFriends(token: authenticationService.getCachedToken())
    }
}
