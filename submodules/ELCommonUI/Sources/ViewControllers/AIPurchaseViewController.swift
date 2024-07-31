//
//  AIPurchaseViewController.swift
//  _idx_ELCommonUI_A0D546AC_ios_min15.4
//
//

import UIKit
import ELBase
import ElloAppCore
import AccountContext

public class AIPurchaseViewController: BaseViewController {
    struct AIConsumableProductIds: ConsumableProductIds {
        let consumableProductIds = [
            "ai.consumable.text.200.requests",
            "ai.consumable.image.120.requests",
            "ai.consumable.image.text.pack"
        ]
    }
    
    // MARK: - Public
    public var onTapPurchase: (()->())?
    public var didPurchase: VoidClosure?
    public var context: AccountContext?
    
    // MARK: - Properties
    private let initialPage = 0
    private var purchaseItems: [iAPItemModel] = [] {
        didSet {
            guard !purchaseItems.isEmpty, let informationStackView else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let alertController = AlertViewController.createOkAlertController(
                        title: "Error",
                        message: "Problem in loading products for purchase") { [weak self] _ in
                            self?.backBtnDidTap(nil)
                        }
                    self.present(alertController, animated: true)
                }
                return
            }
            pageControl?.numberOfPages = purchaseItems.count
            pageControl?.currentPage = 0
            informationStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            purchaseItems.forEach { item in
                let purchaseInfo = PurchaseInfoView(frame: informationStackView.bounds)
                if item.type == .textImage {
                    purchaseInfo.config(models: [
                        .init(segment: "AI Chat", freeTitle: String(format: "iAP.AI.Consumable.Chat.Label".localized, "\(item.type.freeText)"), items: iAPItemModel.ListItem.textItems),
                        .init(segment: "AI Image", freeTitle: String(format: "iAP.AI.Consumable.Image.Label".localized, "\(item.type.freeImage)"), items: iAPItemModel.ListItem.imageItems)
                        
                    ])
                } else {
                    purchaseInfo.config(models: [
                        .init(segment: nil, freeTitle: String(format: "iAP.AI.Consumable.Label".localized, "\(item.freeCount)"), items: item.list)
                    ])
                }
                
                informationStackView.addArrangedSubview(purchaseInfo)
                
                purchaseInfo.translatesAutoresizingMaskIntoConstraints = false
                purchaseInfo.widthAnchor.constraint(equalTo: containerScrollView.widthAnchor, multiplier: 1).isActive = true
                purchaseInfo.layoutIfNeeded()
                purchaseInfo.itemUpdated = { [weak self] height in
                    self?.containerScrollViewHeight.constant = height
                }
            }
            //            informationStackView.translatesAutoresizingMaskIntoConstraints = false
            //            informationStackView.widthAnchor.constraint(equalToConstant: containerScrollView.bounds.width * CGFloat(informationStackView.arrangedSubviews.count)).isActive = true
            informationStackView.layoutIfNeeded()
            if let height = informationStackView.arrangedSubviews.first?.bounds.height {
                containerScrollViewHeight.constant = height
            }
            itemsCollectionView?.reloadData()
        }
    }
    private let bundle = Bundle(for: BaseViewController.self)
    private let iapService = iAPService(productIds: AIConsumableProductIds())
    
    @IBOutlet private weak var typeSegmentedControl: UISegmentedControl?
    @IBOutlet private weak var itemsCollectionView: UICollectionView?
    @IBOutlet private weak var informationStackView: UIStackView?
    @IBOutlet private weak var subsribeButton: UIButton!
    @IBOutlet private weak var resetPurchasesButton: UIButton!
    @IBOutlet private weak var containerScrollView: UIScrollView!
    @IBOutlet private weak var pageControl: UIPageControl?
    @IBOutlet private weak var containerScrollViewHeight: NSLayoutConstraint!
    // MARK: - Set up
    public override func storyboardName() -> String {
        return "Common"
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        updateAvailableProducts()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        itemsCollectionView?.register(
            UINib(
                nibName: "ProposeCell",
                bundle: Bundle(for: ProposeCell.self)
            ),
            forCellWithReuseIdentifier: ProposeCell.identifier
        )
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 315, height: itemsCollectionView?.bounds.height ?? 0)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        itemsCollectionView?.collectionViewLayout = layout
    }
    
    private func updateAvailableProducts() {
        Task {
            let processingVC: PurchaseProgressViewController! = PurchaseProgressViewController.controller
            processingVC.modalTransitionStyle = .crossDissolve
            present(processingVC, animated: true)
            
            await iapService.retrieveConsumableProducts()
            
            processingVC.dismiss(animated: true)
            
            let consumableItems = iAPItemModel.itemsForConsumable
            purchaseItems = iapService.consumableProducts.map { product in
                var item = consumableItems.first(where: { $0.id == product.id })
                item?.product = product
                return item
            }
            .compactMap { $0 }
            .sorted(by: { $0.type < $1.type })
        }
    }
    
    private func setupUI() {
        subsribeButton.setTitle("iAP.AI.Buy.Button".localized, for: .normal)
        subsribeButton.backgroundColor = UIColor(hex: 0x0A49A5)
        subsribeButton.setTitleColor(.white, for: .normal)
        subsribeButton.layer.cornerRadius = 14
        subsribeButton.titleLabel?.font = UIFont.Custom.sfProText(ofSize: 16, weight: .medium)
        resetPurchasesButton.setTitle("iAP.AI.Restore.Button".localized, for: .normal)
        resetPurchasesButton.setTitleColor(UIColor(hex: 0x0A49A5), for: .normal)
        resetPurchasesButton.titleLabel?.font = UIFont.Custom.sfProText(ofSize: 14, weight: .medium)
        typeSegmentedControl?.selectedSegmentIndex = 0
        typeSegmentedControl?.setTitle("iAP.AI.Segment.Subscription".localized, forSegmentAt: 0)
        typeSegmentedControl?.setTitle("iAP.AI.Segment.Buy".localized, forSegmentAt: 1)
    }
    
    @IBAction func typeChanged(_ sender: UISegmentedControl) {
        updateAvailableProducts()
    }
    
    @IBAction func pageControllChanged(_ sender: UIPageControl) {
        updatePurchaseInfoOffset()
        updateCollectionViewOffset()
    }
    
    private func updatePurchaseInfoOffset() {
        guard let currentPage = pageControl?.currentPage else {
            return
        }
        if let height = informationStackView?.arrangedSubviews[currentPage].bounds.height {
            containerScrollViewHeight.constant = height
        }
        
        itemsCollectionView?.isPagingEnabled = false
        let path = IndexPath(row: currentPage, section: 0)
        itemsCollectionView?.scrollToItem(at: path, at: .centeredHorizontally, animated: true)
        itemsCollectionView?.isPagingEnabled = true
        containerScrollView.setContentOffset(CGPoint(x: containerScrollView.bounds.width * CGFloat(currentPage), y: 0), animated: true)
    }
    
    private func updateCollectionViewOffset() {
        guard let currentPage = pageControl?.currentPage, let itemsCollectionView, let cellSize = itemsCollectionView.visibleCells.first?.bounds.size else {
            return
        }
        itemsCollectionView.setContentOffset(CGPoint(x: cellSize.width * CGFloat(currentPage), y: 0), animated: true)
    }
    
    @IBAction func subsribeAction(_ sender: Any) {
        guard !purchaseItems.isEmpty, let confirmVC = ConfirmPurchaseViewController.controller else {
            return
        }
        let purchasableProduct = purchaseItems[pageControl?.currentPage ?? 0]
        //        guard let product = purchasableProduct.product else {
        //            return
        //        }
        confirmVC.purchasableProduct = purchasableProduct
        present(confirmVC, animated: true)
        confirmVC.confirmAction = { [weak self] in
            let processingVC: PurchaseProgressViewController! = PurchaseProgressViewController.controller
            processingVC.modalTransitionStyle = .crossDissolve
            self?.present(processingVC, animated: true) {
                self?.buyPromptsByCoin(with: purchasableProduct) {
                    processingVC?.dismiss(animated: true)
                }
            }
            
            //            self?.iapService.buyProduct(product) { [weak self, weak processingVC] result in
            //                DispatchQueue.main.async {
            //                    if case let .success(type, quantity, amount, payload, _) = result {
            //                        _ = self?.context?.engine.aiChatBot.subscribeIAP(
            //                            type: type,
            //                            quantity: quantity,
            //                            amount: amount,
            //                            payload: payload
            //                        ).start(next: { [weak self] result in
            //                            processingVC?.dismiss(animated: true)
            //                            self?.statusController(
            //                                status: .success(
            //                                    title: "Bot.AI.Status.Success.Title".localized,
            //                                    description: String(format: "Bot.AI.Status.Purchase.Success".localized, quantity)
            //                                )
            //                            )
            //                            self?.didPurchase?()
            //                        }, error: { [weak self] error in
            //                            processingVC?.dismiss(animated: true)
            //                            debugPrint(error.errorDescription ?? "unknown error")
            //                            self?.statusController(
            //                                status: .failure(
            //                                    title: "Bot.AI.Status.Error.Title".localized + "!",
            //                                    description: "Bot.AI.Status.Purchase.Error".localized
            //                                )
            //                            )
            //                        })
            //                    } else {
            //                        processingVC?.dismiss(animated: true)
            //                        self?.statusController(
            //                            status: .failure(
            //                                title: "Bot.AI.Status.Error.Title".localized + "!",
            //                                description: "Bot.AI.Status.Purchase.Error".localized
            //                            )
            //                        )
            //                    }
            //                }
            //            }
        }
    }
    
    private func buyPromptsByCoin(with model: iAPItemModel, completion: @escaping () -> Void) {
        let type = {
            switch model.type {
            case .image: return 4
            case .text: return 3
            case .textImage: return 5
            }
        }()
        _ = context?.engine.aiChatBot.subscribe(type: type, quantity: model.count).start(
            next: { [weak self] aiSubscriptionInfoItem in
                completion()
                self?.statusController(
                    status: .success(
                        title: "Bot.AI.Status.Success.Title".localized,
                        description: String(format: (model.type == .textImage ? "Bot.AI.Status.ImageText.Purchase.Success" : "Bot.AI.Status.Purchase.Success").localized, model.count)
                    )
                )
                self?.didPurchase?()
            }, error: { [weak self] error in
                completion()
                let status: StatusViewController.Status = switch error {
                case .notEnoughCoins:
                        .failure(
                            title: "Bot.AI.Status.Error.Title".localized + "!",
                            description: "Bot.AI.Status.Purchase.Error.NotEnoughCoins".localized,
                            image: UIImage(
                                named: "PaymentStatusNotEnoughCoinsFailure",
                                in: Bundle(for: StatusViewController.self),
                                compatibleWith: nil
                            )
                        )
                case .message:
                        .failure(
                            title: "Bot.AI.Status.Error.Title".localized + "!",
                            description: "Bot.AI.Status.Purchase.Error".localized
                        )
                }
                
                self?.statusController(status: status)
            }
        )
    }
    
    private func statusController(status: StatusViewController.Status) {
        let adopt = AdaptingController(viewController: nil)
        if let vc = StatusViewController.controller {
            vc.status = status
            vc.closeButtonTitle = "back".localized
            
            vc.onTapClose = { [weak self] in
                if let vc = self?.navigationController?.viewControllers[1] {
                    self?.navigationController?.popToViewController(vc, animated: true)
                }
            }
            
            adopt.altController = vc
        }
        
        navigationController?.pushViewController(adopt, animated: true)
        
    }
    
    @IBAction func resetPurchasesAciton(_ sender: Any) {
        Task {
            await iapService.restorePurchases()
        }
    }
}

extension AIPurchaseViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        purchaseItems.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProposeCell.identifier, for: indexPath) as? ProposeCell else {
            return UICollectionViewCell()
        }
        if var item = purchaseItems[safe: indexPath.row] {
            cell.configurate(
                icon: item.icon,
                price: item.type.price,
                propose: item.propose,
                background: item.background,
                title: item.title,
                description: item.description,
                isProposeAdjustFont: item.type == .textImage
            )
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 60, height: collectionView.bounds.height)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int((scrollView.contentOffset.x / scrollView.bounds.width).rounded())
        pageControl?.currentPage = page
        updatePurchaseInfoOffset()
    }
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let page = Int((scrollView.contentOffset.x / scrollView.bounds.width).rounded())
            pageControl?.currentPage = page
            updatePurchaseInfoOffset()
        }
    }
}
