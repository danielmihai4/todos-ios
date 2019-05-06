//
//  ListViewCell.swift
//  todos-ios
//
//  Created by Daniel Mihai on 30/03/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit

class ListViewCell: UITableViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var todosCountLabel: UILabel!
    @IBOutlet weak var doneCountLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, CellConstants.margins)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backView.layer.cornerRadius = CellConstants.cornerRadius
        self.backView.layer.borderColor = CellConstants.lightGray.cgColor
        self.backView.backgroundColor = CellConstants.lightGray
        self.backView.layer.masksToBounds = true
    }

}
