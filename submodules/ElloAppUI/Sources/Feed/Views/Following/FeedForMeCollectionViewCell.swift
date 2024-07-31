//
//  FeedRootTableViewCell.swift
//  _idx_ELFeedUI_DAE05111_ios_min13.0
//
//

import UIKit
import ElloAppApi
import ElloAppCore
import AvatarNode
import AccountContext
import ElloAppPresentationData
import Postbox
import SwiftSignalKit
import Display
import ELBase

class SelfSizingCollectionView: UICollectionView {
    override var contentSize: CGSize{
        didSet {
            if oldValue.height != self.collectionViewLayout.collectionViewContentSize.height {
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: collectionViewLayout.collectionViewContentSize.height)
    }
}

class BackgroundSupplementaryView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let imageView = UIImageView(image: UIImage(named: "feed_message_tail_in"))
        imageView.frame = bounds
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FeedForMeCollectionViewCell: UICollectionViewCell {
    // MARK: - IBOutlets
    
    // Avatar block
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var payTypeImageView: UIImageView!
    @IBOutlet var adultImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var userNameLabel: UIButton!
    @IBOutlet var verifiedImageView: UIImageView!
    
    // Text
    @IBOutlet var messageTextView: UITextView! {
        didSet {
            messageTextView.textContainer.lineFragmentPadding = .zero
            messageTextView.textContainerInset = .zero
            messageTextView.contentInset = .zero
        }
    }
    
    // Collection view content block
    @IBOutlet var sliderLabelContainerView: UIView!
    @IBOutlet var sliderLabel: UILabel!
    @IBOutlet var collectionView: SelfSizingCollectionView!
    @IBOutlet var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var actionsButton: UIButton!
    
    // Social block
    @IBOutlet var viewsCountLabel: UILabel!
    @IBOutlet var reactionsCount: UILabel!
    @IBOutlet var reactionContainerView: UIControl!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var commentsStackView: UIStackView!
    @IBOutlet var commentsButton: UIButton!
    @IBOutlet var commentsAvatarsStackView: UIStackView!
    
    // MARK: - Properties
    private let avatarNode = AvatarNode(font: avatarPlaceholderFont(size: 14.0))
    private var context: AccountContext!
    private var presentationData: PresentationData {
        context.sharedContext.currentPresentationData.with { $0 }
    }
    private var feedContentManager: FeedContentManager!
    private var feedRootItem: FeedRootItem?
    private lazy var dataSource: DataSource = makeDataSource()
    var showPeerInfoHandler: ((_ peer: ElloAppChannel) -> Void)?
    var onHideTapHandle: EventClosure<Int64>?
    var onReportTapHandle: EventClosure<MessageId>?
    var showMessageRepliesController: ((_ peer: ElloAppChannel, _ engineMessageId: EngineMessage.Id) -> Void)?
    
    /// - Parameters:
    ///     - MessageId:  MessageId to like
    ///     - Bool: Add like or remove
    var onLikeTapHandle: TwoEventsClosure<MessageId, Bool>?
    
    private var menuItems: [UIAction] {
        guard let channel = feedRootItem?.channel else { return [] }
        guard let messageId = feedRootItem?.messageId else { return [] }
        
        return [
            UIAction(
                title: presentationData.strings.Feed_HideChannel,
                image: UIImage(named: "feed_action-menu_hide")
            ) { [weak self] _ in
                self?.onHideTapHandle?(channel.id.id._internalGetInt64Value())
            },
            UIAction(
                title: presentationData.strings.Report_Report,
                image: UIImage(named: "feed_action-menu_error")
            ) { [weak self] _ in
                self?.onReportTapHandle?(messageId)
            },
        ]
    }
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.addSubnode(avatarNode)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarNode.frame = avatarImageView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        collectionView.isUserInteractionEnabled = true
        collectionView.cornerRadius = 12.0
    }
    
    // MARK: - Additional Methods
    private func configureAvatar() {
        guard let channel = feedRootItem?.channel else { return }
        
        avatarNode.setPeer(context: context, theme: presentationData.theme, peer: EnginePeer(channel))
    }
    
    private func configureHeaderData() {
        guard let channel = feedRootItem?.channel else { return }
        
        switch channel.payType {
        case .free:
            payTypeImageView.image = nil
        case .onlineCourse:
            payTypeImageView.image = UIImage(named: "Chat List/PaidChannel/OnlineCourseIcon")
        case .subscription:
            payTypeImageView.image = UIImage(named: "Chat List/PaidChannel/SubscriptionIcon")
        }
        
        payTypeImageView.isHidden = payTypeImageView.image == nil
        adultImageView.isHidden = !channel.isAdult
        verifiedImageView.isHidden = !channel.flags.contains(.isVerified)
        
        titleLabel.text = channel.title
        let channelUserName = String(format: "@%@", channel.username ?? "")
        userNameLabel.setTitle(channelUserName, for: .normal)
    }
    
