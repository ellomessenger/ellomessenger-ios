//
//  ConfirmPurchaseViewController.swift
//  _idx_ELCommonUI_856AD9E3_ios_min16.0
//
//

import UIKit
import ELBase
import ElloAppCore
import AccountContext

class ConfirmPurchaseViewController: BaseViewController {
    
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var rightProductImage: UIImageView!
    @IBOutlet private weak var leftProductImage: UIImageView!
    @IBOutlet private weak var rightPackImage: UIImageView!
    @IBOutlet private weak var leftPackImage: UIImageView!
    @IBOutlet private weak var middlePackImage: UIImageView!
    @IBOutlet private weak var availableLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var promtsDescLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var priceBGView: UIView!
    @IBOutlet private weak var imagesView: UIView!
    @IBOutlet private weak var infoStackView: UIStackView!
    @IBOutlet private weak var multipackImagesView: UIView!
    @IBOutlet private weak var multipackInfoStackView: UIStackView!
    @IBOutlet private weak var multipackPriceLabel: UILabel!
    @IBOutlet private weak var packFirstItemCountLabel: UILabel!
    @IBOutlet private weak var packSecondItemCountLabel: UILabel!
    @IBOutlet private weak var packFirstItemTitleLabel: UILabel!
    @IBOutlet private weak var packSecondItemTitleLabel: UILabel!
    @IBOutlet private weak var purchaseButton: UIButton!
    
    var confirmAction: VoidClosure?
    
    var purchasableProduct: iAPItemModel?
    
    // MARK: - Set up
    public override func storyboardName() -> String {
        return "Common"
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    private lazy var gradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(hex: 0x44BE2E).cgColor, UIColor(hex: 0x27AE60).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        return gradientLayer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        purchaseButton.layer.insertSublayer(gradientLayer, at: 0)
        
        
        guard var purchasableProduct else {
            return
        }
        amountLabel.text = "\(purchasableProduct.count)"
        priceLabel.text = purchasableProduct.type.price
        leftProductImage.image = purchasableProduct.rounded
        infoStackView.isHidden = false
        imagesView.isHidden = false
        multipackImagesView.isHidden = true
        multipackInfoStackView.isHidden = true
        switch purchasableProduct.type {
        case .text:
            promtsDescLabel.text = "IAP.AI.Prompts.Text".localized
        case .image:
            promtsDescLabel.text = "IAP.AI.Prompts.Image".localized
        case .textImage:
            
            infoStackView.isHidden = true
            imagesView.isHidden = true
            multipackImagesView.isHidden = false
            multipackInfoStackView.isHidden = false
            packFirstItemCountLabel.text = "50"
            packSecondItemCountLabel.text = "40"
            packFirstItemTitleLabel.text = "IAP.AI.Prompts.Text".localized
            packSecondItemTitleLabel.text = "IAP.AI.Prompts.Image".localized
            multipackPriceLabel.text = purchasableProduct.type.price
            
            leftPackImage.image = iAPItemModel.Avatar.text.image
            middlePackImage.image = iAPItemModel.Avatar.image.image
            return
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        gradientLayer.frame = purchaseButton.bounds
    }
    
    
    @IBAction func purchaseAction() {
        backBtnDidTap(nil)
        confirmAction?()
    }
}
