//
//  LanguagesViewController.swift
//  ElloApp
//
//

import UIKit
import ELBase
import ELCommonUI

public enum Language: String, CaseIterable {
    case english
    case russian
    
    var title: String {
        return self.localized.capitalizeFirst()
    }
}

public class LanguagesViewController: BaseViewController {
    
    // MARK: - Public
    
    public var onTapLanguage: EventClosure<Language>?
    
    // MARK: - Lifecycle
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    override public func localize() {
        titleL?.text = "WelcomeChooseLanguage".localized
        headerL?.text = Localization.chooseLanguages.localized(bundle)
    }
    
    override public func storyboardName() -> String {
        return "ELLanguageUI"
    }
    
    // MARK: - Private
    
    @IBOutlet private weak var titleL: UILabel?
    @IBOutlet private weak var headerL: UILabel?
    
    @IBOutlet private weak var stack: UIStackView?
    
    private let bundle = Bundle(for: LanguagesViewController.self)
    private let radioBtnOnImg = UIImage(named: "radio-on", in: Bundle(for: LanguagesViewController.self), compatibleWith: nil)
    private let radioBtnOffImg = UIImage(named: "radio-off", in: Bundle(for: LanguagesViewController.self), compatibleWith: nil)
    
    private var selectedLanguage: Language = .english
    
    private func setupUI() {
        stack?.subviews.forEach{$0.removeFromSuperview()}
        Language.allCases.forEach {[weak self] cased in
            let icon = cased == self?.selectedLanguage
            ? self?.radioBtnOnImg : self?.radioBtnOffImg
            
            let option = OptionView.Option(icon: icon, title: cased.title)
            let view = OptionView(option: option, iconShape: .square(24), showAccessory: false)
            view.onSelect = { option in
                let result = Language.allCases.first(where: {$0.title == option?.title}) ?? .english
                self?.selectedLanguage = result
                self?.onTapLanguage?(result)
                self?.setupUI()
            }
            self?.stack?.addArrangedSubview(view)
        }
    }
}

private enum Localization: String {
    case language
    case chooseLanguages
}
