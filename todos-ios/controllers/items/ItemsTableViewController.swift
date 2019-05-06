//
//  ItemViewController.swift
//  todos-ios
//
//  Created by Daniel Mihai on 06/04/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit

class ItemsTableViewController: UITableViewController, TableViewCellDelegate, ItemProtocolDelegate {
    
    var list: List? = nil
    let dateFormatter = DateFormatter()
    
    var authenticationService = AuthenticationService()
    var listService = ListService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.title = list?.name
        
        self.listService.itemDelegate = self
        self.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: UIControlEvents.valueChanged)        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (list?.items.count)!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.Item , for: indexPath) as! ItemViewCell
        let item = self.list?.items[indexPath.row]
        
        cell.nameLabel.text = item?.name
        cell.stateImage.image = getStateImage(item: item)
        cell.dueDateLabel.text = formatDate(date: (item?.dueDate)!)
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let item = self.list?.items[indexPath.row]
            
            self.list?.items.remove(at: indexPath.row)
            self.tableView.reloadData()
            
            listService.deleteItem(token: authenticationService.getCachedToken(), list: list!, item: item!)
        }
    }
    
    internal func doubleTap(cell: UITableViewCell) {
        if let itemCell = cell as? ItemViewCell {
            let item = list?.items[(itemCell.getIndexPath()?.row)!]
            
            item?.isDone = !(item?.isDone)!
            
            itemCell.stateImage.image = getStateImage(item: item)
            
            listService.updateItem(token: authenticationService.getCachedToken(), list: list!, item: item!)
        }
    }
    
    @IBAction func createItem(segue: UIStoryboardSegue) {
        if let source = segue.source as? NewItemViewController {
            let name = source.nameTextField.text!
            let dueDate = source.dueDateTextField.text!
            
            self.listService.createItem(token: authenticationService.getCachedToken(), list: self.list!, itemName: name, dueDate: dueDate)
        }
    }
    
    internal func itemUpdated(item: Item) {
        //TODO: implement
    }
    internal func itemDeleteFailed(item: Item) {
        //TODO: implement
    }
    
    internal func itemCreated(item: Item) {
        self.list?.items.append(item)
        self.tableView.reloadData()
    }
    
    internal func itemCreationFailed(list: List) {
        //TODO: implement
    }
    
    internal func listLoaded(list: List) {
        self.list = list
        self.tableView.reloadData()
        
        if (self.refreshControl?.isRefreshing)! {
            self.refreshControl?.endRefreshing()
        }
    }
    
    internal func listLoadFailed() {
        //TODO: implement
    }
    
    internal func listsLoaded(lists: [List]) {
        //not needed
    }
    
    internal func listsLoadFailed() {
        //not needed
    }
    
    internal func listCreated(list: List) {
        //not needed
    }
    
    internal func listCreationFailed(name: String) {
        //not needed
    }
    
    internal func listDeleted(list: List) {
        //not needed
    }
    
    internal func listDeletionFailed(list: List) {
        //not needed
    }
    
    private func formatDate(date: Date) -> String {
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        return dateFormatter.string(from: date)
    }
    
    private func getStateImage(item: Item?) -> UIImage? {
        return UIImage(named: (item?.isDone)! ? "icon-checked.png" : "icon-unchecked.png")
    }
    
    @objc func refresh(_ sender:Any) {
        self.listService.loadList(token: authenticationService.getCachedToken(), list: self.list!)
    }
}
