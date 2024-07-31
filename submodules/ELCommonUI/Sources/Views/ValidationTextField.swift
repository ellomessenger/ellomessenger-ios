//
//  ValidationTextField.swift
//  _idx_ELWelcomeUI_B3056AB3_ios_min14.0
//
//

import UIKit
import ELBase
@objc public protocol ValidationTextFieldDelegate: AnyObject {
    func textFieldDidChange(_ textField: ValidationTextField)
}
   
@IBDesignable
 
public class ValidationTextField: BaseView, ValidationTextFieldDelegate {
    // MARK: - IBOutlets
    @IBOutlet private weak var containerTFView: UIView!
    @IBOutlet private weak var textFieldContainerSV: UIStackView!
    @IBOutlet public weak var textField: DesignableUITextField!
    @IBOutlet public weak var lengthLabel: UILabel!
    @IBOutlet private weak var eyeBtn: UIButton!
    @IBOutlet private var errorTextView: UITextView! {
        didSet {
            errorTextView.textContainer.lineFragmentPadding = .zero
            errorTextView.textContainerInset = .zero
            errorTextView.contentInset = .zero
        }
    }
    @IBOutlet public weak var validationDelegate: ValidationTextFieldDelegate!
    
    // MARK: - Properties
    @IBInspectable var isBordered: Bool = true {
        didSet {
            updateBorder(for: text)
            let horisontalMargins: CGFloat = isBordered ? 12 : 0
            textFieldContainerSV.layoutMargins = UIEdgeInsets(top: 0, left: horisontalMargins, bottom: 0, right: horisontalMargins)
        }
    }
    // MARK: - Properties
    @IBInspectable var viewBackgroundColor: UIColor = UIColor(hexString: "#EEEEEF")! {
        didSet {
            textField.backgroundColor = viewBackgroundColor
            containerTFView.backgroundColor = viewBackgroundColor
        }
    }
    private lazy var bundle: Bundle = Bundle(for: BaseViewController.self)
    private lazy var eyeImg = UIImage(named: "eye", in: bundle, compatibleWith: nil)
    private lazy var eyeSlashImg = UIImage(named: "eye-slash", in: bundle, compatibleWith: nil)
    
    /// - Parameters:
    ///    - text: TextField text
    ///    - isValid: Is local valid text
    public var onTextChange: ((_ text: String?, _ isValid: Bool)-> Void)?
    public var onError: ((String?)->())?
    public var onReturn: VoidClosure?
    public var isSecure: Bool = false {
        didSet {
            eyeBtn.isHidden = !(validator?.isSecure ?? false)
            textField.isSecureTextEntry = isSecure
        }
    }
    public var validator: Validator? {
        didSet {
            guard let validator else {
                isSecure = false
                return
            }
            isSecure = validator.isSecure
        }
    }
    public var text: String? {
        set {
            textField.text = newValue
        }
        get {
            textField.text
        }
    }
    public var maxLength: Int? {
        didSet {
            guard let maxLength else {
                return
            }
            lengthLabel.text = "\(maxLength - (text?.count ?? 0))"
        }
    }
    public var maxLengthVisible: Bool = false {
        didSet {
            lengthLabel.isHidden = !maxLengthVisible
        }
    }
    public var errorDescription: String? {
        didSet {
            guard let errorDescription else {
                errorTextView.isHidden = true
                containerTFView.borderColor = UIColor(hexString: "#0A49A5")
                return
            }
            errorTextView.isHidden = false
            
            if let htmlData = errorDescription.data(using: .utf8),
               let font = errorTextView.font,
               let color = errorTextView.textColor {
                let attributedString = try? NSMutableAttributedString(
                    data: htmlData,
                    options: [
                        .documentType: NSAttributedString.DocumentType.html,
                        .characterEncoding: String.Encoding.utf8.rawValue],
                    documentAttributes: nil
                )
                attributedString?.addAttributes(
                    [
                        .font: font,
                        .foregroundColor: color,
                        .underlineColor: color
                    ],
                    range: NSMakeRange(0, attributedString?.length ?? 0))
                errorTextView.linkTextAttributes = [
                    .font: font,
                    .foregroundColor: color,
                    .underlineColor: color
                ]
                errorTextView.attributedText = attributedString
            } else {
                errorTextView.text = errorDescription
            }
            containerTFView.borderColor = UIColor(hexString: "#EF4062")
            onError?(errorDescription)
        }
    }
    public var isValid: Bool {
        errorDescription == nil && !(textField.text?.isEmpty ?? true)
    }
    
