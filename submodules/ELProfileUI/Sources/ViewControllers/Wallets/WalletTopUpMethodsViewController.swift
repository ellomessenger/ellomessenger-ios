//
//  WalletTopUpMethodsViewController.swift
//  _idx_ELProfileUI_BBFAEC0E_ios_min11.0
//
//  Created by Damir Aushenov on 18/2/23.
//

import UIKit
import ELBase
import ElloAppApi

public enum MethodTypes: String, Equatable {
    case deposit = "deposit"
    case withdrawal = "withdrawal"
}

struct MethodTypesViewModel {
    static func subtitle(withAmount amount: Double = 0, methodType:MethodTypes?) -> String {
        var method = "purchased"
        
        if let methodType {
            switch methodType {
            case .deposit:
                method = "purchased"
            case .withdrawal:
                method = "withdrawn"
            }
            return "You have \(method)"
        }
            
        let formattedAmount = String(format: "%.2f", amount)
        return "You \(method) $\(formattedAmount)."
    }
    
    static func subtitle(withMethodType methodType:MethodTypes?) -> String {
        if let methodType {
            switch methodType {
            case .deposit:
                return "Payment.Status.Success.Description".localized
            case .withdrawal:
                return "Payment.Status.Success.DescriptionWithdraw".localized
            }
        }

        return "Payment.Status.Success.Description".localized
    }
}

class WalletTopUpMethodsViewController: BaseViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<AnyHashable, TopUpMethodModel>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<AnyHashable, TopUpMethodModel>
    
    // MARK: - IBOutlets
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet private var navigationTitleLabel: UILabel!
    
    // MARK: - Properties
    public var methodTypes: MethodTypes?
    public var onTapOption: EventClosure<TopUpMethodModel>?
    public var walletItem: Api.wallet.WalletItem?
    public var walletItems: [Api.wallet.WalletItem]?

    private var items: [TopUpMethodModel] {
        guard let methodTypes else { return [] }
        switch methodTypes {
        case .deposit:
            return [/*.payPal, */.bankCard]
        case .withdrawal:
            if walletItem?.type == .earning {
                return [.myBalance, .bankCard]// removed PayPal - [.myBalance ,.payPal, .bankCard]
            } else {
                return [.payPal]
            }
        }
    }

    private lazy var dataSource = makeDataSource()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        createSnapshot()
    
        navigationTitleLabel.text = methodTypes == .deposit ? "Wallets.DepositMethod".localized : "Wallets.WithdrawalMethod".localized
    }
    
    // MARK: - Set up
    override func storyboardName() -> String {
        return "Wallet"
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(100.0),
            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(126.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(22.0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = .init(top: 16.0, leading: 16.0, bottom: 16.0, trailing: 16.0)
        section.interGroupSpacing = 16.0
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func configureCollectionView() {
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()
    }
    
    // MARK: - IBActions
    // MARK: - Actions
    private func makeDataSource() -> DataSource {
        DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: WalletTopUpCollectionViewCell.self),
                for: indexPath
            ) as? WalletTopUpCollectionViewCell
            cell?.configure(item: item)
            
            return cell
        }
    }
    
    private func createSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        
        dataSource.apply(snapshot)
    }
    
    // MARK: - Network Manager calls
}

// MARK: - UICollectionViewDelegate
extension WalletTopUpMethodsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        onTapOption?(item)
    }
}

extension UIButton {
    func enable() {
        DispatchQueue.main.async {
            self.isEnabled = true
            self.alpha = 1.0
        }
    }

    func disable() {
        DispatchQueue.main.async {
            self.isEnabled = false
            self.alpha = 0.5
        }
    }
}
