//
//  SearchUsersViewController.swift
//  todos-ios
//
//  Created by Daniel Mihai on 06/05/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit

class SearchUsersViewController: UIViewController, UserServiceDelegate, UITableViewDataSource, UITableViewDelegate, TableViewCellDelegate {
    
    var selectableUsers = [SelectableUser]()
    var authenticationService = AuthenticationService()
    var userService = UserService()


    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userService.userServiceDelegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectableUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.SelectableUser) as! SelectableUserCell
        let selectableUser = self.selectableUsers[indexPath.row]
        
        cell.nameLabel.text = "\(selectableUser.firstName) \(selectableUser.lastName)"
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        self.userService.searchUsers(token: self.authenticationService.getCachedToken(), query: self.searchTextField.text!)
    }
    
    internal func usersLoaded(users: [SelectableUser]) {
        self.selectableUsers = users
        self.tableView.reloadData()
    }
    
    internal func doubleTap(cell: UITableViewCell) {
        if let selectableUserCell = cell as? SelectableUserCell {
            let selectableUser = selectableUsers[(selectableUserCell.getIndexPath()?.row)!]
            
            selectableUser.selected = !selectableUser.selected
            
            selectableUserCell.stateImage.image = getImage(selectableUser: selectableUser)
            
            if selectableUser.selected {
                self.userService.addFriendship(token: authenticationService.getCachedToken(), friend: selectableUser)
            } else {
                self.userService.removeFriendship(token: authenticationService.getCachedToken(), friend: selectableUser)
            }
        }
    }
    
    private func getImage(selectableUser: SelectableUser) -> UIImage {
        return UIImage(named: (selectableUser.selected) ? "icon-checked.png" : "icon-unchecked.png")!
    }

}
