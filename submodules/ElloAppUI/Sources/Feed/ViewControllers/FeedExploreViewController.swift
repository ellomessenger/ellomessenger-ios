//
//  FeedExploreViewController.swift
//  ElloAppUI
//
//

import AccountContext
import ELBase
import ElloAppCore
import Postbox
import UIKit

class FeedExploreViewController: BaseViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<AnyHashable, StoreMessage>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<AnyHashable, StoreMessage>
    
    // MARK: - IBOutlets
    @IBOutlet var collectionView: UICollectionView!
    
    // MARK: - Properties
    private let requestManager = RequestsManager()
    private var context: AccountContext
    private lazy var dataSource = makeDataSource()
    private var storeMessages: [StoreMessage] = [] {
        didSet {
            _ = context.account.postbox.transaction { [weak self] transaction in
                guard let self else { return }
                
                _ = transaction.addMessages(storeMessages, location: .Random)
            }.start(completed: { [weak self] in
                self?.createSnapshot()
            })
            
        }
    }
    private var channels: [ElloAppChannel] = []
    
    var showChatControllerHandler: ((_ channelPeerId: PeerId, _ engineMessageId: EngineMessage.Id) -> Void)?
    
    // MARK: - Life cycle
    required init?(coder: NSCoder, context: AccountContext) {
        self.context = context
        
        super.init(coder: coder)
    }
    
    @available(*, unavailable, renamed: "init(coder:context:)")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()

        getMedia()
    }
    
    // MARK: - Set up
    private func configureCollectionView() {
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createCollectionViewLayout()
    }
    
    // MARK: - IBActions
    
    // MARK: - Actions
    private func makeDataSource() -> DataSource {
        DataSource(collectionView: collectionView) { [weak context] collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FeedExploreCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? FeedExploreCollectionViewCell
            
            if let context {
                cell?.configure(with: item, context: context)
            }
            
            return cell
        }
    }
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, environment -> NSCollectionLayoutSection in
            let width = environment.container.effectiveContentSize.width
            
            let spacing = 3.0
            let itemsCountInGroup = 3
            let commonItemsSpacing = Double((itemsCountInGroup - 1)) * spacing
            let itemWidth = (width - commonItemsSpacing) / Double(itemsCountInGroup)
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(itemWidth),
                heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(1.0 / 3.0))
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                repeatingSubitem: item,
                count: itemsCountInGroup
            )
            group.interItemSpacing = .fixed(spacing)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = .init(top: 10.0, leading: 0.0, bottom: 0.0, trailing: 0.0)
            
            return section
        }
    }
    
    private func createSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(storeMessages, toSection: 0)
        dataSource.apply(snapshot)
    }
    
    // MARK: - Network Manager calls
    private func getMedia(page: Int = 0, limit: Int = RequestsManager.feedPageLimit, onFeedFetched: VoidClosure? = nil) {
        requestManager.getFeed(with: context, page: page, limit: limit, isFeedExplore: true) { [weak self] responseFeed in
            switch responseFeed {
            case .feedMessages(let messages, let chats):
                let history = FeedHistory()
                self?.storeMessages = messages.compactMap(history.parse)
                self?.channels = chats.compactMap { history.parse(chat: $0) as? ElloAppChannel }
            }
        }
    }
}

// MARK: - UICollectionViewDelegate
extension FeedExploreViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let storeMessageId = dataSource.itemIdentifier(for: indexPath)?.id else { return }
        guard case .Id(let messageId) = storeMessageId else { return }
        
        showChatControllerHandler?(messageId.peerId, messageId)
    }
}

