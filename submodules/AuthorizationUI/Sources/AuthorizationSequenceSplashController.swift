import Foundation
import UIKit
import Display
import AsyncDisplayKit
import Postbox
import ElloAppCore
import SwiftSignalKit
import ElloAppPresentationData
import LegacyComponents
import SolidRoundedButtonNode
import ElloAppApi
import ELBase

import ELWelcomeUI
import ELProfileUI

final class AuthorizationSequenceSplashController: ViewController {
    
    private var controllerNode: AuthorizationSequenceSplashControllerNode {
        return self.displayNode as! AuthorizationSequenceSplashControllerNode
    }
    
    var nextPressed: ((PresentationStrings?) -> Void)?
    var onSignUp: ((ELWelcomeUI.RegistrationObject?)->())?
    
    /// Callback on tap login in sign in screen
    ///
    /// - Parameters:
    ///   - userName: username to login
    ///   - password: password to login
    ///   - completionHandler:Closure with **true** if success login, **false** if error
    ///
    var onSignIn: ((_ userName: String, _ password: String, _ completionHandler: EventClosure<Bool>?) -> Void)?
    var onCodeToVerify: ((_ code: String?, _ email: String, _ password: String, _ isNeedConfirm: Bool) -> Void)?
    var onResetPassword: ((_ email: String, _ showErrorAllert: Bool, _ result: @escaping ((Result<Never, Error>) -> Void)) -> Void)?
    var onResetPasswordCodeToVerify: ((String?, String) -> Void)?
    var onNewPassword: ((String, String, String) -> Void)?
    var onCheckUsername: ((WelcomeController.CheckUsernameParams)->())?
    var onCheckEmail: ((WelcomeController.CheckEmailParams)->())?
    var onTapResend: EventClosure<CodeVerificationViewController?>?
    var onOpenMailApp: VoidClosure?
    
    private let accountManager: AccountManager<ElloAppAccountManagerTypes>
    private let account: UnauthorizedAccount
    private let theme: PresentationTheme
    private let altController: UIViewController
    private var validLayout: ContainerViewLayout?
    
    func verifyRegistrationCode(for email: String, till time: Int, password: String, isNeedConfirmEmail: Bool = false) {
        _ = WelcomeController.verifyCode(for: email, till: time)
        WelcomeController.onCodeVerify = { [weak self] code, email in
            self?.onCodeToVerify?(code, email, password, isNeedConfirmEmail)
        }
        
        WelcomeController.onTapResend = onTapResend
        WelcomeController.onOpenMailApp = onOpenMailApp
    }
    
    func registrationCodeVerified() {
        navigateToLoginScreen()
    }
    
    func verifyPasswordResetCode(for email: String, till time: Int) {
        _ = WelcomeController.verifyCode(for: email, till: time)
        WelcomeController.onCodeVerify = { [weak self] email, code in
            self?.onResetPasswordCodeToVerify?(email, code)
        }
        WelcomeController.onTapResend = onTapResend
    }
    
    func passwordResetVerified(email: String, code: String, onError: ErrorCallback?) {
        WelcomeController.newPassword(for: email, code: code, onError: onError)
    }
    
    func passwordChanged() {
        navigateToLoginScreen()
    }
    
    func navigateToLoginScreen() {
        WelcomeController.navigateToLoginScreen()
    }
    
    private let suggestedLocalization = Promise<SuggestedLocalizationInfo?>()
    private let activateLocalizationDisposable = MetaDisposable()
        
    init(accountManager: AccountManager<ElloAppAccountManagerTypes>, account: UnauthorizedAccount, theme: PresentationTheme) {
        self.accountManager = accountManager
        self.account = account
        self.theme = theme
        
        self.suggestedLocalization.set(.single(nil)
        |> then(ElloAppEngineUnauthorized(account: self.account).localization.currentlySuggestedLocalization(extractKeys: ["Login.ContinueWithLocalization"])))
        let suggestedLocalization = self.suggestedLocalization
        
        let _ = SSignal(generator: { subscriber in
            let disposable = suggestedLocalization.get().start(next: { localization in
                guard let _ = localization else {
                    return
                }

            }, completed: {
                subscriber.putCompletion()
            })
            
            return SBlockDisposable(block: {
                disposable.dispose()
            })
        })
        
        self.altController = WelcomeController.controller ?? UINavigationController()

        
        super.init(navigationBarPresentationData: nil)
        
        self.supportedOrientations = ViewControllerSupportedOrientations(regularSize: .all, compactSize: .portrait)
        
        self.statusBar.statusBarStyle = theme.intro.statusBarStyle.style
        WelcomeController.onLogin = {[weak self] u, p, completionHandler in
            print("Auth on login: \(u)/\(p)")
            self?.onSignIn?(u, p, completionHandler)
        }
        
        WelcomeController.onRegister = { [weak self] object in
            print("Auth on registration: \(String(describing: object))")
            self?.onSignUp?(object)
        }
        
        WelcomeController.onResetPassword = { [weak self] email, showErrorAlert, result in
            self?.onResetPassword?(email, showErrorAlert, result)
        }
        
        WelcomeController.onNewPasswordStatic = { [weak self] email, code, password in
            self?.onNewPassword?(email, code, password)
        }
        
        WelcomeController.onCheckUsername = { [weak self] in
            self?.onCheckUsername?($0)
        }
        
        WelcomeController.onCheckEmail = { [weak self] in
            self?.onCheckEmail?($0)
        }
        
        WelcomeController.countriesSignal = Signal<[ELWelcomeUI.Country], Never> { observer in
           return (ElloAppEngineUnauthorized(account: account).localization.getCountriesList(accountManager: accountManager, langCode: "", forceUpdate: true)
                     |> deliverOnMainQueue)
                .start(next: { countries in
                    let processed = countries.map{
                        ELWelcomeUI.Country(name: $0.name, code: $0.countryCodes.first?.code ?? "", flagCode: $0.localizedName ?? "", flag: URL(string: $0.id))
                    }
                    observer.putNext(processed)
                }, completed: {
                    observer.putCompletion()
                })
        }
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.activateLocalizationDisposable.dispose()
    }
    
