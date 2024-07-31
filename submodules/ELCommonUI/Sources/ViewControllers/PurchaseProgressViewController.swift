//
//  PurchaseProgressViewController.swift
//  _idx_ELCommonUI_E5937FD2_ios_min14.0
//
//

import UIKit
import ELBase

public class PurchaseProgressViewController: BaseViewController {
    
    public var onTapClose: VoidClosure?
    
    @IBOutlet private weak var progressImage: UIImageView?
    
    // MARK: - Set up
    public override func storyboardName() -> String {
        return "Common"
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        progressImage?.rotate()
    }
}


extension UIImageView{
    func rotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1.5
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
}
