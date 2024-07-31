//
//  PrivacyDataSetupViewController.swift
//  _idx_ELProfileUI_139B49CA_ios_min11.0
//
//

import UIKit
import ELBase
import ELCommonUI

public struct PrivacyDataOptionObject {
    public var dataOption: PrivacyDataOption = .lastSeen
    public var setups: [PrivacyDataSelectionOption] = PrivacyDataSelectionOption.allCases
    public var selected: PrivacyDataSelectionOption = .everybody
    
    public init(dataOption: PrivacyDataOption = .lastSeen, setups: [PrivacyDataSelectionOption] = PrivacyDataSelectionOption.allCases, selected: PrivacyDataSelectionOption = .everybody) {
        self.dataOption = dataOption
        self.setups = setups
        self.selected = selected
    }
}

class PrivacyDataSetupViewController: BaseViewController {
    
    // MARK: - Public
    
    var onUpdate: EventClosure<PrivacyDataOptionObject?>?
    
    var object: PrivacyDataOptionObject? {
        didSet{
            setupOptionData()
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupOptionData()
    }
    
    override func storyboardName() -> String {
        return "ELProfileUI"
    }
    
    
    // MARK: - Private
    
    @IBOutlet private weak var titleL: UILabel?
    
    @IBOutlet private weak var headerL: UILabel?
    @IBOutlet private weak var optionsStack: UIStackView?
    @IBOutlet private weak var descriptionL: UILabel?
    
    private let bundle = Bundle(for: PrivacyDataSetupViewController.self)

    private func setupOptionData() {
        titleL?.text = object?.dataOption.localized(bundle)
        headerL?.text = object?.dataOption.header.uppercased()
        descriptionL?.text = object?.dataOption.description
        updateSelectedOption()
    }
    
    private func updateSelectedOption() {
        optionsStack?.subviews.forEach{$0.removeFromSuperview()}
        for option in object?.setups ?? [] {
            let o = OptionView.Option(title: option.localized(bundle))
            let icon = option == object?.selected ? UIImage(named: "checkmark", in: bundle, compatibleWith: nil) : nil
            let view = OptionView(option: o, showAccessory: icon != nil, accessoryIcon: icon)
            view.onSelect = { [weak self] option in
                let result = PrivacyDataSelectionOption.allCases.first(where: {$0.title == option?.title}) ?? .everybody
                self?.object?.selected = result
                
                self?.onUpdate?(self?.object)
                
                self?.updateSelectedOption()
            }
            optionsStack?.addArrangedSubview(view)
        }
    }
}

extension PrivacyDataSelectionOption {
    
    var title: String {
        return self.localized(Bundle(for: PrivacyDataSetupViewController.self))
    }
}

extension PrivacyDataOption {
    
    private static let bundle = Bundle(for: PrivacyDataSetupViewController.self)
    
    var header: String {
        switch self {
            case .lastSeen:             return Localization.lastSeenHeader.localized(PrivacyDataOption.bundle)
            case .groupsAndChannels:    return Localization.groupsAndChannelsHeader.localized(PrivacyDataOption.bundle)
            case .calls:                return Localization.callsHeader.localized(PrivacyDataOption.bundle)
            case .profilePhoto:         return Localization.profilePhotoHeader.localized(PrivacyDataOption.bundle)
            case .forwardedMessages:    return Localization.forwardMessageHeader.localized(PrivacyDataOption.bundle)
            default: return ""
        }
    }
    
    var description: String {
        switch self {
            case .lastSeen:             return Localization.lastSeenDescription.localized(PrivacyDataOption.bundle)
            case .groupsAndChannels:    return Localization.groupsAndChannelsDescription.localized(PrivacyDataOption.bundle)
            case .calls:                return Localization.callsDescription.localized(PrivacyDataOption.bundle)
            case .profilePhoto:         return Localization.profilePhotoDescription.localized(PrivacyDataOption.bundle)
            case .forwardedMessages:    return Localization.forwardMessageDescription.localized(PrivacyDataOption.bundle)
            default: return ""
        }
    }
}

private enum Localization: String {
    case lastSeenHeader
    case lastSeenDescription
    
    case groupsAndChannelsHeader
    case groupsAndChannelsDescription
    
    case callsHeader
    case callsDescription
    
    case profilePhotoHeader
    case profilePhotoDescription
    
    case forwardMessageHeader
    case forwardMessageDescription
}