    override public func loadDisplayNode() {
        self.displayNode = AuthorizationSequenceSplashControllerNode(theme: self.theme)
        self.displayNodeDidLoad()
    }
    
    var buttonFrame: CGRect {
        return .zero
    }
    
    var buttonTitle: String {
        return ""
    }
    
    var animationSnapshot: UIView? {
        return nil
    }
    
    var textSnaphot: UIView? {
        return nil
    }
    
    private func addControllerIfNeeded() {
        if !self.displayNode.view.subviews.contains(self.altController.view) {
            self.displayNode.view.addSubview( self.altController.view)
        }
        altController.view.frame = self.displayNode.view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addControllerIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        
        self.validLayout = layout
//        let controllerFrame = CGRect(origin: CGPoint(), size: layout.size)
        
        self.controllerNode.containerLayoutUpdated(layout, navigationBarHeight: 0.0, transition: transition)
        
        self.addControllerIfNeeded()
    }
    
    private func activateLocalization(_ code: String) {
        let currentCode = self.accountManager.transaction { transaction -> String in
            if let current = transaction.getSharedData(SharedDataKeys.localizationSettings)?.get(LocalizationSettings.self) {
                return current.primaryComponent.languageCode
            } else {
                return "en"
            }
        }
        let suggestedCode = self.suggestedLocalization.get()
        |> map { localization -> String? in
            return localization?.availableLocalizations.first?.languageCode
        }
        
        let _ = (combineLatest(currentCode, suggestedCode)
        |> take(1)
        |> deliverOnMainQueue).start(next: { [weak self] currentCode, suggestedCode in
            guard let strongSelf = self else {
                return
            }
            
            if let suggestedCode = suggestedCode {
                _ = ElloAppEngineUnauthorized(account: strongSelf.account).localization.markSuggestedLocalizationAsSeenInteractively(languageCode: suggestedCode).start()
            }
            
            if currentCode == code {
                strongSelf.pressNext(strings: nil)
                return
            }
            
            let accountManager = strongSelf.accountManager
            
            strongSelf.activateLocalizationDisposable.set(ElloAppEngineUnauthorized(account: strongSelf.account).localization.downloadAndApplyLocalization(accountManager: accountManager, languageCode: code).start(completed: {
                let _ = (accountManager.transaction { transaction -> PresentationStrings? in
                    let localizationSettings: LocalizationSettings?
                    if let current = transaction.getSharedData(SharedDataKeys.localizationSettings)?.get(LocalizationSettings.self) {
                        localizationSettings = current
                    } else {
                        localizationSettings = nil
                    }
                    
                    let stringsValue: PresentationStrings
                    if let localizationSettings = localizationSettings {
                        stringsValue = PresentationStrings(primaryComponent: PresentationStrings.Component(languageCode: localizationSettings.primaryComponent.languageCode, localizedName: localizationSettings.primaryComponent.localizedName, pluralizationRulesCode: localizationSettings.primaryComponent.customPluralizationCode, dict: dictFromLocalization(localizationSettings.primaryComponent.localization)), secondaryComponent: localizationSettings.secondaryComponent.flatMap({ PresentationStrings.Component(languageCode: $0.languageCode, localizedName: $0.localizedName, pluralizationRulesCode: $0.customPluralizationCode, dict: dictFromLocalization($0.localization)) }), groupingSeparator: "")
                    } else {
                        stringsValue = defaultPresentationStrings
                    }
                    
                    return stringsValue
                }
                |> deliverOnMainQueue).start(next: { strings in
                    self?.pressNext(strings: strings)
                })
            }))
        })
    }
    
    private func pressNext(strings: PresentationStrings?) {
        if let navigationController = self.navigationController, navigationController.viewControllers.last === self {
            self.nextPressed?(strings)
        }
    }
}
