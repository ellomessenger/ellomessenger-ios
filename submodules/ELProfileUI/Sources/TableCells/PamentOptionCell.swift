//
//  PamentOptionCell.swift
//  _idx_ELProfileUI_BBFAEC0E_ios_min11.0
//
//  Created by Damir Aushenov on 18/2/23.
//

import UIKit
import ELBase
import ELCommonUI
import ELLanguageUI
class PamentOptionCell: UITableViewCell {
    
    @IBOutlet private weak var checkbox: UIImageView?
    @IBOutlet private weak var icon: UIImageView?
    @IBOutlet private weak var name: UILabel?
    @IBOutlet private weak var containerIcon: UIView?
   
    var payment: PaymentModel?
    { didSet{ updateData() }}
    
    private let radioBtnOnImg = UIImage(named: "radio-on", in: Bundle(for: LanguagesViewController.self), compatibleWith: nil)
    private let radioBtnOffImg = UIImage(named: "radio-off", in: Bundle(for: LanguagesViewController.self), compatibleWith: nil)
    
    
    func updateData() {
        name?.text = payment?.title
        icon?.image = UIImage(named: payment?.icon ?? "")
        containerIcon?.layer.borderWidth = 1
        containerIcon?.layer.cornerRadius = 6
        containerIcon?.layer.borderColor = UIColor(red: 0.851, green: 0.851, blue: 0.851, alpha: 1).cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            checkbox?.image = radioBtnOnImg
        } else {
            checkbox?.image = radioBtnOffImg
        }
    }
}
    