    private func configurePageControl() {
        guard let feedContentManager else { return }
        
        pageControl.numberOfPages = feedContentManager.feedTypes.count
        pageControl.isHidden = !needShowPageControl()
    }
    
    private func configureFooterData() {
        guard let feedRootItem else { return }
        
        viewsCountLabel.isHidden = feedRootItem.views == 0
        viewsCountLabel.text = String(feedRootItem.views)
        reactionsCount.text = String(feedRootItem.reactions)
        reactionContainerView.backgroundColor = feedRootItem.isLiked ? UIColor(named: "Blue", in: Bundle(for: Self.self), compatibleWith: nil) : .white
        reactionContainerView.borderColor = feedRootItem.isLiked
        ? .black.withAlphaComponent(0.2)
        : .black.withAlphaComponent(0.05)
        reactionsCount.textColor = feedRootItem.isLiked ? .white : UIColor(named: "TextDark")
        
        let date = Date(timeIntervalSince1970: TimeInterval(feedRootItem.timestamp))
        if date.isToday {
            dateLabel.text = date.toString(dateFormat: .hma)
        } else {
            dateLabel.text = date.toString(dateFormat: .MMMddyyyy)
        }
        
        commentsStackView.arrangedSubviews.forEach({ $0.isHidden = feedRootItem.replyAttribute == nil })
        let commentsCount = feedRootItem.replyAttribute?.count ?? 0
        let commentsTitle = commentsCount > 0
        ? presentationData.strings.Feed_LeaveComments(commentsCount)
        : presentationData.strings.Feed_LeaveComment
        commentsButton.setTitle(commentsTitle, for: .normal)
        
        fillCommentAvatars(with: feedRootItem)
    }
    
    private func fillCommentAvatars(with feedRootItem: FeedRootItem) {
        let isEmptyCommenators = feedRootItem.replyAttribute?.latestUsers.isEmpty ?? true
        if isEmptyCommenators {
            commentsAvatarsStackView.arrangedSubviews.enumerated().forEach { index, imageView in
                let imageView = imageView as? UIImageView
                if index == 0 {
                    imageView?.isHidden = false
                    imageView?.image = UIImage(named: "Chat/Message/BubbleComments")
                } else {
                    imageView?.isHidden = true
                }
            }
            
            return
        }
        
        _ = (context.account.postbox.transaction { transaction -> [Peer] in
            feedRootItem.replyAttribute?.latestUsers.compactMap { transaction.getPeer($0) } ?? [Peer]()
        }
             |> deliverOnMainQueue
        ).start(next: { [weak self] peers in
            self?.commentsAvatarsStackView.arrangedSubviews.enumerated().forEach { index, imageView in
                guard let context = self?.context else { return }
                guard let imageView = imageView as? UIImageView else { return }
                guard
                    let commentPeer = peers[safe: index]
                else {
                    imageView.isHidden = true
                    return
                }
                
                imageView.isHidden = false
                
                let avatarNode = AvatarNode(font: avatarPlaceholderFont(size: 12.0))
                avatarNode.bounds = imageView.bounds
                
                _ = avatarNode.imageNode.ready.start { [peerId = commentPeer.id] _ in
                    guard peerId == self?.feedRootItem?.replyAttribute?.latestUsers[safe: index] else { return }
                    
                    imageView.image = avatarNode.unroundedImage
                    if imageView.image == nil {
                        imageView.subviews.forEach { $0.removeFromSuperview() }
                        imageView.addSubviewWithSameSize(avatarNode.view)
                    }
                }
                
                avatarNode.setPeer(context: context, peer: EnginePeer(commentPeer))
            }
        })
    }
    
    func configure(with item: FeedRootItem, context: AccountContext, feedContentManager: FeedContentManager) {
        self.context = context
        self.feedRootItem = item
        self.feedContentManager = feedContentManager
        
        reactionContainerView.isUserInteractionEnabled = true
        
        configureAvatar()
        configureHeaderData()
        configureCollectionView()
        configureButtonMenu()
        
        messageTextView.text = item.text
        messageTextView.isHidden = item.text.isEmpty
        
        configurePageControl()
        configureSlider()
        configureFooterData()
        
        if collectionView.superview?.isHidden ?? true {
            return
        }
        // Костыль, если значение не пересчиталось и estimatedSize остался 1 - не обновляем датасорс
        if collectionView.intrinsicContentSize.height == 1 {
            return
        }
        
        createSnapshot()
        collectionViewHeightConstraint.constant = collectionView.intrinsicContentSize.height
    }
    
    private func needShowPageControl() -> Bool {
        guard let feedContentManager else {
            return false
        }
        
        if case .image = feedContentManager.feedTypes.first, feedContentManager.feedTypes.count > 1 {
            return true
        } else {
            return false
        }
    }
    
    private func configureSlider() {
        sliderLabelContainerView.isHidden = pageControl.isHidden
        sliderLabel.text = "\(pageControl.currentPage + 1) / \(pageControl.numberOfPages)"
    }
    
