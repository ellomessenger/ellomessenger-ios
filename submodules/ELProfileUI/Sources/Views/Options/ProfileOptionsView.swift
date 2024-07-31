//
//  ProfileOptionsView.swift
//  _idx_ELProfileUI_0B89BFFD_ios_min11.0
//
//

import UIKit
import ELBase

public enum ProfileOption: String {
    case chat
    case call
    case search
    case more
}

public class ProfileOptionsView: BaseView {
    
    // MARK: - Public
    
    var options: [ProfileOption] = []
    
    var onTapOption: EventClosure<ProfileOption>?
    
    // MARK: - Lifecycle
    
    public convenience init(options: [ProfileOption] = [.chat, .call, .search, .more], onTapOption: EventClosure<ProfileOption>? = nil) {
        self.init()
        self.options = options
        self.onTapOption = onTapOption
        
        setupUI()
    }
    
    // MARK: - Private
    
    @IBOutlet private weak var stackView: UIStackView?
    
    private func setupUI() {
        stackView?.subviews.forEach{$0.removeFromSuperview()}
        for option in options {
            let view = optionView(for: option)
            stackView?.addArrangedSubview(view)
        }
    }
    
    private func optionView(for option: ProfileOption) -> UIView {
        let title = option.title
        let icon = option.icon
        let view = ProfileOptionItem(icon: icon ?? UIImage(), title: title) { [weak self] in
            self?.onTapOption?(option)
        }
        return view
    }
}

private extension ProfileOption {
    
    var title: String {
        return self.localized(Bundle(for: ProfileOptionsView.self))
    }
    
    var icon: UIImage? {
        switch self {
            case .chat: return UIImage(named: "ProfileOptions/chat", in: Bundle(for: ProfileOptionsView.self), compatibleWith: nil)
            case .call: return UIImage(named: "ProfileOptions/call", in: Bundle(for: ProfileOptionsView.self), compatibleWith: nil)
            case .search: return UIImage(named: "ProfileOptions/search", in: Bundle(for: ProfileOptionsView.self), compatibleWith: nil)
            case .more: return UIImage(named: "ProfileOptions/more", in: Bundle(for: ProfileOptionsView.self), compatibleWith: nil)
        }
    }
}
