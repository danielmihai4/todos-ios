//
//  SelectableUserDataSource.swift
//  todos-ios
//
//  Created by Daniel Mihai on 14/04/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import Foundation
import UIKit

protocol SelectableUserDataSourceDelegate: class {
    func toggleSelectedState(selectableUser: SelectableUser)
}


class SelectableUserDataSource: NSObject, UITableViewDataSource, UITableViewDelegate, TableViewCellDelegate {
    
    weak var delegate: SelectableUserDataSourceDelegate?
    
    var selectableUsers = [SelectableUser]()
    
    override init() {
        super.init()
    }
    
    func setData(selectableUsers: [SelectableUser]) {
        self.selectableUsers = selectableUsers
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
    
    internal func doubleTap(cell: UITableViewCell) {
        if let selectableUserCell = cell as? SelectableUserCell {
            let selectableUser = selectableUsers[(selectableUserCell.getIndexPath()?.row)!]
            
            selectableUser.selected = !selectableUser.selected
            
            selectableUserCell.stateImage.image = getImage(selectableUser: selectableUser)
            
            delegate?.toggleSelectedState(selectableUser: selectableUser)
        }
    }
    
    private func getImage(selectableUser: SelectableUser) -> UIImage {
        return UIImage(named: (selectableUser.selected) ? "icon-checked.png" : "icon-unchecked.png")!
    }
}
