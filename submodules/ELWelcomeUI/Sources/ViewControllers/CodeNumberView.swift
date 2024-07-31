//
//  CodeNumberView.swift
//  _idx_ELWelcomeUI_2FE1263A_ios_min15.4
//

import UIKit
import ELBase

enum CodeNumberViewState {
    case empty
    case filled
    case error
}

protocol CodeNumberViewDelegate: AnyObject {
    func didFilled(view: UIView)
    func didDelete(view: UIView)
}

final class CodeNumberView: UIView {
    
    // MARK: - Constants
    private struct Constants {
        static let grayColor = UIColor(red: 0.027, green: 0.027, blue: 0.031, alpha: 0.05) // TO DO: Update color when figma will be filled
        static let redColorName = "Red"
        static let cornerRadius: CGFloat = 10
    }
    
    // MARK: - Properties
    weak var delegate: CodeNumberViewDelegate?
    
    private var isDeleteAction: Bool = false
    private var textField: CodeTextField = {
        var textField = CodeTextField()
        textField.configure()
        textField.translatesAutoresizingMaskIntoConstraints = false

        return textField
    }()
    
    var state: CodeNumberViewState = .empty {
        didSet {
            changeState()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }

    func setupUI() {
        clipsToBounds = true
        layer.cornerRadius = Constants.cornerRadius
        layer.borderWidth = 1
        layer.borderColor = Constants.grayColor.cgColor
        addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 60.0),
            textField.widthAnchor.constraint(equalToConstant: 48.0),
            textField.centerXAnchor.constraint(equalTo: centerXAnchor),
            textField.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
        textField.customDelegate = self
        textField.delegate = self
    }
    
    func changeState() {
        switch state {
        case .empty:
            backgroundColor = Constants.grayColor
            layer.borderColor = Constants.grayColor.cgColor
        case .filled:
            backgroundColor = .white
            layer.borderColor = Constants.grayColor.cgColor
        case .error:
            backgroundColor = .white
            layer.borderColor = UIColor(named: Constants.redColorName, in: Bundle(for: Self.self), compatibleWith: nil)?.cgColor
        }
    }
}

// MARK: - Text Field Delegate
extension CodeNumberView: UITextFieldDelegate {

//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        state = .filled
//        return true
//    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        state = textField.text == "" ? .empty : .filled
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        textField.text = string
        string == "" ? delegate?.didDelete(view: self) : delegate?.didFilled(view: self)
        state = string == "" ? .empty : .filled
        print(state)
        return false
    }
}

// MARK: - Text Field Delegate
extension CodeNumberView: CodeTextFieldDelegate {
    
    func textFieldDidDelete() {
        delegate?.didDelete(view: self)
    }
}

// MARK: - Public
extension CodeNumberView {
    
    func deleteNumber() {
        textField.text = ""
    }
    
    func setNumber(number: Int) {
        textField.text = "\(number)"
    }
    
    func setFirstResponder() {
        //state = .filled
        textField.becomeFirstResponder()
    }
    
    func getNumber() -> String {
        return textField.text ?? ""
    }
}
