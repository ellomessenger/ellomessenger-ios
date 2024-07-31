//
//  ProfileItemQRView.swift
//  _idx_ELProfileUI_249CAF1E_ios_min11.0
//
//

import UIKit
import ELBase

class ProfileItemQRView: BaseView {
    
    // MARK: - Public
    
    var link: String = "" {didSet{
        if nil == name {
            linkL?.text = link
        }
    }}
    
    var name: String? = nil {didSet{
        linkL?.text = name
    }}
    
    var onTap: EventClosure<String>?
    var onCopy: EventClosure<String>?
    var onShare: EventClosure<String>?
    
    convenience init(link: String = "", onTap: EventClosure<String>? = nil, onCopy: EventClosure<String>? = nil, onShare: EventClosure<String>? = nil) {
        self.init()
        self.link = link
        self.onTap = onTap
        self.onCopy = onCopy
        self.onShare = onShare
        
        linkL?.text = link
        
    }
    
    // MARK: - Lifecycle
    
    override func localize() {
        headerL?.text = Localization.inviteLink.localized(Bundle(for: ProfileItemQRView.self))
        copyTitleL?.text = Localization.copyLink.localized(Bundle(for: ProfileItemQRView.self))
        shareTitleL?.text = Localization.share.localized(Bundle(for: ProfileItemQRView.self))
    }
    
    // MARK: - Private
    
    @IBOutlet private weak var headerL: UILabel?
    @IBOutlet private weak var linkL: UILabel?
    @IBOutlet private weak var copyTitleL: UILabel?
    @IBOutlet private weak var shareTitleL: UILabel?
    @IBOutlet private weak var buttonsView: UIStackView?
    @IBOutlet private weak var separatorView: UIView?
}

// MARK: - Actions

extension ProfileItemQRView {

    @IBAction private func linkAreaDidTap(_ sender: AnyObject?) {
        onTap?(link)
    }
    
    @IBAction private func copyBtnDidTap(_ sender: AnyObject?) {
        onCopy?(link)
    }
    
    @IBAction private func shareBtnDidTap(_ sender: AnyObject?) {
        onShare?(link)
    }
    
    public func resizeButtons(isHidden:Bool) {
        guard let buttonsView, let separatorView else { return }
        buttonsView.isHidden = isHidden
        separatorView.isHidden = isHidden
        var rect = self.bounds
        rect.size.height = isHidden ? 66 : 123
        self.bounds = rect
    }
}

private enum Localization: String {
    case inviteLink
    case copyLink
    case share
}
