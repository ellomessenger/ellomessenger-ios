//
//  AccountInfoFooter.swift
//  ELProfileUI
//
//

import ELBase
import UIKit

class AccountInfoFooter: BaseView {
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var imageView: UIImageView?
    @IBOutlet private weak var deleteButton: UIButton?
    
    private var action: VoidClosure?
    
    func config(isReadyToDelete: Bool, action: VoidClosure?) {
        
        self.action = action
        if isReadyToDelete {
            titleLabel?.text = "DeleteAccount.AccountInfo.CanDelete".localized
            titleLabel?.textColor = UIColor.greenText
            imageView?.image = UIImage(systemName: "checkmark.circle")
            imageView?.tintColor = UIColor.greenText
            deleteButton?.setTitleColor(UIColor.redText, for: .normal)
            deleteButton?.backgroundColor = UIColor.buttonLightRed
        } else {
            titleLabel?.text = "DeleteAccount.AccountInfo.CantDelete".localized
            titleLabel?.textColor = UIColor.redText
            imageView?.image = UIImage(systemName: "exclamationmark.triangle")
            imageView?.tintColor = UIColor.redText
            deleteButton?.setTitleColor(UIColor.textGray, for: .normal)
            deleteButton?.backgroundColor = UIColor.buttonDarkGrey
        }
    }
    
    @IBAction private func deleteAction() {
        action?()
    }
}
