//
//  AIUniverseTotalTableViewCell.swift
//  ELProfileUI
//
//  Created by Oleksii Zabrodin on 09.04.2024.
//

import UIKit

class AIUniverseTotalTableViewCell: UITableViewCell {
    @IBOutlet var textTotalLabel: UILabel!
    @IBOutlet var imageTotalLabel: UILabel!
    @IBOutlet var buyAiPackButton: UIButton!
    
    public var onBuyAiPack:(()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onBuyAiPackTap(_ sender: Any) {
        onBuyAiPack?()
    }
}