    private func configureButtonMenu() {
        actionsButton.menu = UIMenu(children: menuItems)
        actionsButton.showsMenuAsPrimaryAction = true
    }
    
    // MARK: IBActions
    @IBAction func userNameButtonTapped(_ sender: Any) {
        guard let channel = feedRootItem?.channel else { return }
        
        showPeerInfoHandler?(channel)
    }
    
    @IBAction func commentsButtonTapped(_ sender: Any) {
        guard let feedRootItem else { return }
        guard let channel = feedRootItem.channel else { return }
        guard let messageId = feedRootItem.messageId else { return }
        
        showMessageRepliesController?(channel, messageId)
    }
    @IBAction func likeTapped(_ sender: Any) {
        guard let feedRootItem = feedRootItem else { return }
        guard let messageId = feedRootItem.messageId else { return }
        
        reactionContainerView.isUserInteractionEnabled = false
        onLikeTapHandle?(messageId, !feedRootItem.isLiked)
        
        self.feedRootItem?.isLiked.toggle()
        if self.feedRootItem?.isLiked == true {
            self.feedRootItem?.reactions += 1
        } else {
            self.feedRootItem?.reactions -= 1
        }
        configureFooterData()
    }
}

// MARK: - CollectionView Data
extension FeedForMeCollectionViewCell {
    private typealias DataSource = UICollectionViewDiffableDataSource<AnyHashable, FeedContentManager.FeedType>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<AnyHashable, FeedContentManager.FeedType>
    
    private func makeDataSource() -> DataSource {
        DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: item.cellIdentifier,
                for: indexPath
            )
            
            switch item {
            case .image(_, arguments: let arguments):
                if let cell = cell as? FeedRootMediaCollectionViewCell {
                    cell.configure(with: item, media: arguments.media)
                }
            case .video(_, arguments: let arguments):
                if let cell = cell as? FeedRootVideoCollectionViewCell {
                    cell.configure(with: item, media: arguments.media)
                }
//                collectionView.isUserInteractionEnabled = false
            case .audio:
                if let cell = cell as? FeedRootAudioCollectionViewCell {
                    cell.configure(with: item)
                }
            case .file:
                if let cell = cell as? FeedRootFileCollectionViewCell {
                    cell.configure(with: item)
                }
            case .map:
                if let cell = cell as? FeedRootMapCollectionViewCell {
                    cell.configure(with: item)
                }
            case .liveMap:
                if let cell = cell as? FeedRootLiveMapCollectionViewCell {
                    cell.configure(with: item)
                }
            case .webPage(arguments: let arguments, feedType: let feedType):
                if let cell = cell as? FeedRootWebPageCollectionViewCell {
                    cell.configure(with: arguments, feedType: feedType)
                }
                collectionView.cornerRadius = 0.0
            }

            return cell
        }
    }
    
    private func configureCollectionView() {
        if let feedRootItem {
            collectionView.superview?.isHidden = feedRootItem.media.isEmpty || feedContentManager.feedTypes.isEmpty
        } else {
            collectionView.superview?.isHidden = true
        }
        
        if collectionView.superview?.isHidden ?? true {
            return
        }
        
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createCollectionViewLayout()
        layoutIfNeeded()
    }
    
    func createCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(1.0)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = interGroupSpacing()
        section.visibleItemsInvalidationHandler = { [weak self] (items, offset, env) -> Void in
            guard let self else { return }
            
            let page = Int(round(offset.x / collectionView.bounds.width))
            if page != pageControl.currentPage {
                pageControl.currentPage = page
                configureSlider()
            }
        }
        section.orthogonalScrollingBehavior = scrollingBehavior()
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func scrollingBehavior() -> UICollectionLayoutSectionOrthogonalScrollingBehavior {
        switch feedContentManager.feedTypes.first {
        case .image, .video: return .paging
        default: return .none
        }
    }
    
    private func interGroupSpacing() -> CGFloat {
        switch feedContentManager.feedTypes.first {
        case .image, .video: return 0.0
        default: return 12.0
        }
    }
    
    func createSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(feedContentManager.feedTypes, toSection: 0)
        dataSource.apply(snapshot) { [id = feedRootItem?.messageId?.id, weak self] in
            guard let self else { return }
            if self.feedRootItem?.messageId?.id != id { return }
            
            Task {
                self.collectionViewHeightConstraint.constant = self.collectionView.intrinsicContentSize.height
            }
        }
    }
}

extension FeedForMeCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let feedItem = feedContentManager?.feedTypes[indexPath.row] else {
            return
        }
        switch feedItem {
        case .map(_, arguments: let item):
            item.openFile()
        case .liveMap(_, arguments: let item):
            item.openFile()
        case .image(_, arguments: let item):
            item.openFile()
        case .video(_, arguments: let item):
            item.openFile()
        default:
            break
        }
    }
}

extension FeedForMeCollectionViewCell: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        if(!NSEqualRanges(textView.selectedRange, NSMakeRange(0, 0))) {
            textView.selectedRange = NSMakeRange (0, 0);
        }
    }
}
