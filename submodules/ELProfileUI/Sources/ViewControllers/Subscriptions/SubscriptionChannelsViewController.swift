//
//  SubscriptionChannelsViewController.swift
//  _idx_ELProfileUI_41162252_ios_min11.0
//
//

import UIKit
import ELBase
import ElloAppApi
import AnimationUI

class SubscriptionChannelsViewController: BaseViewController {
    private typealias DataSource = UITableViewDiffableDataSource<AnyHashable, PaidSubscriptionItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<AnyHashable, PaidSubscriptionItem>
    
    // MARK: - IBOutlets
    @IBOutlet private weak var titleL: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var menuButton: UIButton!
    @IBOutlet private weak var emptyStackView: UIStackView?
    @IBOutlet private weak var emptyAnimationView: UIView?
    @IBOutlet private weak var emptyTitleLabel: UILabel?
    
    // MARK: - Properties
    var requestService: RequestService?
    private let animationNode = AnimationNode()
    private lazy var dataSource = makeDataSource()
    private var currentSubscriptionFilterType: PaidSubscriptionFilterType = .active {
        didSet {
            menuButton.setTitle(currentSubscriptionFilterType.menuButtonTitle, for: .normal)
            requestSubscriptions(currentSubscriptionFilterType)
        }
    }
    
    private lazy var menuItems: [UIAction] = {
        [
            UIAction(
                title: "MyCurrentSubscriptions".localized,
                image: UIImage(
                    named: "Subscriptions/menu-current-subscriptions",
                    in: Bundle(for: Self.self),
                    compatibleWith: nil
                )
            ) { [weak self] _ in
                self?.currentSubscriptionFilterType = .active
            },
            UIAction(
                title: "MyPreviousSubscriptions".localized,
                image: UIImage(
                    named: "Subscriptions/menu-previous-subscriptions",
                    in: Bundle(for: Self.self),
                    compatibleWith: nil
                )
            ) { [weak self] _ in
                self?.currentSubscriptionFilterType = .cancelled
            }
        ]
    }()
    
    // MARK: - Life cycle
    override func localize() {
        titleL?.text = "CurrentSubscriptions".localized
        menuButton.setTitle("PaidChannels".localized, for: .normal)
    }
    
    override func storyboardName() -> String {
        return "Subscriptions"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureButtonMenu()
        
        requestSubscriptions(currentSubscriptionFilterType)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let animationView = emptyAnimationView {
            animationNode.frame = animationView.bounds
            
            animationView.addSubnode(animationNode)
        }
    }
    
    // MARK: - Set up
    func configureButtonMenu() {
        menuButton.menu = UIMenu(children: menuItems)
        menuButton.showsMenuAsPrimaryAction = true
    }
    
    func showEmptyAnimation() {
        animationNode.setAnimation(name: "TransactionHistoryNoResults")
        animationNode.loop()
    }

    // MARK: - IBActions
    
    // MARK: - Actions
    private func makeDataSource() -> DataSource {
        DataSource(tableView: tableView) { [weak self] tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: SubscriptionChannelCell.self),
                for: indexPath
            ) as? SubscriptionChannelCell
            cell?.subscriptionItem(item, context: self?.requestService?.accountContext)
            cell?.onMenuTapHandle = { [weak self] subscriptionItem in
                if subscriptionItem.isActive {
                    self?.unsubscribe(peerId: subscriptionItem.peerId, peerType: subscriptionItem.peerType ?? 3)
                } else {
                    self?.subscribe(peerId: subscriptionItem.peerId, peerType: subscriptionItem.peerType ?? 3)
                }
            }
            
            return cell
        }
    }
    
    private func createSnapshot(_ subscriptionItems: [PaidSubscriptionItem]) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(subscriptionItems)
        
        dataSource.apply(snapshot)
    }
    
    // MARK: - Navigation
    
    // MARK: - Network Manager calls
    private func requestSubscriptions(_ filterType: PaidSubscriptionFilterType) {
        Task {
            if let subscriptionItems = try? await requestService?.subscriptions(filterType) {
                createSnapshot(subscriptionItems)
                emptyStackView?.isHidden = !subscriptionItems.isEmpty
                showEmptyAnimation()
            } else {
                createSnapshot([])
            }
        }
    }
    
    private func subscribe(peerId: Int, peerType: Int) {
        Task {
            if let _ = try? await requestService?.subscribe(peerId, peerType: peerType) {
                requestSubscriptions(currentSubscriptionFilterType)
            }
        }
    }
    
    private func unsubscribe(peerId: Int, peerType: Int) {
        Task {
            if let _ = try? await requestService?.unsubscribe(peerId, peerType: peerType) {
                requestSubscriptions(currentSubscriptionFilterType)
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension SubscriptionChannelsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
//        onTapChannel?(channels[indexPath.row])
    }
}

fileprivate extension PaidSubscriptionFilterType {
    var menuButtonTitle: String {
        switch self {
        case .active:
            return "PaidChannels".localized
        case .cancelled:
            return "MyPreviousSubscriptions".localized
        case .all:
            return ""
        }
    }
}
