//
//  EarningsViewController.swift
//  _idx_ELProfileUI_5CF1157F_ios_min11.0
//
//

import UIKit
import ELBase
import ELCommonUI

public enum EarningOption: String, CaseIterable {
    case subscriptionChannels
    case totalBalance
    case transferOut
    case paymentOptions
}

class EarningsViewController: BaseViewController {
    
    // MARK: - Public
    
    var onTapOption: EventClosure<EarningOption>?
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleL?.text = Localization.earnings.localized(Bundle(for: Self.self))
        setupUI()
    }
    
    override func storyboardName() -> String {
        return "ELProfileUI"
    }
    
    // MARK: - Private
    
    @IBOutlet private weak var titleL: UILabel?
    @IBOutlet private weak var stack: UIStackView?
    
    private func setupUI() {
        stack?.subviews.forEach{$0.removeFromSuperview()}
        EarningOption.allCases.forEach {[weak self] cased in
            let option = OptionView.Option(icon: cased.icon, title: cased.title)
            let view = OptionView(option: option, iconShape: .square(24), showAccessory: false)
            view.onSelect = { option in
                let result = EarningOption.allCases.first(where: {$0.title == option?.title}) ?? .subscriptionChannels
                self?.onTapOption?(result)
            }
            self?.stack?.addArrangedSubview(view)
        }
    }
}

extension EarningOption {
    var title: String {
        return self.localized(Bundle(for: EarningsViewController.self))
    }
    
    var icon: UIImage? {
        return UIImage(named: self.rawValue, in: Bundle(for: EarningsViewController.self), compatibleWith: nil)
    }
}

private enum Localization: String {
    case earnings
}
