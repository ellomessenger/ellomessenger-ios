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
import ContextUI
import PeerInfoUI

class FeedRootViewController: BaseViewController {
    // MARK: - IBOutlets
    @IBOutlet private weak var titleL: UILabel?
    
    @IBOutlet private weak var emptyView: UIView?
    @IBOutlet private weak var emptyTitleL: UILabel?
    @IBOutlet private weak var emptyDescrL: UILabel?
    @IBOutlet private weak var emptyStartButton: UIButton?
    @IBOutlet private weak var notificationView: FeedNotificationView!
    @IBOutlet private weak var forMeContainerView: UIView!
    @IBOutlet private weak var exploreContainerView: UIView!
    @IBOutlet private weak var recomendedContainerView: UIView!
    @IBOutlet private weak var segmentedView: FeedSegmentedView!
    @IBOutlet private weak var forMeBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var exploreBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var recommendedBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var searchView: UIView!
    
    // MARK: - Properties
    var onStart: (() -> Void)?
    var onSearch: EventClosure<String>?
    var onSettings: ((_ context: AccountContext, _ filterItem: FeedFilterItem, _ onUpdateFiltersHandler: @escaping EventClosure<FeedFilterItem>) -> Void)?
    
    private var presentationData: PresentationData {
        context.sharedContext.currentPresentationData.with { $0 }
    }
    private let messagesManager = MessagesManager()
    private let requestManager = RequestsManager()
    var effectiveNavigationController: (() -> UINavigationController?)?
    
    var getAdoptViewController: (() -> ViewController)?
    
    private let actionDisposable = MetaDisposable()
    private let notificationMessagesDisposable = MetaDisposable()
    var context: AccountContext!
    var containerViewLayout: ContainerViewLayout? {
        didSet {
            guard let adoptController = getAdoptViewController?(),
                  let parentController = adoptController.parent as? TabBarController
            else {
                return
            }
            
            forMeBottomConstraint.constant = parentController.tabBarHeight
            exploreBottomConstraint.constant = parentController.tabBarHeight
            recommendedBottomConstraint.constant = parentController.tabBarHeight
        }
    }
    
