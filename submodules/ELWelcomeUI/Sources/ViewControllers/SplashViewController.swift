//
//  SplashViewController.swift
//  _idx_ELWelcomeUI_DF76EB68_ios_min11.0
//
//

import UIKit
import ELBase

class SplashViewController: UIViewController {
    
    
    // MARK: - Public
    
    public static var controller: SplashViewController? {
        let storyboard = UIStoryboard(name: "WelcomeUI", bundle: Bundle(for: Self.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "SplashViewController")
        return vc as? SplashViewController
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        versionL?.text = "v\(App.version) (\(App.build)"
    }
    
    // MARK: - Private
    
    @IBOutlet private weak var versionL: UILabel?
    
    
}