    // MARK: - Life Cycle
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        eyeBtn.isHidden = true
        textField.isSecureTextEntry = false
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        eyeBtn.isHidden = true
        textField.isSecureTextEntry = false
    }
    
    // MARK: - Additional Methods
    private func setup() {
        textField.backgroundColor = viewBackgroundColor
        containerTFView.backgroundColor = viewBackgroundColor
        containerTFView.borderWidth = 0
        errorTextView.isHidden = true
        textField.autocorrectionType = .no 
        textField.delegate = self
    }
    
    public func setPlaceholder(_ placeholder: String, isRequired: Bool) {
        let attributedPlaceholder = NSMutableAttributedString(string: (isBordered ? " " : "") + "\(placeholder)")
        
        if isRequired {
            guard let color = UIColor(hexString: "EF4062") else { return }
            let asterix = NSAttributedString(string: "*", attributes: [.foregroundColor: color])
            attributedPlaceholder.insert(asterix, at: 0)
        }
        textField.attributedPlaceholder = attributedPlaceholder
    }
    
    private func updateBorder(for text: String?) {
        guard let text, !text.isEmpty && isBordered else {
            setup()
            return
        }
        textField.backgroundColor = viewBackgroundColor
        containerTFView.backgroundColor = viewBackgroundColor
        containerTFView.borderWidth = 0
    }
    
    // MARK: - IBActions
    @IBAction private func toggleEyeBtnDidTap(_ sender: AnyObject?) {
        isSecure.toggle()
        let img = textField.isSecureTextEntry ? eyeSlashImg : eyeImg
        eyeBtn.setImage(img, for: .normal)
    }
    
    @IBAction public func textFieldsDidChange(_ sender: UITextField) {
        validate(isEditing: true)
    }
    
    public func validate(isEditing: Bool = false) {
        errorDescription = nil
        guard let validator, let value = textField.text else {
            onTextChange?(textField.text, true)
            return
        }
        do {
            try validator.validate(value: value)
            errorDescription = nil
            if isEditing {
                onTextChange?(value, true)
            }
        } catch {
            errorDescription = error.localizedDescription
            if isEditing {
                onTextChange?(value, false)
            }
        }
    }
    
    public func addHorisontalMargins(_ horisontalMargins: CGFloat = 12) {
        textFieldContainerSV.layoutMargins = UIEdgeInsets(top: 0, left: horisontalMargins, bottom: 0, right: horisontalMargins)
    }
}

// MARK: - UITextFieldDelegate
extension ValidationTextField: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        if isBordered {
            self.textField.backgroundColor = UIColor(hexString: "FFFFFF")
            containerTFView.backgroundColor = UIColor.white
            containerTFView.borderColor = UIColor(hexString: "#0A49A5")
            containerTFView.borderWidth = 1.0
        }
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        updateBorder(for: textField.text)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturn?()
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let maxLength, let text = textField.text else {
            return true
        }
        let isCanEdit = text.count < maxLength
        let newLength = (text as NSString).replacingCharacters(in: range, with: string).count
        let isLessLength = text.count > newLength
        if isCanEdit || isLessLength {
            lengthLabel.text = "\(maxLength - newLength)"
        }
        
        return isCanEdit || isLessLength
    }
    
    public func textFieldDidChange(_ textField: ValidationTextField) {
        guard let textField = textField.textField else { return }
        textFieldsDidChange(textField)
    }
}

// MARK: - UITextViewDelegate
extension ValidationTextField: UITextViewDelegate {
    public func textViewDidChangeSelection(_ textView: UITextView) {
        if !NSEqualRanges(textView.selectedRange, NSMakeRange(0, 0)) {
            textView.selectedRange = NSMakeRange(0, 0)
        }
    }
}
