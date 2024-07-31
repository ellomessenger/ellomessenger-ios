//
//  WelcomeController.swift
//  ElloApp
//
//

import UIKit
import Display
import ELBase
import ELLanguageUI

import SwiftSignalKit
import ELProfileUI

public struct Country {
    public var name: String
    public var code: String
    public var flagCode: String
    public var flag: URL?
    
    public init(name: String, code: String, flagCode: String, flag: URL? = nil) {
        self.name = name
        self.code = code
        self.flagCode = flagCode
        self.flag = flag
    }
}

public final class WelcomeController: ViewController {
    /// - Parameters:
    ///     - Bool:  isError
    ///     - String: error message
    public typealias CheckUsernameParams = (username: String, completion: TwoEventsClosure<Bool, String?>)
    public typealias CheckEmailParams = (email: String, completion: EventClosure<Bool>)
    
    // MARK: - Public
    public static var onLogin: ((String, String, _ completionHandler: EventClosure<Bool>?)->())?
    public static var onCheckUsername: ((CheckUsernameParams)->())?
    public static var onCheckEmail: ((CheckEmailParams)->())?
    public static var onRegister: ((RegistrationObject?)->())?
    public static var onOpenMailApp: VoidClosure?
    public static var onCodeVerify: ((_ code: String?, _ email: String)->())?
    public static var onResetPassword: ((_ email: String, _ showErrorAllert: Bool, _ result: @escaping ((Result<Never, Error>) -> Void)) -> Void)?
    public static var onNewPasswordStatic: ((_ email: String, _ code: String, _ password: String) -> Void)?
    public static var onBack: (()->())?
    public static var onTapResend: EventClosure<CodeVerificationViewController?>?
    
    public static var countriesSignal: Signal<[Country], Never>? {
        didSet{
            reloadCountries(complete: nil)
        }
    }
    
    private static func reloadCountries(complete: VoidClosure?) {
        _ = (countriesSignal! |> deliverOnMainQueue).start(next: { result in
            if result.count > 0 {
                countries = result
            }
            complete?()
        })
    }
    
    
    private static var countries: [Country] = []
    
    public static var controller: UIViewController? { //WelcomeController? {
        let storyboard = UIStoryboard(name: "WelcomeUI", bundle: bundle)
        let nc = storyboard.instantiateInitialViewController() as? UINavigationController
        
        let welcomeVC = nc?.topViewController as? ELWelcomeController
        welcomeVC?.onTapStart = {
            showLoginRegister()
        }
        
        welcomeVC?.onTapLangSelect = {
            if let lvc = LanguagesViewController.controller {
                lvc.onTapBack = {
                    lvc.navigationController?.popViewController(animated: true)
                }
                
                welcomeVC?.navigationController?.pushViewController(lvc, animated: true)
            }
        }
        
        rootViewController = welcomeVC
        
        let vc = nc//?.topViewController as?  WelcomeController
        return vc
    }
    
    public static func verifyCode(for email: String, till time: Int, isBusiness: Bool = false) -> CodeVerificationViewController? {
        
        guard let vc = CodeVerificationViewController.controller else { return nil }
        vc.onTapBack = {
            vc.navigationController?.popViewController(animated: true)
        }
        vc.style = isBusiness ? .business : .code
        vc.onVerifyCode = { code in
            onCodeVerify?(code, email)
        }
        vc.onTapOpenMailApp = {
            onOpenMailApp?()
        }
        vc.onTapResend = { [weak vc] in
            onTapResend?(vc)
        }
        
        rootViewController?.navigationController?.pushViewController(vc, animated: true)
        vc.timer = time - Int(Date().timeIntervalSince1970)
        
        return vc
    }
    
    public static func navigateToLoginScreen() {
        let viewControllers = rootViewController?.navigationController?.viewControllers
        var newStack = [UIViewController]()
        if viewControllers?.contains(where: {$0 is ELLoginContoller}) ?? false {
            for vc in viewControllers ?? [] {
                newStack.append(vc)
                if let lvc = vc as? ELLoginContoller {
                    lvc.reset()
                    break }
            }
        }
        rootViewController?.navigationController?.viewControllers = newStack
    }
    
    public static func newPassword(for email: String, code: String, onError: ErrorCallback?) {
        // show Code verification screen with timeout
        
        guard let vc = ELNewPasswordController.controller else {
            return
        }
        
        vc.onTapBack = {
            vc.navigationController?.popViewController(animated: true)
        }
        vc.onTapSend = { password in
            onNewPasswordStatic?(email, code, password)
        }
        vc.onPasswordError = onError
        
        rootViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Private
    
    private static var rootViewController: UIViewController?
    
    private static let bundle = Bundle(for: WelcomeController.self)
    
    private static var registrationFirstObject: RegistrationObject?
    
    private static func makeLoginRegister(isHideBack: Bool = true) -> ELLoginContoller? {
        if let vc = ELLoginContoller.controller {
            if !isHideBack {
                vc.onTapBack = {
                    if let onBack = self.onBack {
                        onBack()
                    }
                    else{
                        vc.navigationController?.popViewController(animated: true)
                    }
                }
            }
// remove to add Onboarding
            else {
                vc.onTapBack = nil
            }
            
            vc.onTapRegisterType = {
                switch $0 {
                case .personal: showRegistration(with: .personal)
                case .business: showRegistration(with: .business)
                }
            }
            
            vc.onTapLogin = { u, p, completionHandler in
                onLogin?(u, p, completionHandler)
            }
            
            vc.onTapForgotPassword = {
                showForgotPassword()
            }
            
            vc.onTapLoginTypesDescription = {
                showLoginTypeDescription()
            }
            
            return vc
        }
        
        return nil
    }
    
    public static func showLoginRegister(isHideBack: Bool = true) {
        if let vc = makeLoginRegister(isHideBack: isHideBack) {
            rootViewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private static func showLoginTypeDescription() {
        if let vc = ELLoginTypesDescriptionContoller.controller {
            vc.onTapBack = {
                vc.navigationController?.popViewController(animated: true)
            }
            rootViewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private static func showRegistration(with type: ProfileType) {
        if let vc = ELRegisterController.controller {
            
            vc.onCheckEmail = onCheckEmail
            vc.onCheckUsername = onCheckUsername
            vc.onTapBack = {
                vc.navigationController?.popViewController(animated: true)
            }
            
            vc.accountType = type
            vc.onTapAction = { object in
                switch object.profile {
                case .business:
                    onRegister?(object)
                case .personal:
                    registrationFirstObject = object
                    showAdditionalRegistration(vc)
                }
            }
            
            reloadCountries {
                vc.countries = countries
            }
            
            rootViewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private static func showAdditionalRegistration(_ parent: UIViewController) {
        if let vc = ELRegisterAdditionController.controller {
            vc.onTapBack = {
                vc.navigationController?.popViewController(animated: true)
            }
            
            vc.onTapRegister = { additional in
                registrationFirstObject?.country = additional.country
                registrationFirstObject?.date_of_birth = additional.dob
                registrationFirstObject?.gender = additional.gender.rawValue
                
                onRegister?(registrationFirstObject)
            }
            
            vc.countries = countries
            
            parent.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private static func showForgotPassword() {
        if let vc = ForgotPasswordViewController.controller {
            vc.onTapBack = {
                vc.navigationController?.popViewController(animated: true)
            }
            vc.onTapSend = {
                /// !!!!! Need to be updated with new API
                //                ononRegister?(registrationFirstObject?.username ?? "", registrationFirstObject?.password ?? "")
                onResetPassword?($0, false, $1)
                print("email to reset: \($0)")
            }
            
            rootViewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
