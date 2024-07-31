//
//  ProfileOptionItem.swift
//  _idx_ELProfileUI_0B89BFFD_ios_min11.0
//
//

import UIKit
import ELBase

class ProfileOptionItem: BaseView {
    
    // MARK: - Public
    
    
    
    // MARK: - Lifecycle
    
    convenience init( icon: UIImage, title: String, onTap: VoidClosure?) {
        self.init()
        
        iconIV?.image = icon
        titleL?.text = title
        actionBtn?.addAction {
            onTap?()
        }
    }
    
    // MARK: - Private
        
    @IBOutlet private weak var iconIV: UIImageView?
    @IBOutlet private weak var titleL: UILabel?
    @IBOutlet private weak var actionBtn: UIButton?
}
