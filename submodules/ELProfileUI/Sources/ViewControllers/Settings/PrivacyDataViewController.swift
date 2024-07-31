//
//  PrivacyDataViewController.swift
//  _idx_ELProfileUI_139B49CA_ios_min11.0
//
//

import UIKit
import ELBase
import ELCommonUI


public struct PrivacyDataObject {
    public var blockedUsers: Int = 0
    public var lastSeen: PrivacyDataSelectionOption = .everybody
    public var groupsAndChannels: PrivacyDataSelectionOption = .everybody
    public var calls: PrivacyDataSelectionOption = .everybody
    public var profilePhoto: PrivacyDataSelectionOption = .everybody
    public var forwardedMessages: PrivacyDataSelectionOption = .everybody
    
    public init(blockedUsers: Int = 0,
         lastSeen: PrivacyDataSelectionOption = .everybody,
         groupsAndChannels: PrivacyDataSelectionOption = .everybody,
         calls: PrivacyDataSelectionOption = .everybody,
         profilePhoto: PrivacyDataSelectionOption = .everybody,
         forwardedMessages: PrivacyDataSelectionOption = .everybody) {
        self.blockedUsers = blockedUsers
        self.lastSeen = lastSeen
        self.groupsAndChannels = groupsAndChannels
        self.calls = calls
        self.profilePhoto = profilePhoto
        self.forwardedMessages = forwardedMessages
    }
}

public enum PrivacyDataOption: String, CaseIterable {
    case blockedUsers
    case privacy
    case lastSeen
    case groupsAndChannels
    case calls
    case profilePhoto
    case forwardedMessages
}

public enum PrivacyDataSelectionOption: String, CaseIterable {
    case everybody
    case myContacts
    case nobody
}

class PrivacyDataViewController: BaseViewController {
    
    // MARK: - Public
        
    var privacyObject: PrivacyDataObject?
    {didSet{
        setupUI()
    }}

    var onTapOption: EventClosure<PrivacyDataOption>?
    var onRequestUpdate: ReturnClosure<PrivacyDataObject?>?
    
    // MARK: - Lifecycle
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let result = onRequestUpdate?() {
            privacyObject = result
        } else {
            setupUI()
        }
    }
    
    override func localize() {
        titleL?.text = Localization.privacy.localized(bundle)
    }
    
    override func storyboardName() -> String {
        return "ELProfileUI"
    }
    
    // MARK: - Private
    
    @IBOutlet private weak var titleL: UILabel?
    @IBOutlet private weak var stack: UIStackView?
    
    private let bundle = Bundle(for: PrivacyDataViewController.self)
        
    private func setupUI() {
        stack?.subviews.forEach{$0.removeFromSuperview()}
        for option in PrivacyDataOption.allCases {
            let type = option.type
            let icon = option.icon
            let isHeader = type == .header
            let o = OptionView.Option(icon: icon, title: isHeader ? option.localized(bundle).uppercased() : option.localized(bundle), isHeader: isHeader)
            let titleFontColor = isHeader ? UIColor(hexString: "070708") ?? .black : .black
            let backgroundColor: UIColor = isHeader ? .clear : .white
            
            var additionalInfo = ""
            switch option {
                case .blockedUsers: additionalInfo = "\(privacyObject?.blockedUsers ?? 0) \(Localization.users.localized(bundle))"
                case .lastSeen: additionalInfo = "\((privacyObject?.lastSeen ?? .everybody).localized(bundle) )"
                case .groupsAndChannels: additionalInfo = "\((privacyObject?.groupsAndChannels ?? .everybody).localized(bundle) )"
                case .calls: additionalInfo = "\((privacyObject?.calls ?? .everybody).localized(bundle) )"
                case .profilePhoto: additionalInfo = "\((privacyObject?.profilePhoto ?? .everybody).localized(bundle) )"
                case .forwardedMessages: additionalInfo = "\((privacyObject?.forwardedMessages ?? .everybody).localized(bundle) )"
                default: break
            }
            
            var showSeparator = true
            switch option {
                case .privacy, .blockedUsers, .forwardedMessages: showSeparator = false
                default: break
            }
                        
            let view = OptionView(option: o, iconShape: .square(24), showAccessory: type == .option, additional: additionalInfo, titleColor: titleFontColor, titleFont: .systemFont(ofSize: isHeader ? 12 : 15, weight: .regular), showSeparator: showSeparator)
            view.backgroundColor = backgroundColor
            view.onSelect = { [weak self] option in
                let result = PrivacyDataOption.allCases.first(where: {$0.title == option?.title}) ?? .privacy
                self?.onTapOption?(result)
            }
            switch option {
                case .blockedUsers:
                    view.cornerRadius = 15
                case .lastSeen:
                    view.roundTopLeft = true
                    view.roundTopRight = true
                    view.roundBottomLeft = false
                    view.roundBottomRight = false
                    view.cornerRadius = 15
                case .forwardedMessages:
                    view.roundTopLeft = false
                    view.roundTopRight = false
                    view.roundBottomLeft = true
                    view.roundBottomRight = true
                    view.cornerRadius = 15
                default: break
            }
            stack?.addArrangedSubview(view)
            if isHeader {
                stack?.setCustomSpacing(8, after: view)
            }
        }
    }
    
}

// MARK: - Data

extension PrivacyDataViewController {
    
    
    
    enum OptionType {
        case option
        case header
    }
}

private extension PrivacyDataOption {
    var type: PrivacyDataViewController.OptionType {
        switch self {
            case .privacy: return .header
            default: return .option
        }
    }
    
    var icon: UIImage? {
        switch self {
            case .blockedUsers: return UIImage(named: "block", in: Bundle(for: PrivacyDataViewController.self), compatibleWith: nil)
            default: return nil
        }
    }
    var title: String {
        return self.localized(Bundle(for: PrivacyDataViewController.self))
    }
}

private enum Localization: String {
    case privacy
    case users
        
    case everybody
    case myContacts
    case nobody
}
