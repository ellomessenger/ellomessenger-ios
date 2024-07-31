//
//  ToastViewController.swift
//  ELProfileUI
//
//  Created by Oleksii Zabrodin on 21.02.2024.
//

import UIKit
import ELBase
import Lottie
import AppBundle

class ToastViewController: BaseViewController {
    enum ToastViewControllerType {
        case linkCopied
        case copied
        
        var message:String {
            switch self {
            case .linkCopied:
                "Referral code link copied"
            case .copied:
                "Referral code copied"
            }
        }
        
        var animation:String {
            switch self {
            case .linkCopied:
                "anim_linkcopied"
            case .copied:
                "anim_copy"
            }
        }
    }

    public var type:ToastViewControllerType = .linkCopied
    public var delay:CGFloat = 2
    
    @IBOutlet var animationView: AnimationView!
    @IBOutlet var messageLabel: UILabel!
    
    override func storyboardName() -> String {
        return "Loyalty"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messageLabel.text = type.message
        if let url = getAppBundle().url(forResource: type.animation, withExtension: "json"), let animation = Animation.filepath(url.path) {
            self.animationView.animation = animation
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animationView.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {[weak self]in
            guard let self else { return }
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func onTap(_ sender: Any) {
        self.animationView.stop()
        self.dismiss(animated: true)
    }
}
