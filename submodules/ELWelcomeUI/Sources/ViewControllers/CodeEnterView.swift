//
//  CodeEnterView.swift
//  _idx_ELWelcomeUI_2AD85077_ios_min15.4
//

import UIKit

protocol CodeEnterViewDelegate: AnyObject {
    func didFilled(code : String)
}

final class CodeEnterView: UIView {
    
    // MARK: - Constants
    private struct Constants {
        static let bgGrayColorName = "BgGrey"
        static let redColorName = "Red"
        static let cornerRadius: CGFloat = 10
    }
    
    // MARK: - IBOutlet
    @IBOutlet private var numberViews: [CodeNumberView]!
    @IBOutlet private var wrongLabel: UILabel!
    private var isError = false
    
    weak var delegate: CodeEnterViewDelegate?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure() {
        setFirstResponder()
        configureEnterView()
      }
    
    func getCode() -> String {
        let code = numberViews.enumerated().map {
            $0.element.getNumber()
        }.reduce("", +)
        
        return code
    }
}

// MARK: - Private
private extension CodeEnterView {
    
    func configureEnterView() {
        numberViews.enumerated().forEach { index, view in
            view.delegate = self
            view.state = index == 0 ? .filled : .empty
            view.tag = index + 1
        }

        wrongLabel.isHidden = !isError
        wrongLabel.textColor = UIColor(named: Constants.redColorName, in: Bundle(for: Self.self), compatibleWith: nil)
        wrongLabel.text = "verifyInvalidCode".localized
        wrongLabel.alpha = 0
    }
    
    func setFirstResponder() {
        let view = numberViews.first {
            $0.tag == 0
        }
        view?.setFirstResponder()
    }
    
    func swapNumbers() {
        let first = numberViews.first {
            $0.tag == 0
        }
        
        let last = numberViews.last {
            $0.getNumber() != ""
        }
        
        guard let string = last?.getNumber(),
              let number = Int(string) else { return }
        
        first?.setNumber(number: number)
    }
    
    func changeToEmptyState(isFill : Bool) {
        isError = false
        numberViews.forEach { (view) in
            isFill && view.tag == 0 ? swapNumbers() : view.deleteNumber()
            view.state = .empty
        }
        
        let view = numberViews.first {
            $0.tag == 0 + (isFill ? 1 : 0)
        }
        
        view?.setFirstResponder()
    }
}

// MARK: - Code Number Delegate
extension CodeEnterView : CodeNumberViewDelegate {
    
    func didFilled(view: UIView) {
        if isError {
            changeToEmptyState(isFill: true)
            return
        }
        
        let nextTag = view.tag + 1
        if nextTag <= 6, let numberView = numberViews.first(where: { $0.tag == nextTag }) {
            numberView.setFirstResponder()
        } else {
            delegate?.didFilled(code: getCode())
        }
    }
    
    func didDelete(view: UIView) {
        if isError {
            changeToEmptyState(isFill: false)
            return
        }
        
        let view = numberViews.first {
            $0.tag == (view.tag - 1 >= 0 ? view.tag - 1 : 0)
        }
        
        isError = false
        view?.setFirstResponder()
    }
}
