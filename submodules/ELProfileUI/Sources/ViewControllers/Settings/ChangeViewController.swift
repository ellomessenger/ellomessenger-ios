//
//  ChangeViewController.swift
//  _idx_ELProfileUI_3402FF40_ios_min11.0
//
//

import UIKit
import ELBase
import ELCommonUI

public enum ChangeOption: String, CaseIterable {
    case changeEmail
    case changePassword
}

class ChangeViewController: BaseViewController {
    
    // MARK: - Public
    
    var onTapOption: EventClosure<ChangeOption>?
    
    // MARK: - Lifecycle
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupUI()
    }
    
    override func localize() {
        titleL?.text = "change".localized(Bundle(for: SettingsViewController.self))
    }
    
    override func storyboardName() -> String {
        return "ELProfileUI"
    }
    
    // MARK: - Private
    
    @IBOutlet private weak var titleL: UILabel?
    @IBOutlet private weak var stack: UIStackView?
    
    private func setupUI() {
        stack?.subviews.forEach{$0.removeFromSuperview()}
        ChangeOption.allCases.forEach {[weak self] cased in
            let option = OptionView.Option(icon: cased.icon, title: cased.title)
            let view = OptionView(option: option, iconShape: .square(24))
            view.onSelect = { option in
                let result = ChangeOption.allCases.first(where: {$0.title == option?.title}) ?? .changeEmail
                self?.onTapOption?(result)
            }
            self?.stack?.addArrangedSubview(view)
        }
    }
}

// MARK: - Data

extension ChangeOption {
    
    var title: String {
        return self.localized(Bundle(for: SettingsViewController.self))
    }
    
    var icon: UIImage? {
        switch self {
            case .changeEmail: return UIImage(named: "change_email", in: Bundle(for: SettingsViewController.self), compatibleWith: nil)
            case .changePassword: return UIImage(named: "change_password", in: Bundle(for: SettingsViewController.self), compatibleWith: nil)
        }
    }
}
