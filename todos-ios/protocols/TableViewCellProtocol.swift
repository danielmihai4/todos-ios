//
//  TableViewCellProtocol.swift
//  todos-ios
//
//  Created by Daniel Mihai on 06/04/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import Foundation
import UIKit

protocol TableViewCellDelegate {
    func doubleTap(cell: UITableViewCell)
}
