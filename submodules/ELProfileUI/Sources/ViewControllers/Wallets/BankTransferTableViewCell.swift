//
//  BankTransferTableViewCell.swift
//  ELProfileUI
//
//  Created by Oleksii Zabrodin on 18.03.2024.
//

import UIKit
import ELBase

class BankTransferTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var selectButton: UIButton!
    @IBOutlet var editButton: UIButton!
    
    public var onEdit: VoidClosure?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        selectButton.isSelected = selected
    }

    @IBAction func onSelectButtonTap(_ sender: Any) {
        
    }
    
    @IBAction func onEditButtonTap(_ sender: Any) {
        onEdit?()
    }
    
}
