//
//  ProfileItemSwitchView.swift
//  _idx_ELProfileUI_0B89BFFD_ios_min11.0
//
//

import UIKit
import ELBase

class ProfileItemSwitchView: BaseView {
 
    // MARK: - Public
    
    var title: String = ""
    { didSet{ setupData() }}
    var value: Bool = false
    { didSet{ setupData() }}

    var onChange: EventClosure<Bool>?
    
    convenience init( title: String, value: Bool, onChange: @escaping EventClosure<Bool>) {
        self.init()
        self.title = title
        self.value = value
        self.onChange = onChange
        
        setupData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupData()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if let _ = newSuperview {
            setupData()
        }
    }
    
    // MARK: - Private
    
    @IBOutlet private weak var titleL: UILabel?
    @IBOutlet private weak var stateSW: UISwitch?
    
    private func setupData() {
        titleL?.text = title
        stateSW?.isOn = value
    }
}

// MARK: - Actions

extension ProfileItemSwitchView {
    
    @IBAction private func switchDidToggle(_ sender: UISwitch) {
        onChange?(sender.isOn)
    }
}
