
import UIKit

internal var bottomLayoutConstraint: NSLayoutConstraint?

public extension UIViewController {

    //MARK: - Call to activate
    /**
     Call to activate
     */
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    func registerKeyboardNotifications(bottomConstraint:NSLayoutConstraint?) {
        bottomLayoutConstraint = bottomConstraint
        registerKeyboardNotifications()
    }
    //MARK: - May override to fetch activity
    /**
     Override to fetch activity
     */
    @objc
    open func keyboardDidShow() {

    }
    /**
     Override to fetch activity
     */
    func keyboardDidHide() {

    }


    //MARK: - Static
    /**
     Static
     */
    @objc final func keyboardDidShow(_ notification:Notification) {
        if let info = (notification as NSNotification).userInfo {
            let size = (info["UIKeyboardFrameEndUserInfoKey"] as? NSValue)?.cgRectValue.size;
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.1, animations: { [weak self] in
                bottomLayoutConstraint?.constant = size?.height ?? 0
                self?.view.layoutIfNeeded()
                },completion: { [weak self](finished) in
                    self?.keyboardDidShow()
            })
        }
    }
    /**
     Static
     */
    @objc final func keyboardDidHide(_ notification:Notification) {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            bottomLayoutConstraint?.constant = 0
            self?.view.layoutIfNeeded()
            },completion: { [weak self](finished) in
                self?.keyboardDidHide()
        })
    }
}

public extension UIViewController {
    func add(_ child: UIViewController, containerView: UIView? = nil) {
        child.view.translatesAutoresizingMaskIntoConstraints = false
        child.willMove(toParent: self)
        addChild(child)
        if let containerView {
            containerView.addSubview(child.view)
            NSLayoutConstraint.activate([
                child.view.topAnchor.constraint(equalTo: containerView.topAnchor),
                child.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                child.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                child.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
            ])
        } else {
            view.addSubview(child.view)
            NSLayoutConstraint.activate([
                child.view.topAnchor.constraint(equalTo: view.topAnchor),
                child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
        child.didMove(toParent: self)
    }
    
    func remove() {
        // Just to be safe, we check that this view controller
        // is actually added to a parent before removing it.
        guard parent != nil else { return }
        
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
