//
//  AccountInfoViewController.swift
//  ELProfileUI
//
//


import UIKit
import ELBase
import ElloAppApi
import AccountContext
import AvatarNode
import Postbox
import ElloAppCore
import SwiftSignalKit
import ElloAppPresentationData
import ElloAppStringFormatting


class AccountInfoViewController: BaseViewController {
    
    final class DataSource: UITableViewDiffableDataSource<Section, AnyHashable> {
        var sectionsTitle: [String] = []
        
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            sectionsTitle[section]
        }
    }
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>
    
    enum Section: Hashable {
        case wallet(wallets: [Wallet]),
             payedSubscription(items: [PaidSubscriptionItem]),
             payedSubscriptionOwner(items: [PayedSubscription]),
             aiBotInfo(info: [BotInfo])
        
        var values: [AnyHashable] {
            switch self {
            case let .wallet(items):
                return items
            case let .payedSubscriptionOwner(items):
                return items
            case let .payedSubscription(items):
                return items
            case let .aiBotInfo(items):
                return items
            }
        }
        var title: String {
            switch self {
            case .wallet:
                return "DeleteAccount.AccountInfo.elloPay".localized
            case .payedSubscription:
                return "DeleteAccount.AccountInfo.subscriptions".localized
            case .payedSubscriptionOwner:
                return "DeleteAccount.AccountInfo.owner".localized
            case .aiBotInfo:
                return "DeleteAccount.AccountInfo.ai".localized
            }
        }
        
        var actionButton: String {
            switch self {
            case .wallet:
                return "DeleteAccount.AccountInfo.goToElloPay".localized
            case .payedSubscription:
                return "DeleteAccount.AccountInfo.goToSubscriptions".localized
            case .payedSubscriptionOwner:
                return "DeleteAccount.AccountInfo.goToOwner".localized
            case .aiBotInfo:
                return "DeleteAccount.AccountInfo.goToAI".localized
            }
        }
    }
    
    struct ActionButton: Hashable {
        let title: String
    }
    struct Wallet: Hashable {
        let name: String
        let amount: Int64
        let symbol: String
    }
    struct BotInfo: Hashable {
        let name: String
        let value: Int
    }
    struct PayedSubscription: Hashable {
        let id: UUID
        let peerId: PeerId
        let title: String
        let endDate: Int?
        let isActive: Bool
        let price: Int
    }
    
    override func storyboardName() -> String {
        return "ELProfileUI"
    }
    
    @IBOutlet private weak var titleL: UILabel?
    @IBOutlet private weak var actionButton: UIButton?
    @IBOutlet private weak var tableView: UITableView!
    
    
    var onTapDelete: VoidClosure?
    var onTapGoToElloPay: EventClosure<[Api.wallet.WalletItem]>?
    var onTapGoToAI: VoidClosure?
    var onTapGoToOwner: VoidClosure?
    var onTapGoToSubsciptions: VoidClosure?
    var onOpenChat: EventClosure<PeerId>?
    private lazy var dataSource = makeDataSource()
    private var infoResponse: Api.Response.DeleteAccountResponse?
    
    var sections: [Section] = [] {
        didSet {
            createSnapshot(sections)
        }
    }
    var requestContext: AccountContext?
    private func setFooter(isReadyToDelete: Bool) {
        let footer = AccountInfoFooter()
        footer.config(isReadyToDelete:isReadyToDelete, action: self.onTapDelete)
        footer.layoutIfNeeded()
        let size = footer.systemLayoutSizeFitting(CGSize.zero)
        footer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        tableView?.tableFooterView = footer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateActionButton(false)
        tableView?.sectionHeaderTopPadding = 20
        tableView?.contentInset = .init(top: 10, left: 0, bottom: 16, right: 0)
        tableView?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let requestContext else {
            return
        }
        _ = (getDeleteAccountInfo(network: requestContext.account.network) |> deliverOnMainQueue)
            .start(next: { [weak self] response in
                guard let self, let requestContext = self.requestContext else {
                    return
                }
                self.infoResponse = response
                _ = combineLatest(
                    requestContext.account.network.request(Api.functions.channels.getChannels(id: response.paidChannelsOwner.chats.map { .inputChannel(channelId: Int64($0.id), accessHash: 0)})),
                    requestContext.account.network.request(Api.paidSubscription.subscriptions(filterType: .active)))
                .start(next: {
                    self.buildSections(info: response, ownerChannels: $0, subscriptions: $1)
                })
            }, error: {  [weak self] error in
                print(error)
                self?.onTapBack?()
            })
    }
    
    private func buildSections(info: Api.Response.DeleteAccountResponse, ownerChannels: Api.messages.Chats, subscriptions: PaidSubscriptionItems) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let ownerSubscriptions: [PayedSubscription] = {
                switch ownerChannels {
                case .chats(let chats):
                    return chats.compactMap {
                        if let channel = parseElloAppGroupOrChannel(chat: $0) as? ElloAppChannel {
                            return PayedSubscription(id: UUID(), peerId: channel.id, title: channel.title, endDate: Int(channel.endDate ?? 0), isActive: true, price: Int(channel.cost ?? 0))
                        } else {
                            return nil
                        }
                    }
                default: return []
                }
            }()
            self.sections = [
                .wallet(wallets: info.wallets.wallets.map {
                    Wallet(name: $0.type.name, amount: Int64($0.amount), symbol: $0.assetName)
                }),
                .payedSubscription(items: subscriptions.items),
                .payedSubscriptionOwner(items: ownerSubscriptions),
                .aiBotInfo(info: [
                    .init(name: "DeleteAccount.AccountInfo.ai.text".localized, value: info.aiSubInfo.textTotal),
                    .init(name: "DeleteAccount.AccountInfo.ai.image".localized, value: info.aiSubInfo.imgTotal),
                ].filter { $0.value > 0 })
            ]
            self.setFooter(isReadyToDelete: info.wallets.wallets.filter { $0.amount > 0 }.isEmpty && info.paidChannelsOwner.chats.isEmpty && info.paidChannelsSubscribe.chats.isEmpty && info.aiSubInfo.imgTotal == 0 && info.aiSubInfo.textTotal == 0)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func localize() {
        actionButton?.setTitle("deleteAccountBtn".localized, for: .normal)
        actionButton?.setTitle("deleteAccountBtn".localized, for: .disabled)
    }
    
    private func updateActionButton(_ isActive: Bool) {
        actionButton?.isEnabled = isActive
        actionButton?.titleLabel?.textColor = isActive ? UIColor.buttonBlue : UIColor.buttonDarkGrey
        actionButton?.backgroundColor = isActive ? UIColor.white : UIColor.textGray
    }
    
    
    private func makeDataSource() -> DataSource {
        DataSource(tableView: self.tableView) { [weak self] tableView, indexPath, itemIdentifier in
            guard let self else {
                return UITableViewCell()
            }
            let section = self.sections[indexPath.section]
            func actionCell(section: Section, title: String?, action: VoidClosure?) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: String(describing: AccountInfoButtonCell.self),
                    for: indexPath
                ) as? AccountInfoButtonCell
                cell?.config(title: title, buttonTitle: section.actionButton, action: action)
                return cell!
            }
            switch section {
            case let .wallet(items):
                if indexPath.row >= items.count {
                    return actionCell(section: section, title: nil, action: {
                        [weak self] in
                        guard let self, let info = self.infoResponse else {
                            return
                        }
                        self.onTapGoToElloPay?(info.wallets.wallets)
                    })
                }
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: String(describing: AccountInfoWalletCell.self),
                    for: indexPath
                ) as? AccountInfoWalletCell
                let wallet = items[indexPath.row]
                cell?.config(title: wallet.name.localized, value: String(format: "%ld", wallet.amount))
                return cell!
            case let .payedSubscriptionOwner(items):
                if indexPath.row >= items.count {
                    return actionCell(section: section, title: items.isEmpty ? "DeleteAccount.AccountInfo.emptySubscriptions".localized : nil, action: self.onTapGoToOwner)
                }
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: String(describing: SubscriptionChannelCell.self),
                    for: indexPath
                ) as? SubscriptionChannelCell
                cell?.subscriptionItem(items[indexPath.row], context: self.requestContext)
                return cell!
            case let .payedSubscription(items):
                if indexPath.row >= items.count {
                    return actionCell(section: section, title: items.isEmpty ? "DeleteAccount.AccountInfo.emptyOwner".localized : nil, action: self.onTapGoToSubsciptions)
                }
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: String(describing: SubscriptionChannelCell.self),
                    for: indexPath
                ) as? SubscriptionChannelCell
                cell?.subscriptionItem(items[indexPath.row], context: self.requestContext)
                return cell!
            case let .aiBotInfo(items):
                if indexPath.row >= items.count {
                    return actionCell(section: section, title: items.isEmpty ? "DeleteAccount.AccountInfo.emptyAI".localized : nil, action: self.onTapGoToAI)
                }
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: String(describing: AccountInfoAIBotCell.self),
                    for: indexPath
                ) as? AccountInfoAIBotCell
                let botInfo = items[indexPath.row]
                cell?.config(title: botInfo.name, value: "\(botInfo.value) \(botInfo.value > 1 ? "Requests".localized : "Request".localized)")
                return cell!
            }
        }
    }
    
    private func createSnapshot(_ sections: [Section]) {
        var snapshot = Snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections(sections)
        sections.forEach {
            snapshot.appendItems($0.values, toSection: $0)
            snapshot.appendItems([ActionButton(title: $0.actionButton)], toSection: $0)
        }
        dataSource.sectionsTitle = sections.map { $0.title }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension AccountInfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = self.sections[indexPath.section]
        guard let peerId = {
            switch section {
            case let .payedSubscription(items):
                return PeerId(Int64(items[indexPath.row].peerId))
            case let .payedSubscriptionOwner(items):
                return items[indexPath.row].peerId
            default:
                return nil
            }
        }() else {
            return
        }
        onOpenChat?(peerId)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let section = self.sections[indexPath.section]
        switch section {
        case let .payedSubscription(items):
            if indexPath.row >= items.count {
                return nil
            }
            return indexPath
        case let .payedSubscriptionOwner(items):
            if indexPath.row >= items.count {
                return nil
            }
            return indexPath
        default:
            return nil
        }
    }
    
}
