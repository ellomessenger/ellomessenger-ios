//
//  CodeVerificationViewController.swift
//  _idx_ELWelcomeUI_30B6B8C6_ios_min11.0
//
//

import UIKit
import ELBase

enum Style {
    case email
    case business
    case code
}

public class CodeVerificationViewController: BaseViewController {
    
    // MARK: - @IBOutlet
    @IBOutlet private weak var titleL: UILabel?
    @IBOutlet private weak var descriptionL: UILabel?
    @IBOutlet private weak var codeInputView: CodeEnterView?
    @IBOutlet private weak var requestTimerL: UILabel?
    @IBOutlet private weak var timerL: UILabel?
    @IBOutlet private weak var secondsL: UILabel?
    @IBOutlet private weak var dontReceiveL: UILabel?
    @IBOutlet private weak var resendL: UILabel?
    @IBOutlet private weak var warningL: UILabel?
    @IBOutlet private weak var openMail: UIButton?
    
    // MARK: - Properties
    public var onVerifyCode: EventClosure<String?>?
    public var onTapResend: VoidClosure?
    public var onTapOpenMailApp: VoidClosure?
    public var isError: Bool?
    
    private var timerUnit: Timer?
    private var countDown: Int = 0
    var style: Style = .code {
        didSet {
            updateStyle()
        }
    }
    
    public var timer: Int = 180 {
        didSet{
            restartCountDown()
        }
    }
    
    // MARK: - Lifecycle
    public override func localize() {
        updateStyle()
        requestTimerL?.text = Localization.youCanRequestVerificationCodeIn.localized(Bundle(for: Self.self))
        secondsL?.text = Localization.seconds.localized(Bundle(for: Self.self))
        dontReceiveL?.text = Localization.dontReceiveCode.localized(Bundle(for: Self.self))
        resendL?.text = Localization.resendEmail.localized(Bundle(for: Self.self))
        warningL?.text = Localization.verifyCheckSpamWarning.localized(Bundle(for: Self.self))
        openMail?.setTitle(Localization.openEmailApp.localized(Bundle(for: Self.self)), for: .normal)
    }
    
    public override func storyboardName() -> String {
        return "WelcomeUI"
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        restartCountDown()
        
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        timerL?.text = "\(countDown)"
        codeInputView?.configure()
        codeInputView?.delegate = self
    }
    
    private func updateStyle() {
        switch style {
        case .code:
            titleL?.text = Localization.verificationCode.localized(Bundle(for: Self.self))
            descriptionL?.text = Localization.verificationCodeDescription.localized(Bundle(for: Self.self))
        case .email:
            titleL?.text = Localization.verifyYourEmail.localized(Bundle(for: Self.self))
            descriptionL?.text = Localization.verificationCodeDescription.localized(Bundle(for: Self.self))
        case .business:
            titleL?.text = Localization.verifyYourBusinessEmail.localized(Bundle(for: Self.self))
            descriptionL?.text = Localization.verifyYourBusinessEmailDescription.localized(Bundle(for: Self.self))
        }
    }
    
    private func restartCountDown() {
        timerUnit?.invalidate()
        countDown = timer
        timerL?.text = "\(countDown)"
        
        timerUnit = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] sht in
            guard let weak = self else {sht.invalidate(); return}
            if weak.countDown > 0 {
                weak.countDown -= 1
                weak.timerL?.text = "\(weak.countDown)"
            } else {
                sht.invalidate()
            }
        }
    }
}

// MARK: - Actions
extension CodeVerificationViewController {
    
    @IBAction private func resentBtnDidTap(_ sender: AnyObject?) {
        onTapResend?()
    }
    
    @IBAction private func openMailBtnDidTap(_ sender: AnyObject?) {
        view.endEditing(true)
        onTapOpenMailApp?()
    }
}

// MARK: - Code Enter Delegate
extension CodeVerificationViewController: CodeEnterViewDelegate {
    
    func didFilled(code: String) {
        if let code = codeInputView?.getCode(), code.count == 6 {
            onVerifyCode?(code)
        }
    }
}

// MARK: - Localization

private enum Localization: String {
    case verificationCode
    case verificationCodeDescription
    case verifyYourEmail
    case verifyYourBusinessEmail
    case verifyYourBusinessEmailDescription
    case verifyCheckSpamWarning
    case youCanRequestVerificationCodeIn
    case seconds
    case dontReceiveCode
    case resendEmail
    case openEmailApp
}