    private var feedItems: [FeedRootItem] = [] {
        didSet {
//            emptyView?.isHidden = !feedItems.isEmpty
//            tableView.isHidden = feedItems.isEmpty
//            tableView.reloadData()//reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    private var feed: [Api.Feeds] = []
    
    private lazy var forMeFeedController: FeedForMeViewController? = {
        let controller = storyboard?
            .instantiateViewController(withIdentifier: "FeedForMeViewController") as? FeedForMeViewController
        controller?.context = context
        controller?.getAdoptViewController = getAdoptViewController
        controller?.showPeerInfo = showPeerInfo(peer:)
        controller?.onHideTapHandle = hideChannel(id:)
        controller?.onReportTapHandle = openReport(messageId:)
        controller?.showChatControllerHandler = showChatController(channelPeerId: messageId:)
        controller?.showMessageRepliesController = showMessageRepliesController(peer: messageId:)
        controller?.onLikeTapHandle = onLikeTapHandle(messageId:addLike:)
        controller?.onFetchFeedHandle = { [weak self] page in
            self?.getFeed(page: page)
        }
        
        return controller
    }()
    
    private lazy var recomendedFeedController: FeedRecomendedViewController? = {
        let controller = storyboard?
            .instantiateViewController(withIdentifier: "FeedRecomendedViewController") as? FeedRecomendedViewController
        controller?.context = context
//        controller?.getAdoptViewController = getAdoptViewController
//        controller?.showPeerInfo = showPeerInfo(peer:)
//        controller?.onHideTapHandle = hideChannel(id:)
//        controller?.onReportTapHandle = openReport(messageId:)
        controller?.showChatControllerHandler = showChatController(channelPeerId:)
//        controller?.showMessageRepliesController = showMessageRepliesController(peer: messageId:)
//        controller?.onLikeTapHandle = onLikeTapHandle(messageId:addLike:)
//        controller?.onFetchFeedHandle = { [weak self] page in
//            self?.getFeed(page: page)
//        }
        
        return controller
    }()
    
    private lazy var exploreFeedController: FeedExploreViewController? = {
        let controller = storyboard?.instantiateViewController(
            identifier: "FeedExploreViewController"
        ) { [weak self] coder -> FeedExploreViewController? in
                guard let self else { return nil }
                
                return FeedExploreViewController(coder: coder, context: self.context)
            }
        controller?.showChatControllerHandler = showChatController(channelPeerId: messageId:)
        
        return controller
    }()
    
    private var filterItem = FeedFilterItem()
    
    // MARK: - Lifecycle
    override func localize() {
        let bundle = Bundle(for: Self.self)
        
        titleL?.text = "feed".localized
        emptyTitleL?.text = Localization.myFeed.localized(bundle)
        emptyDescrL?.text = Localization.myFeedDescription.localized(bundle)
        emptyStartButton?.setTitle(Localization.start.localized(bundle), for: .normal)
    }
    
    override func storyboardName() -> String {
        return "ELFeedUI"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationMessagesDisposable.set(
            (context.account.stateManager.notificationMessages
             |> mapToSignal { messageList -> Signal<[([Message], PeerGroupId, Bool)], NoError> in
                 let messageList: [([Message], PeerGroupId, Bool)] = messageList.compactMap { (messages, peerGroupId, notify) in
                     let messages: [Message] = messages.filter { message in
                         message.peers.contains { _, peer in peer is ElloAppChannel }
                     }
                     
                     return (messages, peerGroupId, notify)
                 }
                 
                 return .single(messageList)
             }
             |> deliverOn(Queue.mainQueue())).start(next: { [weak self] messageList in
                 guard let self else {
                     return
                 }
                 if messageList.isEmpty {
                     return
                 }
                 
                 let peers: [Peer] = messageList.flatMap { messages, _, _ in
                     let peers: [Peer] = messages.flatMap { message in
                         message.peers.compactMap {
                             guard let channel = $0.1 as? ElloAppChannel else {
                                 return nil
                             }
                             
                             return channel
                         }
                     }
                     
                     return peers
                 }
                 
                 if (self.forMeFeedController?.isFeedScrollOnTop ?? false) {
                     self.getFeed()
                 } else {
                     self.notificationView.updateLayout(context: self.context, presentationData: self.presentationData, channels: peers)
                     self.notificationView.show()
                 }
             })
        )
        
        if let forMeFeedController {
            add(forMeFeedController, containerView: forMeContainerView)
        }
        
        if let exploreFeedController {
            add(exploreFeedController, containerView: exploreContainerView)
        }
        
        if let recomendedFeedController {
            add(recomendedFeedController, containerView: recomendedContainerView)
        }
        
        segmentedView.forMeControlTappedHandler = { [weak self] in
            self?.forMeContainerView.isHidden = false
            self?.exploreContainerView.isHidden = true
            self?.recomendedContainerView.isHidden = true
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                self?.searchView.alpha = 0.0
                self?.searchBar.alpha = 0.0
            }
        }
        
        segmentedView.exploreControlTappedHandler = { [weak self] in
            self?.forMeContainerView.isHidden = true
            self?.exploreContainerView.isHidden = false
            self?.recomendedContainerView.isHidden = true
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                self?.searchView.alpha = 0.0
                self?.searchBar.alpha = 0.0
            }
            
        }
        
        segmentedView.recomendedTappedHandler = { [weak self] in
            self?.forMeContainerView.isHidden = true
            self?.exploreContainerView.isHidden = true
            self?.recomendedContainerView.isHidden = false
            
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                if self?.searchBar.text?.isEmpty == false {
                    self?.searchBar.alpha = 1.0
                } else {
                    self?.searchView.alpha = 1.0
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getFilters()
        getFeed()
    }

    // MARK: - Actions
    private func preloadImage(_ media: ElloAppMediaImage) {
        let actionDisposable = MetaDisposable()
        actionDisposable.set(
            chatMessagePhotoInteractiveFetched(
                context: context,
                photoReference: .standalone(media: media),
                displayAtSize: nil,
                storeToDownloadsPeerType: nil
            ).start()
        )
    }
    
    private func preloadeVideo(_ media: ElloAppMediaFile) {
        let actionDisposable = MetaDisposable()
        actionDisposable.set(
            mediaGridMessageVideo(postbox: context.account.postbox, videoReference: .standalone(media: media), autoFetchFullSizeThumbnail: true
            ).start()
        )
    }
    
    func openRecomendedTab() {
        segmentedView.recomendedControl.sendActions(for: .touchUpInside)
    }
    
    // MARK: - IBActions
    @IBAction private func startBtnDidTap(_ sender: AnyObject?) {
        getFeed() { [weak self] in
            DispatchQueue.main.async {
                self?.forMeFeedController?.collectionView.setContentOffset(.zero, animated: true)
            }
        }
    }
    
    @IBAction private func settingsBtnDidTap(_ sender: AnyObject?) {
        onSettings?(context, filterItem, updateFilters(filterItem:))
    }
    
    @IBAction private func searchBtnDidTap(_ sender: AnyObject?) {
        UIView.animate(withDuration: CATransaction.animationDuration()) {
            self.searchBar.alpha = 1.0
            self.searchView.alpha = 0.0
        }
        searchBar.becomeFirstResponder()
    }
    
    // MARK: - Navigation
    private func showPeerInfo(peer: ElloAppChannel) {
        let infoController = context.sharedContext.makePeerInfoController(
            context: context,
            updatedPresentationData: (presentationData, Promise<PresentationData>().get()),
            peer: peer,
            mode: .generic,
            avatarInitiallyExpanded: false,
            fromChat: false,
            requestsContext: context.engine.peers.peerInvitationImporters(
                peerId: peer.id,
                subject: .requests(query: nil)
            )
        )
        
        if let infoController {
            effectiveNavigationController?()?.pushViewController(infoController, animated: true)
        }
    }
    
    private func showChatController(channelPeerId: PeerId) {
        showChatController(channelPeerId: channelPeerId, subject: nil)
    }
    
    private func showChatController(channelPeerId: PeerId, messageId: EngineMessage.Id) {
        let subject = ChatControllerSubject.message(id: .id(messageId), highlight: true, timecode: nil)
        showChatController(channelPeerId: channelPeerId, subject: subject)
    }
    
    private func showChatController(channelPeerId: PeerId, subject: ChatControllerSubject?) {
        guard let navigationController = (effectiveNavigationController?() as? NavigationController) else { return }
        
        let navigationParams = NavigateToChatControllerParams(
            navigationController: navigationController,
            context: context,
            chatLocation: .peer(id: channelPeerId),
            subject: subject
        )
        context.sharedContext.navigateToChatController(navigationParams)
    }
    
    private func showMessageRepliesController(peer: ElloAppChannel, messageId: EngineMessage.Id) {
        guard let navigationController = (effectiveNavigationController?() as? NavigationController) else { return }
        
        _ = (ChatControllerImpl.openMessageReplies(
            context: context,
            updatedPresentationData: (presentationData, Promise<PresentationData>().get()),
            navigationController: navigationController,
            present: { _,_ in },
            messageId: messageId,
            isChannelPost: true,
            atMessage: nil,
            displayModalProgress: false
        )).start()
    }
    
    private func openReport(messageId: MessageId) {
        guard let topController = getAdoptViewController?() else {
            return
        }
        
        let options: [PeerReportOption] = [
            .spam,
            .violence,
            .pornography,
            .childAbuse,
            .copyright,
            .illegalDrugs,
            .personalDetails,
            .other
        ]
        
        presentPeerReportOptions(
            context: context,
            parent: topController,
            contextController: nil,
            subject: .messages([messageId]),
            options: options,
            completion: { _, _ in }
        )
    }
    
    // MARK: - Network
    private func hideChannel(id: Int64) {
        if filterItem.hidden.contains(Int(id)) { return }
        
        filterItem.hidden.append(Int(id))
        updateFilters(filterItem: filterItem)
    }
    
    private func getFilters() {
        requestManager.getFilters(with: context) { [weak self] filters in
            self?.filterItem = FeedFilterItem(responseObject: filters)
        }
    }
    
    private func onLikeTapHandle(messageId: MessageId, addLike: Bool) {
        Task {
            let status: LikesStatusItem?
            if addLike {
                status = try? await requestManager.addLike(with: context, messageId: Int(messageId.id), peerId: messageId.peerId.id._internalGetInt64Value())
            } else {
                status = try? await requestManager.removeLike(with: context, messageId: Int(messageId.id), peerId: messageId.peerId.id._internalGetInt64Value())
            }
            
            if status?.status == "success" {
                let page = if let messageIndex = self.feedItems.firstIndex(where: { $0.messageId == messageId }) {
                    messageIndex / RequestsManager.feedPageLimit
                } else {
                    0
                }
                
                getFeed(page: page)
            }
        }
    }
    
    private func updateFilters(filterItem: FeedFilterItem) {
        requestManager.updateFilters(with: context, item: filterItem) { [weak self] response in
            if response.status {
                self?.getFilters()
                self?.getFeed()
            }
        }
    }
}

// MARK: - Localization
private enum Localization: String {
    case feed
    case myFeed
    case myFeedDescription
    case start
}

// MARK: - API
private extension FeedRootViewController {
    func getFeed(hideNotificationView: Bool = true, page: Int = 0, limit: Int = RequestsManager.feedPageLimit, onFeedFetched: VoidClosure? = nil) {
        requestManager.getFeed(with: context, page: page, limit: limit) { [weak self] responseFeed in
            if page == 0 { self?.feedItems = [] }
            
            if self?.feed.count ?? 0 <= page {
                self?.feed.append(responseFeed)
            } else {
                self?.feed[page] = responseFeed
            }
            
            var apiMessage: [Api.Message] = []
            var apiChat: [Api.Chat] = []
            if let feed = self?.feed {
                apiMessage = feed.flatMap { feeds -> [Api.Message] in
                    guard case let .feedMessages(messages, _) = feeds else { return [] }
                    return messages
                }
                
                apiChat = feed.flatMap { feeds -> [Api.Chat] in
                    guard case let .feedMessages(_, chats) = feeds else { return [] }
                    return chats
                }
            }
            let combinedFeed = Api.Feeds.feedMessages(messages: apiMessage, chats: apiChat)
            
            self?.feedItems = self?.messagesManager.feedItems(from: combinedFeed) ?? []
            self?.messagesManager.loadMessages(postbox: self?.context.account.postbox)
            self?.forMeFeedController?.feedItems = self?.feedItems ?? []
            
            onFeedFetched?()
        }
        
        if hideNotificationView && page == 0 {
            notificationView.hide()
        }
    }
}

extension FeedRootViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count >= 3 {
            recomendedFeedController?.searchChannelDidChange(text: searchText)
        } else {
            recomendedFeedController?.searchChannelDidChange(text: "")
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: CATransaction.animationDuration()) {
            searchBar.alpha = 0.0
            self.searchView.alpha = 1.0
        }
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        recomendedFeedController?.searchChannelDidChange(text: "")
    }
}
