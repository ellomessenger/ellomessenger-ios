//
//  ProfileViewController.swift
//  _idx_ELProfileUI_B5B6554B_ios_min11.0
//
//

import UIKit
import Display
import ELBase
import ELCommonUI

public struct ProfileInfo {
    public var avatar: UIImage?
    public var username: String = ""
    public var name: String = ""
    public var bio: String = ""
    
    public  init(avatar: UIImage? = nil, username: String, name: String, bio: String) {
        self.avatar = avatar
        self.username = username
        self.name = name
        self.bio = bio
    }
}

class ProfileViewController: UIViewController {
    
    // MARK: - Public
    
//    public static var controller: ProfileViewController? { //WelcomeController? {
//        let storyboard = UIStoryboard(name: "ELProfileUI", bundle: Bundle(for: ProfileViewController.self))
//        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController")
//        return vc as? ProfileViewController
//    }
    
    var profile: ProfileInfo?{
        didSet{ setupProfileInfo() }
    }
    
    var onTapBack: VoidClosure?
    var onTapEdit: VoidClosure?
    var onTapChangePhoto: VoidClosure?
    var optionDidSelect: EventClosure<Option>?
    var onTapSupport: VoidClosure?
    var onTapLogout: VoidClosure?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // overrideUserInterfaceStyle is available with iOS 13
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            overrideUserInterfaceStyle = .light
        }
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupOptions()
    }
    
    // MARK: - Private
    
    @IBOutlet private weak var avatarIV: UIImageView?
    @IBOutlet private weak var usernameL: UILabel?
    @IBOutlet private weak var nameL: UILabel?
    
    @IBOutlet private weak var optionsListStack: UIStackView?
    
    @IBOutlet private weak var bioL: UILabel?
    @IBOutlet private weak var moreLessL: UILabel?
    
    @IBOutlet private weak var supportL: UILabel?
    
    @IBOutlet private weak var logoutBtn: UIButton?
    
    
    private var isMore: Bool = false
    
    private func setupProfileInfo() {
        usernameL?.text = profile?.username
        nameL?.text = profile?.name
        bioL?.text = profile?.bio
        if let image = profile?.avatar {
            avatarIV?.image = image
        } else {
            avatarIV?.image = UIImage(named: "avatar", in: Bundle(for: ProfileViewController.self),compatibleWith: nil)
        }
    }
    
    private func setupOptions() {
        optionsListStack?.subviews.forEach{$0.removeFromSuperview()}
        Option.allCases.forEach {[weak self] cased in
            let option = OptionView.Option(icon: cased.icon, title: cased.title)
            let view = OptionView()
            view.option = option
            view.onSelect = { option in
                let result = Option.allCases.first(where: {$0.title == option?.title}) ?? .wallet
                self?.optionDidSelect?(result)
            }
            self?.optionsListStack?.addArrangedSubview(view)
        }
    }
}

// MARK: - Actions

extension ProfileViewController {
    
    @IBAction private func onBackBtnDidTap(_ sender: AnyObject?) {
        onTapBack?()
    }
    
    @IBAction private func onEditBtnDidTap(_ sender: AnyObject?) {
        onTapEdit?()
    }
    
    @IBAction private func onChangePhotoBtnDidTap(_ sender: AnyObject?) {
        onTapChangePhoto?()
    }
    
    @IBAction private func onMoreLessBtnDidTap(_ sender: AnyObject?) {
        isMore.toggle()
        moreLessL?.text = isMore ? "Less" : "More"
        bioL?.numberOfLines = isMore ? 0 : 2
    }
    
    @IBAction private func onSupportBtnDidTap(_ sender: AnyObject?) {
        onTapSupport?()
    }
    
    @IBAction private func onLogoutBtnDidTap(_ sender: AnyObject?) {
        onTapLogout?()
    }
}

// MARK: - Data

extension ProfileViewController {
    
    enum Option: String, CaseIterable {
        case wallet
        case subscriptions
        case earnings
        case purchases
        case invite
        case settings
        
        var title: String {
            return self.localized(Bundle(for: ProfileViewController.self))
        }
        
        var icon: UIImage? {
            UIImage(named: self.rawValue, in: Bundle(for: ProfileViewController.self), compatibleWith: nil)
        }
    }
}
