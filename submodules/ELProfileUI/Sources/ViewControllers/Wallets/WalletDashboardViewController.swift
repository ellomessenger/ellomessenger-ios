//
//  WalletDashboardViewController.swift
//  ElloApp
//
//  Created by Damir Aushenov on 15/2/23.
//

import UIKit
import ELBase
import ElloAppApi
import SwiftSignalKit
import ElloAppApi

protocol TransactionControllerContainable: UIViewController {
    var tableViewHeightConstraint: NSLayoutConstraint! { get set }
    var tableViewTopToNavbarConstraint: NSLayoutConstraint! { get set }
    var defaultTableViewHeight: CGFloat { get }
}

class WalletDashboardViewController: BaseViewController, TransactionControllerContainable {
    private typealias DataSource = UICollectionViewDiffableDataSource<AnyHashable, Api.wallet.WalletItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<AnyHashable, Api.wallet.WalletItem>
    
    // MARK: - IBOutlets
    @IBOutlet var navTitleLabel: UILabel!
    @IBOutlet var topUpButton: UIButton!
    @IBOutlet var withdrawalButton: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var statisticStackView: UIStackView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var containerView: UIView!
    @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var tableViewTopToNavbarConstraint: NSLayoutConstraint!
    @IBOutlet var graphContainerView: UIView!
    @IBOutlet var amountLastMonthLabel: UILabel!
    @IBOutlet var infoButton: UIButton!
    @IBOutlet var detailedTransactionButton: UIButton!
    @IBOutlet var donateStatisticButton: UIButton!
    @IBOutlet var transferOutButton: UIButton!
    @IBOutlet var historyTitleLabel: UILabel!
    @IBOutlet var cardDescriptionViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    public var onTapOption: EventClosure<(Api.wallet.WalletItem, MethodTypes, [Api.wallet.WalletItem])>?
    public var onTapSeeAll: EventClosure<Api.wallet.WalletItem>?
    public var onTapTransaction: EventClosure<WalletTransaction>?
    public var onTapWalletInfo: EventClosure<WalletType>?
    
    private lazy var dataSource = makeDataSource()
    private var currentWalletType: WalletType {
        walletItems[pageControl.currentPage].type
    }
    
    private var _walletItems: [Api.wallet.WalletItem] = []
    var walletItems: [Api.wallet.WalletItem] {
        get {
            _walletItems
        }
        set {
            _walletItems = newValue.reversed()
        }
    }
    var transactionController: TransactionHistoryViewController?
    var dashboardMonthGraphController: DashboardMonthGraphViewController?
    var requestService: RequestService?
    var defaultTableViewHeight: CGFloat { max(self.view.bounds.height - historyTitleLabel.convert(historyTitleLabel.frame, to: self.view).maxY - 12, 170) }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.numberOfPages = walletItems.count
        
        configurateView(type: currentWalletType)
        configureCollectionView()
        createSnapshot()
        
        addTransactionHistoryContainerController()
        addDashboardMonthGraphContainerController()
        
        dashboardMonthGraphController?.commonAmountHandler = { [weak self] amountLastMonth in
            self?.amountLastMonthLabel.text = String(
                format: "%.2f %@",
                amountLastMonth,
                "Last.month".localized(Bundle(for: Self.self))
            )
        }
        
