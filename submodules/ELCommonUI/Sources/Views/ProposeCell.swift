//
//  ProposeCell.swift
//  _idx_ELCommonUI_73816DED_ios_min15.4
//
//

import ELBase
import UIKit

class ProposeCell: UICollectionViewCell {
    static var identifier: String {
        String(describing: ProposeCell.self)
    }
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var proposeLabel: UILabel!
    @IBOutlet weak var priceBGView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    public func configurate(
        icon: UIImage?,
        price: String,
        propose: String? = nil,
        background: UIImage?,
        title: String,
        description: String,
        isProposeAdjustFont: Bool
    ) {
        iconImageView.image = icon
        priceLabel.font = .systemFont(ofSize:
                                            isProposeAdjustFont ? 16 : 24, weight: .semibold)
        priceLabel.text = price
        proposeLabel.text = if let propose {
            propose + " for"
        } else {
            nil
        }
        proposeLabel.font = .systemFont(ofSize:
                                            isProposeAdjustFont ? 16 : 24, weight: .semibold)
        proposeLabel.isHidden = propose == nil
        backgroundImageView.image = background
        titleLabel.text = title
        descriptionLabel.text = description
    }
}
