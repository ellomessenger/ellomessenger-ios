//
//  WalletTopUpCollectionViewCell.swift
//  _idx_ELProfileUI_7F7B2F0B_ios_min14.0
//
//

import UIKit
import ElloAppApi

class WalletTopUpCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var label: UILabel!
    
    func configure(item: TopUpMethodModel) {
        label.text = item.title.localized
        imageView.image = UIImage(named: item.icon, in: Bundle(for: WalletTopUpCollectionViewCell.self), with: nil)
    }
}