        tableViewHeightConstraint.constant = defaultTableViewHeight
    }
    
    // MARK: - Set up
    override func storyboardName() -> String {
        return "Wallet"
    }
    
    override func localize() {
        navTitleLabel.text = "Wallets.ElloPay".localized
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0.0, leading: 16.0, bottom: 0.0, trailing: 16.0)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        section.visibleItemsInvalidationHandler = { [weak self] (items, offset, env) -> Void in
            guard let self else { return }
            
            let page = Int(round(offset.x / view.bounds.width))
            if page != pageControl.currentPage {
                pageControl.currentPage = page
                
                dashboardMonthGraphController?.wallet = walletItems[safe: page]
                dashboardMonthGraphController?.requestLastMonthActivityGraphic()
                transactionController?.wallet = walletItems[safe: page]
                configurateView(type: currentWalletType)
                
                transactionController?.requestTransaction()
            }
        }
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func configurateView(type: WalletType) {
//        statisticStackView.isHidden = type.isMain
        topUpButton.isHidden = type.isEarning
        withdrawalButton.isHidden = type.isMain
        infoButton.isHidden = type.isMain
//        donateStatisticButton.isHidden = type.isEarning
        cardDescriptionViewHeightConstraint.constant = type.isEarning ? 63 : 0
        UIView.animate(
            withDuration: CATransaction.animationDuration(),
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 1,
            options: [],
            animations: {
                self.infoButton.superview?.layoutIfNeeded()
            },
            completion: nil
        )
    }
    
    private func configureCollectionView() {
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()
    }
    
    // MARK: - IBActions
    @IBAction func topUpTap(_ sender: Any) {
        guard let walletItem = walletItems.first(where: { $0.type.isMain }) else {
            return
        }
                
        onTapOption?((walletItem, .deposit, walletItems))
    }
    
    @IBAction func withdrawTap(_ sender: Any) {
        guard let walletItem = walletItems.first(where: { $0.type == currentWalletType }) else {
            return
        }
                
        onTapOption?((walletItem, .withdrawal, walletItems))
    }
    
    @IBAction func seeAllDetailedTransaction(_ sender: UIButton) {
        guard let walletItem = walletItems.first(where: { $0.type == currentWalletType }) else {
            return
        }
        
        onTapSeeAll?(walletItem)
    }
 
    @IBAction func showTransferNote(_ sender: Any) {
        showTransactionNoteAlert()
    }
    
    @IBAction func donateStatisticTapped(_ sender: Any) {
        showDonateAlert()
    }
    
    @IBAction func walletInfoTapped(_ sender: Any) {
        onTapWalletInfo?(currentWalletType)
    }
    
    // MARK: - Actions
    private func addDashboardMonthGraphContainerController() {
        let storyboard = UIStoryboard(name: "Wallet", bundle: Bundle(for: Self.self))
        dashboardMonthGraphController = storyboard.instantiateViewController(withIdentifier: "DashboardMonthGraphViewController") as? DashboardMonthGraphViewController
        dashboardMonthGraphController?.requestService = requestService
        dashboardMonthGraphController?.wallet = walletItems[safe: pageControl.currentPage]
        add(dashboardMonthGraphController, toContainerView: graphContainerView)
    }
    
    private func addTransactionHistoryContainerController() {
        let storyboard = UIStoryboard(name: "Transactions", bundle: Bundle(for: Self.self))
        transactionController = storyboard.instantiateViewController(withIdentifier: "TransactionHistoryViewController") as? TransactionHistoryViewController
        transactionController?.requestService = requestService
        transactionController?.wallet = walletItems[safe: pageControl.currentPage]
        transactionController?.onTapTransaction = onTapTransaction
        add(transactionController, toContainerView: containerView)
    }
    private func showAlert() {
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let image = UIImage(named: "myImage")
        let alertController = AlertViewController.createAlertControllerWithImage(
            title: "Error: Something went wrong.",
            message: "Please try again.",
            preferredStyle: .alert,
            actions: [okAction],
            image: image
        )
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func showTransactionNoteAlert() {
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let image = UIImage(named: "Wallet/info-button", in: Bundle(for: Self.self), compatibleWith: nil)
        let alertController = AlertViewController.createAlertControllerWithTopImage(
            title: "Wallets.Note".localized,
            message: "Wallets.PaymentsInfoMessage".localized,
            preferredStyle: .alert,
            actions: [okAction],
            image: image
        )
        
        present(alertController, animated: true, completion: nil)

    }
    
    private func showDonateAlert() {
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let image = UIImage(named: "Wallet/info-button", in: Bundle(for: Self.self), compatibleWith: nil)
        let alertController = AlertViewController.createAlertControllerWithTopImage(
            title: "Wallets.Note".localized,
            message: "Not implemented yet",
            preferredStyle: .alert,
            actions: [okAction],
            image: image
        )
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func makeDataSource() -> DataSource {
        DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: WalletCardCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? WalletCardCollectionViewCell
            cell?.configure(item: item)
            
            return cell
        }
    }
    
    private func createSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(walletItems)
        
        dataSource.apply(snapshot)
    }
    
    // MARK: - Navigation
    
    // MARK: - Network Manager calls
    func updateWallets() {
        Task {
            walletItems = (try? await requestService?.getWallets()) ?? []
            pageControl.numberOfPages = walletItems.count
            
            createSnapshot()
        }
    }
}

// MARK: - Extensions
@nonobjc extension UIViewController {
    func add(_ child: UIViewController?, frame: CGRect? = nil, toContainerView containerView: UIView) {
        guard let child else { return }
        
        addChild(child)
        
        if let frame = frame {
            child.view.frame = frame
        }
        
        child.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(child.view)
        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0),
            child.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            child.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
            child.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0)
        ])
        
        child.didMove(toParent: self)
    }
    
    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
