//
//  BaseViewController.swift
//  _idx_ELProfileUI_139B49CA_ios_min11.0
//
//

import UIKit


open class BaseViewController: UIViewController {
    open lazy var onTapBack: VoidClosure? = { [weak self] in
        self?.dismiss(animated: true)
    }
    open var onWillAppear: VoidClosure?
    
    open func storyboardName() -> String {
        return ""
    }
        
    public static var controller: Self? {
        let storyboardName = Self().storyboardName()
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle(for: Self.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "\(String(describing: self))")
        return vc as? Self
    }
    
    public static func controller(with bundle: Bundle) -> Self? {
        let storyboardName = Self().storyboardName()
        let storyboard = UIStoryboard(name: storyboardName, bundle: bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: Self.self))
        
        return vc as? Self
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        // overrideUserInterfaceStyle is available with iOS 13
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            overrideUserInterfaceStyle = .light
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideKeyboardWhenTappedAround()
        onWillAppear?()
        localize()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    open func localize() {
        
    }
    
    @IBAction open func backBtnDidTap(_ sender: AnyObject?) {
        onTapBack?()
    }

    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

//public extension UINavigationController {
//    func popToRoot(animated: Bool) {
//        var controllers = self.viewControllers
//        while controllers.count > 1 {
//            controllers.removeLast()
//        }
//        self.setViewControllers(controllers, animated: animated)
//    }
//}
