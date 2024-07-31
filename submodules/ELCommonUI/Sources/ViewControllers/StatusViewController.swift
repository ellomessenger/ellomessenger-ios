//
//  StatusViewController.swift
//  _idx_ELCommonUI_2B4C8285_ios_min14.0
//
//

import UIKit
import ELBase

public class StatusViewController: BaseViewController {
    public enum Status {
        case success(
            title: String = "Payment.Status.Success.Title".localized,
            description: String = "Payment.Status.Success.Description".localized,
            image: UIImage? = UIImage(
                named: "PaymentStatusSuccess",
                in: Bundle(for: StatusViewController.self),
                compatibleWith: nil
            ),
            value: Double? = nil
        )
        case failure(
            title: String = "Payment.Status.Failure.Title".localized,
            description: String = "Payment.Status.Failure.Description".localized,
            image: UIImage? = UIImage(
                named: "PaymentStatusFailure",
                in: Bundle(for: StatusViewController.self),
                compatibleWith: nil
            ),
            value: Double? = nil
        )
    }
    
    public var status: Status? {
        didSet {
            updateStatus()
        }
    }
    
    public var closeButtonTitle: String = "Common.Cancel".localized {
        didSet {
            closeButton?.setTitle(closeButtonTitle, for: .normal)
        }
    }
    
    public var onTapClose: VoidClosure?
    
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var descriptionLabel: UILabel?
    @IBOutlet private weak var descriptionImage: UIImageView?
    @IBOutlet private weak var descriptionValueLabel: UILabel?
    @IBOutlet private weak var statusImageView: UIImageView?
    @IBOutlet private weak var closeButton: UIButton?
    
    // MARK: - Set up
    public override func storyboardName() -> String {
        return "Common"
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        updateStatus()
        closeButton?.setTitle(closeButtonTitle, for: .normal)
        closeButton?.layer.cornerRadius = 14
        closeButton?.layer.borderWidth = 1
        closeButton?.layer.borderColor = UIColor(hex: 0xcfcfd2).cgColor
    }
    
    func updateStatus() {
        guard let status else { return }
        
        switch status {
        case let .success(title, description, statusImage, value),
             let .failure(title, description, statusImage, value):
            titleLabel?.text = title
            descriptionLabel?.text = description
            statusImageView?.image = statusImage
            
            if let value {
                descriptionValueLabel?.text = String(format: "%.2f", value)
            }
            
            descriptionImage?.isHidden = nil == value
            descriptionValueLabel?.isHidden = nil == value
       }
    }
    
    @IBAction func closeAction() {
        onTapClose?()
    }
}
