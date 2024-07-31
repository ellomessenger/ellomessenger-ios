//
//  TransactionDetailsExpandableCollectionViewCell.swift
//  _idx_ELProfileUI_F69049E1_ios_min14.0
//
//

import UIKit

class TransactionDetailsExpandableCollectionViewCell: UICollectionViewCell, UICollectionViewCellDiffable {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var expandStateImageView: UIImageView!
    
    private var isExpanded = false
    
    func configure(item: AnyHashable) {
        guard let item = item as? TransactionDetailsExpandableItem else { return }
        isExpanded = item.isExpanded
        
        imageView.image = UIImage(
            named: item.iconName,
            in: Bundle(for: Self.self),
            with: nil
        )
        titleLabel.text = item.title
        descriptionLabel.text = item.value.first
        if stackView.arrangedSubviews.count <= 1 {
            item.value.enumerated().forEach { index, string in
                
                guard index > 0 else { return }
                
                let label = UILabel()
                label.text = string
                label.font = descriptionLabel.font
                label.textColor = descriptionLabel.textColor
                stackView.addArrangedSubview(label)
            }
        }
        
        updateExpandStateImageView()
        updateStackView()
    }
    
    private func updateExpandStateImageView() {
        let imageName = isExpanded ? "Wallet/arrow-up" : "Wallet/arrow-down"
        expandStateImageView.image = UIImage(
            named: imageName,
            in: Bundle(for: Self.self),
            with: nil
        )
    }
    
    private func updateStackView() {
        stackView.arrangedSubviews.enumerated().forEach { index, view in
            guard index > 0 else { return }
            
            view.isHidden = !isExpanded
        }
    }
}
