//
//  SelectableUserCell.swift
//  todos-ios
//
//  Created by Daniel Mihai on 07/04/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit

class SelectableUserCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stateImage: UIImageView!
    
    var delegate: TableViewCellDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, CellConstants.margins)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backView.layer.cornerRadius = CellConstants.cornerRadius
        self.backView.layer.borderColor = CellConstants.lightGray.cgColor
        self.backView.backgroundColor = CellConstants.lightGray
        self.backView.layer.masksToBounds = true

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
    }
    
    @objc func doubleTapped() {
        delegate?.doubleTap(cell: self)
    }
    
    func getIndexPath() -> IndexPath? {
        guard let superView = self.superview as? UITableView else {
            print("Superview is not a UITableView - getIndexPath")
            return nil
        }
        
        return superView.indexPath(for: self)
    }
}
