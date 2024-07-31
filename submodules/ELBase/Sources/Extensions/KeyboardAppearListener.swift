import UIKit

public final class KeyboardAppearListener {
    private var showKeyboard: NSObjectProtocol?
    private var hideKeyboard: NSObjectProtocol?

    private weak var viewController: UIViewController?
    private var windowSafeArea: CGFloat = 0
    private var windowsSafeAreaWereAdded = false
    private let notificationCenter: NotificationCenter

    public init(_ viewController: UIViewController, notificationCenter: NotificationCenter = .default) {
        self.viewController = viewController
        self.notificationCenter = notificationCenter
        
        showKeyboard = notificationCenter.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main,
            using: { [weak self] notification in
                self?.keyboardWillShow(notification: notification)
            }
        )
        
        hideKeyboard = notificationCenter.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main,
            using: { [weak self] notification in
                self?.keyboardWillHide(notification: notification)
            }
        )
    }
    
    deinit {
        showKeyboard.map { notificationCenter.removeObserver($0) }
        hideKeyboard.map { notificationCenter.removeObserver($0) }
    }

    private func keyboardWillShow(notification: Notification) {
        guard
            let viewController = viewController,
            let userInfo = notification.userInfo,
            let beginKeyboardFrame = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect,
            let endKeyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            //The notificationCenter posts the notification each time user has taped on the input. Ignore when end and begin frame are the same
            endKeyboardFrame != beginKeyboardFrame
        else {
            return
        }
        // we need to subtract the windowSafeArea from the keyboardFrame.height because keyboard is connected to the bottom edge of the window and additionalSafeAreaInsets are added to the windowSafeArea.
        let windowSafeArea: CGFloat = windowsSafeAreaWereAdded ? 0 : viewController.view.safeAreaInsets.bottom - viewController.additionalSafeAreaInsets.bottom

        viewController.additionalSafeAreaInsets.bottom += beginKeyboardFrame.origin.y - endKeyboardFrame.origin.y - windowSafeArea

        animateUpdates(userInfo, viewController)
        windowsSafeAreaWereAdded = true

        if windowSafeArea > 0 {
            self.windowSafeArea = windowSafeArea
        }
    }

    private func keyboardWillHide(notification: Notification) {
        guard
            let viewController = viewController,
            let userInfo = notification.userInfo,
            let beginKeyboardFrame = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect,
            let endKeyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else {
            return
        }

        viewController.additionalSafeAreaInsets.bottom -= (endKeyboardFrame.origin.y - beginKeyboardFrame.origin.y - windowSafeArea)

        animateUpdates(userInfo, viewController)
        windowsSafeAreaWereAdded = false
    }

    private func animateUpdates(_ userInfo: [AnyHashable: Any], _ viewController: UIViewController) {
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey]
            .flatMap { $0 as? Double } ?? 0.25

        if duration > 0 {
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey]
                .flatMap { $0 as? Int }
                .flatMap { UIView.AnimationCurve(rawValue: $0) } ?? .easeInOut

            UIViewPropertyAnimator(duration: duration, curve: curve) {
                viewController.view.layoutIfNeeded()
            }
            .startAnimation()
        } else {
            viewController.view.layoutIfNeeded()
        }
    }
}
