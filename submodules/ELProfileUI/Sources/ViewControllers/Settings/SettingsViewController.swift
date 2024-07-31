//
//  SettingsViewController.swift
//  _idx_ELProfileUI_FED44D4B_ios_min11.0
//
//

import UIKit
import ELBase
import ELCommonUI

public enum SettingsOption: String, CaseIterable {
    case privacy
    case changePasswordAndEmail
//    case language
    case devices
}

class SettingsViewController: BaseViewController {
    
    // MARK: - Public
        
    public var onTapOption: EventClosure<SettingsOption>?
    public var onTapDeleteAccount: VoidClosure?
    
    // MARK: - Lifecycle
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupUI()
    }
    
    override func storyboardName() -> String {
        return "ELProfileUI"
    }
    
    // MARK: - Private
    
    @IBOutlet private weak var stack: UIStackView?
    
    private func setupUI() {
        stack?.subviews.forEach{$0.removeFromSuperview()}
        SettingsOption.allCases.forEach {[weak self] cased in
            let option = OptionView.Option(icon: cased.icon, title: cased.title)
            let view = OptionView(option: option, iconShape: .square(24), showAccessory: false)
            view.onSelect = { option in
                let result = SettingsOption.allCases.first(where: {$0.title == option?.title}) ?? .privacy
                self?.onTapOption?(result)
            }
            self?.stack?.addArrangedSubview(view)
        }
    }
}

// MARK: - Actions

extension SettingsViewController {
    
    @IBAction private func deleteAccountBtnDidTap(_ sender: AnyObject?) {
        onTapDeleteAccount?()
    }
}

extension SettingsOption {
    
    var title: String {
        return self.localized(Bundle(for: SettingsViewController.self))
    }
    
    var icon: UIImage? {
        switch self {
            case .privacy: return UIImage(named: "privacy", in: Bundle(for: SettingsViewController.self), compatibleWith: nil)
            case .changePasswordAndEmail: return UIImage(named: "chng_pass_n_email", in: Bundle(for: SettingsViewController.self), compatibleWith: nil)
//            case .language: return UIImage(named: "language", in: Bundle(for: SettingsViewController.self), compatibleWith: nil)
            case .devices: return UIImage(named: "devices", in: Bundle(for: SettingsViewController.self), compatibleWith: nil)
        }
    }
}
