//
//  AIUniverseTableViewCell.swift
//  ELProfileUI
//
//  Created by Oleksii Zabrodin on 05.04.2024.
//

import UIKit

class AIUniverseTableViewCell: UITableViewCell {

    @IBOutlet var icon: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var subtitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
