//
//  FeedRecomendedFilterDetailsCollectionViewCell.swift
//  ElloAppUI
//
//

import UIKit
import ElloAppCore

class FeedRecomendedFilterDetailsCollectionViewCell: UICollectionViewListCell {
    @IBOutlet var emojiLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        
        accessories = [.checkmark(displayed: .always, options: UICellAccessory.CheckmarkOptions(isHidden: !state.isSelected))]
        
        backgroundConfiguration?.backgroundColor = .white
    }
 
    func configure(item: any Hashable) {
        if let item = item as? Country {
            emojiLabel.text = item.flagEmoji()
            titleLabel.text = item.name
            emojiLabel.isHidden = emojiLabel.text?.isEmpty == true
        } else if let item = item as? String {
            emojiLabel.isHidden = true
            titleLabel.text = item
        }
    }
}
