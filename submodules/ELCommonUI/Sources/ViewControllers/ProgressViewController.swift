//
//  ProgressViewController.swift
//  _idx_ELCommonUI_E5937FD2_ios_min14.0
//
//

import UIKit
import ELBase

public class ProgressViewController: BaseViewController {
    
    public var headerTitle: String = "Payment.InProgress.Header".localized {
        didSet {
            headerLabel?.text = headerTitle
        }
    }
    
    public var progressTitle: String = "Payment.InProgress.Title".localized {
        didSet {
            titleLabel?.text = progressTitle
        }
    }
    
    public var progressDesription: String = "Payment.InProgress.Description".localized {
        didSet {
            descriptionLabel?.text = progressDesription
        }
    }
    
    public var closeButtonTitle: String = "Common.Cancel".localized {
        didSet {
            closeButton?.setTitle(closeButtonTitle, for: .normal)
        }
    }
    
    public var onTapClose: VoidClosure?
    
    @IBOutlet private weak var headerLabel: UILabel?
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var descriptionLabel: UILabel?
    @IBOutlet private weak var progressImage: UIImageView?
    @IBOutlet private weak var closeButton: UIButton?
    
    public var isHideButtonAndDesc: Bool = false
    
    // MARK: - Set up
    public override func storyboardName() -> String {
        return "Common"
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        headerLabel?.text = headerTitle
        titleLabel?.text = progressTitle
        descriptionLabel?.text = progressDesription
        closeButton?.setTitle(closeButtonTitle, for: .normal)
        closeButton?.layer.cornerRadius = 14
        closeButton?.layer.borderWidth = 1
        closeButton?.layer.borderColor = UIColor(hex: 0xcfcfd2).cgColor
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        progressImage?.rotate()
        if isHideButtonAndDesc {
            hideButtonAndDesc()
        }
    }
    
    @IBAction func closeAction() {
        onTapClose?()
    }
    
    func hideButtonAndDesc() {
        headerLabel?.alpha = 0
        closeButton?.isEnabled = false
        closeButton?.alpha = 0
        descriptionLabel?.isHidden = true
    }
}
