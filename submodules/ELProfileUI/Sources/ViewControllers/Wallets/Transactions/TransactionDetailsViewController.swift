//
//  TransactionDetailsViewController.swift
//  _idx_ELProfileUI_3C450097_ios_min14.0
//
//

import UIKit
import ELBase
import ElloAppApi

final class TransactionDetailsViewController: BaseViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<AnyHashable, AnyHashable>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<AnyHashable, AnyHashable>
    
    // MARK: - IBOutlets
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    // MARK: - Properties
    private lazy var dataSource = createDataSource()
    
    var transactionItem: WalletTransaction?
    var requestService: RequestService?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let transactionItem {
            titleLabel.text =  String(format: "transactionDetails.title".localized, transactionItem.transaction.id)
        }
        
        configureCollectionView()
        createSnapshot()
    }
    
    // MARK: - Set up
    override func storyboardName() -> String {
        return "Transactions"
    }
    
    private func configureCollectionView() {
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()
    }
    
    private func titleItem() -> TransactionDetailsTitleItem? {
        guard let transactionItem, let peerType = transactionItem.transaction.peerType else { return nil }
        
        let transactionType: TransactionDetailsTitleItemType
        let amount = transactionItem.transaction.amount
        switch peerType {
        case .courseSubscription:
            transactionType = .onlineCourseFee(amount.isLess(than: .zero) ? .expenses : .income)
        case .channelsSubscription:
            transactionType = .subscriptionChannelFee(amount.isLess(than: .zero) ? .expenses : .income)
        case .transfer:
            transactionType = .transfer(amount.isLess(than: .zero) ? .expenses : .income)
        case .depositOrWithdrawal:
            transactionType = if transactionItem.transaction.paymentMethod == .apple {
                .apple
            } else {
                amount.isLess(than: .zero) ? .withdrawal : .deposit
            }
        case .mediaPurchase:
            transactionType = .mediaSale
        case .aiPacks, .aiSubscription, .aiTextPacks, .aiTextSubscription:
            transactionType = .aiTextPacks
        case .aiImagePacks, .aiImageSubscription:
            transactionType = .aiImagePacks
        case .loyaltyComission:
            transactionType = .referralComission
        case .loyaltyBonus:
            transactionType = .referralBonus
        case .aiImageTextPack:
            transactionType = .aiImageTextPacks
        }
        
        let title = if transactionType == .aiTextPacks {
            "transactionDetails.aiText".localized
        } else if transactionType == .aiImagePacks {
            "transactionDetails.aiPhoto".localized
        } else if transactionType == .aiImageTextPacks {
            "transactionDetails.aiPhotoText".localized
        } else if transactionType == .referralBonus {
            "transactionDetails.bonus".localized
        } else if transactionType == .referralComission {
            "transactionDetails.comission".localized
        } else if case let .transfer(operation) = transactionType {
            switch operation {
            case .income:
                "transactionDetails.transferFromBusinessWallet".localized
            case .expenses:
                "transactionDetails.transferToMainWallet".localized
            }
        } else {
            TopUpMethodModel(rawValue: transactionItem.serviceName ?? "")?.title.localized ?? transactionItem.serviceName?.capitalized
        }
        
        return TransactionDetailsTitleItem(title: title, transactionType: transactionType)
    }
    
    private func descriptionItem() -> TransactionDetailsDescriptionItem? {
        guard let transactionItem, let status = transactionItem.transaction.status else { return nil }
        
        let transactionStatus: TransactionDetailsDescriptionItemStatus
        switch status {
        case .processing, .adminCheck:
            transactionStatus = .pending
        case .completed:
            transactionStatus = .approved
        case .canceled, .error:
            transactionStatus = .rejected(reason: transactionItem.transaction.description)
        }
        
        let date = Date(timeIntervalSince1970: TimeInterval(transactionItem.transaction.createdAt))
        return TransactionDetailsDescriptionItem(
            status: transactionStatus,
            date: date.toString(dateFormat: .MMMMddyyyyHHmm),
            currency: transactionItem.transaction.currency.currencySymbol,
            amount: transactionItem.transaction.amount
        )
    }
    
    private func transactionDetailsItems() -> [TransactionDetailsItem] {
        guard let transaction = transactionItem?.transaction else { return [] }
        
         
        var transactionDetailsItems: [TransactionDetailsItem] = []
        
        //Purchase
        //TODO
        
        //Ello wallet
        if let name = titleItem()?.transactionType.walletType.name.localized {
            transactionDetailsItems.append(.paymentMethods(name, title: ""))
        }
        
        //Channel
        if let serviceName = transactionItem?.serviceName, (.channelsSubscription == transaction.peerType) && (.deposit == transaction.type) {
            transactionDetailsItems.append(.channel(serviceName))
        }
        
        //Course
        if let serviceName = transactionItem?.serviceName, (.courseSubscription == transaction.peerType) && (.deposit == transaction.type) {
            transactionDetailsItems.append(.course(serviceName))
        }
        
        //Commission
        if let fee = transaction.fee, !fee.isZero {
            transactionDetailsItems.append(.commission(fee.stringFinanceFormatWithDollar))
        }
        
        //Stripe commission
        if .stripe == transaction.paymentMethod, let paymentSystemFee = transaction.paymentSystemFee, !paymentSystemFee.isZero {
            let comission = String(format: "%@%.2f", transaction.currency.currencySymbol, paymentSystemFee)
            transactionDetailsItems.append(.stripeCommission(comission))
        }
        
        //PayPal commission
        if .paypal == transaction.paymentMethod, let paymentSystemFee = transaction.paymentSystemFee, !paymentSystemFee.isZero {
            let comission = String(format: "%@%.2f", transaction.currency.currencySymbol, paymentSystemFee)
            transactionDetailsItems.append(.payPalCommission(comission))
        }
        
        //Balance
        transactionDetailsItems.append(.balance(transaction.operationBalance.stringFinanceFormatWithDollar))
        
        //See receipt
        //TODO
        
        return transactionDetailsItems
        
    }
    
    private func transactionDetailsExpandableItem(isExpanded: Bool) -> TransactionDetailsExpandableItem? {
        guard transactionItem?.payment != nil else { return nil }
        
        // TODO: - Implement when added on backend
        return .purchase([
            "The Beatles - Gunna • 2022",
            "The Beatles",
            "Gunna • 2022",
            "• 2022",
            "2022"
        ], isExpanded)
    }
    
    // MARK: - IBActions
    
    // MARK: - Actions
    private func createDataSource() -> DataSource {
        DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            var reuseIdentifier = ""
            switch item {
            case is TransactionDetailsTitleItem:
                reuseIdentifier = TransactionDetailsTitleCollectionViewCell.reuseIdentifier
            case is TransactionDetailsDescriptionItem:
                reuseIdentifier = TransactionDetailsDescriptionCollectionViewCell.reuseIdentifier
            case is TransactionDetailsItem:
                reuseIdentifier = TransactionDetailsCollectionViewCell.reuseIdentifier
            case is TransactionDetailsExpandableItem:
                reuseIdentifier = TransactionDetailsExpandableCollectionViewCell.reuseIdentifier
            default:
                return UICollectionViewCell()
            }
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: reuseIdentifier,
                for: indexPath
            ) as? UICollectionViewCellDiffable
            
            if let transactionDetailsCollectionViewCell = cell as? TransactionDetailsCollectionViewCell {
                transactionDetailsCollectionViewCell.requestService = self.requestService
                transactionDetailsCollectionViewCell.transaction = self.transactionItem?.transaction
            }

            if let transactionDetailsTitleCollectionViewCell = cell as? TransactionDetailsTitleCollectionViewCell {
                transactionDetailsTitleCollectionViewCell.requestService = self.requestService
                transactionDetailsTitleCollectionViewCell.transaction = self.transactionItem?.transaction
            }
            
            cell?.configure(item: item)
            
            return cell
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 15.0, leading: 16.0, bottom: 0.0, trailing: 16.0)
        section.interGroupSpacing = 8.0
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func createSnapshot(withExpandedTransaction isExpanded: Bool = false) {
        var items: [AnyHashable?] = [titleItem(), descriptionItem(), transactionDetailsExpandableItem(isExpanded: isExpanded)]
        items.append(contentsOf: transactionDetailsItems())
        
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(items.compactMap { $0 })
        
        dataSource.apply(snapshot)
    }
    
    // MARK: - Navigation
    
    // MARK: - Network Manager calls
}

extension TransactionDetailsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) as? TransactionDetailsExpandableItem else {
            return
        }

        createSnapshot(withExpandedTransaction: !item.isExpanded)
    }
}
