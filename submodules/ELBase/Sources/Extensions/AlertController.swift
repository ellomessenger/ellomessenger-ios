import UIKit

class AlertController {
    
    static var defaultOkAction = UIAlertAction(title: Localization.okButton, style: .default, handler: nil)
    static var defaultCancelAction = UIAlertAction(title: Localization.cancelButton, style: .default, handler: nil)
    
    //MARK: - AlertControllers
    
    static func show(title: String?, message: String?, actions: [UIAlertAction]? = nil, justCancelButtonTitle:String? = nil, presenter: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let actions = actions {
            for action in actions {
                alert.addAction(action)
            }
        } else {
            let defaultAction = UIAlertAction(title: justCancelButtonTitle ?? Localization.cancelButton, style: .default, handler: nil)
            alert.addAction(defaultAction)
        }
        presenter.present(alert, animated: true)
    }
    
    static func showToast(message : String, seconds: Double, presenter: UIViewController) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.black
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 15
        
        presenter.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
}

// MARK: - Localization

extension AlertController {
    
    private enum Localization {
        static let okButton = "alert_ok".localized
        static let cancelButton = "alert_cancel".localized
    }
}
