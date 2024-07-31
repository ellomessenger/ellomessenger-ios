//
//  FeedRootViewController.swift
//  _idx_ELFeedUI_4B46E6E7_ios_min11.0
//
//

import UIKit
import ELBase
import SwiftSignalKit
import AccountContext
import ElloAppApi
import Display
import ElloAppPresentationData
import AvatarNode
import ElloAppCore
import PhotoResources
import Postbox

class FeedForMeViewController: BaseViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<AnyHashable, FeedRootItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<AnyHashable, FeedRootItem>
    
    // MARK: - IBOutlets
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var emptyView: UIView!
    
    // MARK: - Properties
    private lazy var dataSource = makeDataSource()
    var context: AccountContext!
    var getAdoptViewController: (() -> ViewController)?
    var feedItems: [FeedRootItem] = [] {
        didSet {
            configureEmptyView()
            createSnapshot()
        }
    }
    var showPeerInfo: ((_ peer: ElloAppChannel) -> Void)?
    var onHideTapHandle: ((_ peerId: Int64) -> Void)?
    var onReportTapHandle: ((_ messageId: MessageId) -> Void)?
    var showChatControllerHandler: ((_ channelPeerId: PeerId, _ engineMessageId: EngineMessage.Id) -> Void)?
    var showMessageRepliesController: ((_ peer: ElloAppChannel, _ engineMessageId: EngineMessage.Id) -> Void)?
    /// - Parameters:
    ///     - MessageId:  MessageId to like
    ///     - Bool: Add like or remove
    var onLikeTapHandle: TwoEventsClosure<MessageId, Bool>?
    /// - Parameters:
    ///     - Page to fetch
    var onFetchFeedHandle: EventClosure<Int>?
    var isFeedScrollOnTop: Bool {
        collectionView.contentOffset.y == 0
    }
    private lazy var refreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_ :)), for: .valueChanged)
        
        return refreshControl
    }()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(BackgroundSupplementaryView.self, forSupplementaryViewOfKind: "tail", withReuseIdentifier: BackgroundSupplementaryView.reuseIdentifier)
        
        configureCollectionView()
        configureEmptyView()
    }
    
    // MARK: - Set up
    private func configureCollectionView() {
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createCollectionViewLayout()
        collectionView.refreshControl = refreshControl
    }
    
    private func configureEmptyView() {
        emptyView.isHidden = !feedItems.isEmpty
        collectionView.isHidden = feedItems.isEmpty
    }
    
    // MARK: - IBActions
    
    // MARK: - Actions
    private func makeDataSource() -> DataSource {
        let dataSourse = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FeedForMeCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? FeedForMeCollectionViewCell
            if let context = self?.context {
                cell?.configure(with: item, context: context, feedContentManager: FeedContentManager(accountContext: context, feedItem: item, controller: self?.getAdoptViewController?()))
            }
            cell?.showPeerInfoHandler = self?.showPeerInfo
            cell?.onHideTapHandle = self?.onHideTapHandle
            cell?.onReportTapHandle = self?.onReportTapHandle
            cell?.showMessageRepliesController = self?.showMessageRepliesController
            cell?.onLikeTapHandle = self?.onLikeTapHandle
            
            return cell
        }
        
        dataSourse.supplementaryViewProvider = { (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            collectionView.dequeueReusableSupplementaryView(ofKind: "tail", withReuseIdentifier: BackgroundSupplementaryView.reuseIdentifier, for: indexPath)
        }
        
        return dataSourse
    }
    
    func createCollectionViewLayout() -> UICollectionViewLayout {
        // Supplementary Item
        let layoutSize = NSCollectionLayoutSize(widthDimension: .absolute(16.0), heightDimension: .absolute(34.0))
        let containerAnchor = NSCollectionLayoutAnchor(
            edges: [.leading, .bottom],
            absoluteOffset: CGPoint(x: -10, y: -1)
        )
        let supplementaryItem = NSCollectionLayoutSupplementaryItem(
            layoutSize: layoutSize,
            elementKind: "tail",
            containerAnchor: containerAnchor
        )
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize, supplementaryItems: [supplementaryItem])
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.84),
            heightDimension: .estimated(100.0)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8.0
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 0)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func createSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(feedItems, toSection: 0)
        dataSource.apply(snapshot)
    }
    
    @objc
    private func didPullToRefresh(_ sender: Any) {
        onFetchFeedHandle?(0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.refreshControl.endRefreshing()
        }
    }
}

// MARK: - UICollectionViewDelegate
extension FeedForMeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        guard let channel = item.channel else { return }
        guard let messageId = item.messageId else { return }
        
        showChatControllerHandler?(channel.id, messageId)
    }
}

extension FeedForMeViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if let row = indexPaths.last?.row, row == feedItems.count - 1 {
            onFetchFeedHandle?(Int((Double(row) / Double(RequestsManager.feedPageLimit)).rounded(.awayFromZero)))
        }
    }
}
