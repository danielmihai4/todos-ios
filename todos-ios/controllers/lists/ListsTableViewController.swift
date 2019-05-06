//
//  ListsTableViewController.swift
//  todos-ios
//
//  Created by Daniel Mihai on 30/03/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit

class ListsTableViewController: UITableViewController, ListProtocolDelegate {
    
    var token: String = ""
    var listService = ListService()
    var authenticationService = AuthenticationService()
    var lists = [List]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .none
        
        self.listService.listDelegate = self
        self.listService.loadLists(token: authenticationService.getCachedToken())
        self.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: UIControlEvents.valueChanged)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            addConfirmListDeletionAlert(list: self.lists[indexPath.row])
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.List, for: indexPath) as! ListViewCell
        let list = lists[indexPath.row]
        
        cell.nameLabel.text = list.name
        cell.todosCountLabel.text =  "\(list.todosCount()) to do."
        cell.doneCountLabel.text = "\(list.doneCount()) done."
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == Segues.ShowItemsView {
                if let itemsViewController = segue.destination as? ItemsTableViewController {
                    if let indexPath = tableView.indexPathForSelectedRow {
                        itemsViewController.list = lists[indexPath.row]                        
                    }
                }
            }
        }
    }
    
    @IBAction func createList(segue: UIStoryboardSegue) {
        if let source = segue.source as? NewListViewController {
            let listName = source.nameTextField.text!
            let selectedUserIds = getSelectedUsers(users: source.friends)
            
            self.listService.createList(token: authenticationService.getCachedToken(), name: listName, userIds: selectedUserIds)
        }
    }

    internal func listsLoaded(lists: [List]) {
        self.lists = lists
        self.tableView.reloadData()
        
        if (self.refreshControl?.isRefreshing)! {
            self.refreshControl?.endRefreshing()
        }
    }
    
    internal func listsLoadFailed() {
        //TODO: implement
    }
    
    internal func listCreated(list: List) {
        self.lists.append(list)
        self.tableView.reloadData()
    }
    
    internal func listCreationFailed(name: String) {
        addListCreationFailedAlert(name: name)
    }
    
    internal func listDeleted(list: List) {
        self.lists = self.lists.filter { $0.id != list.id }
        self.tableView.reloadData()
    }
    
    internal func listDeletionFailed(list: List) {
        addListDeletionFailedAlert(name: list.name)
    }
    
    private func getSelectedUsers(users: [SelectableUser]) -> [Int] {
        var selectedUserIds = [Int]()
        
        for user in users {
            if user.selected {
                selectedUserIds.append(user.id)
            }
        }
        
        return selectedUserIds
    }
    
    private func addListCreationFailedAlert(name: String) {
        addListActionFailedAlert(name: name, action: "create")
    }
    
    private func addListDeletionFailedAlert(name: String) {
        addListActionFailedAlert(name: name, action: "delete")
    }
    
    private func addListActionFailedAlert(name: String, action: String) {
        let alertController = UIAlertController(title: "Can't \(action) list \(name).", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: ButtonLabels.ok, style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alertController, animated: false, completion: nil)
    }
    
    private func addConfirmListDeletionAlert(list: List) {
        let dialogMessage = UIAlertController(title: AlertLabels.confirmTitle, message: AlertLabels.deleteMessage, preferredStyle: .alert)
        let cancel = UIAlertAction(title: ButtonLabels.cancel, style: .cancel, handler: nil)
        let ok = UIAlertAction(title: ButtonLabels.ok, style: .default, handler: { (action) -> Void in
            self.listService.deleteList(token: self.authenticationService.getCachedToken(), list: list)
        });
        
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    @objc func refresh(_ sender:Any) {
        self.listService.loadLists(token: authenticationService.getCachedToken())
    }
}
