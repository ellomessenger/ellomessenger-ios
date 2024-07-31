import Foundation
import UIKit
import Display
import AsyncDisplayKit
import Postbox
import SwiftSignalKit
import ElloAppCore
import ElloAppPresentationData
import AccountContext
import AlertUI
import PresentationDataUtils
import SearchUI
import ElloAppPermissionsUI
import AppBundle
import DeviceAccess
import PeerInfoUI
import ELBase

public class ComposeControllerImpl: ViewController, ComposeController {
    private let context: AccountContext
    
    private var contactsNode: ComposeControllerNode {
        return self.displayNode as! ComposeControllerNode
    }
    
    private let index: PeerNameIndex = .lastNameFirst
    
    private var _ready = Promise<Bool>()
    override public var ready: Promise<Bool> {
        return self._ready
    }
    
    private let createActionDisposable = MetaDisposable()
    
    private var presentationData: PresentationData
    private var presentationDataDisposable: Disposable?
    
    private var searchContentNode: NavigationBarSearchContentNode?
    
    public init(context: AccountContext) {
        self.context = context
        
        self.presentationData = context.sharedContext.currentPresentationData.with { $0 }
        
        super.init(navigationBarPresentationData: NavigationBarPresentationData(presentationData: self.presentationData))
        
        self.navigationPresentation = .modal
        
        self.statusBar.statusBarStyle = self.presentationData.theme.rootController.statusBarStyle.style
        
        self.title = self.presentationData.strings.Compose_NewMessage
                
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: self.presentationData.strings.Common_Back, style: .plain, target: nil, action: nil)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: self.presentationData.strings.Common_Cancel, style: .plain, target: self, action: #selector(cancelPressed))
        
        self.scrollToTop = { [weak self] in
            if let strongSelf = self {
                if let searchContentNode = strongSelf.searchContentNode {
                    searchContentNode.updateExpansionProgress(1.0, animated: true)
                }
                strongSelf.contactsNode.contactListNode.scrollToTop()
            }
        }
        
        self.presentationDataDisposable = (context.sharedContext.presentationData
        |> deliverOnMainQueue).start(next: { [weak self] presentationData in
            if let strongSelf = self {
                let previousTheme = strongSelf.presentationData.theme
                let previousStrings = strongSelf.presentationData.strings
                
                strongSelf.presentationData = presentationData
                
                if previousTheme !== presentationData.theme || previousStrings !== presentationData.strings {
                    strongSelf.updateThemeAndStrings()
                }
            }
        })
        
        self.searchContentNode = NavigationBarSearchContentNode(theme: self.presentationData.theme, placeholder: self.presentationData.strings.Common_Search, activate: { [weak self] in
            self?.activateSearch()
        })
        self.navigationBar?.setContentNode(self.searchContentNode, animated: false)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.createActionDisposable.dispose()
        self.presentationDataDisposable?.dispose()
    }
    
    private func updateThemeAndStrings() {
        self.statusBar.statusBarStyle = self.presentationData.theme.rootController.statusBarStyle.style
        self.navigationBar?.updatePresentationData(NavigationBarPresentationData(presentationData: self.presentationData))
        self.searchContentNode?.updateThemeAndPlaceholder(theme: self.presentationData.theme, placeholder: self.presentationData.strings.Common_Search)
        self.title = self.presentationData.strings.Compose_NewMessage
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: self.presentationData.strings.Common_Back, style: .plain, target: nil, action: nil)
    }
    
    override public func loadDisplayNode() {
        self.displayNode = ComposeControllerNode(context: self.context)
        self._ready.set(self.contactsNode.contactListNode.ready)
        
        self.contactsNode.navigationBar = self.navigationBar
        
        self.contactsNode.requestDeactivateSearch = { [weak self] in
            self?.deactivateSearch()
        }
        
        self.contactsNode.requestOpenPeerFromSearch = { [weak self] peerId in
            self?.openPeer(peerId: peerId)
        }
        
        self.contactsNode.contactListNode.activateSearch = { [weak self] in
            self?.activateSearch()
        }
        
        self.contactsNode.contactListNode.openPeer = { [weak self] peer, _ in
            if case let .peer(peer, _, _) = peer {
                self?.openPeer(peerId: peer.id)
            }
        }

        self.contactsNode.openCreateNewGroup = { [weak self] in
            if let strongSelf = self {
                let controller = strongSelf.context.sharedContext.makeContactMultiselectionController(ContactMultiselectionControllerParams(context: strongSelf.context, mode: .groupCreation, options: []))
                (strongSelf.navigationController as? NavigationController)?.pushViewController(controller, completion: { [weak self] in
                    if let strongSelf = self {
                        strongSelf.contactsNode.contactListNode.listNode.clearHighlightAnimated(true)
                    }
                })
                strongSelf.createActionDisposable.set((controller.result
                |> deliverOnMainQueue).start(next: { [weak controller] result in
                    var peerIds: [ContactListPeerId] = []
                    if case let .result(peerIdsValue, _) = result {
                        peerIds = peerIdsValue
                    }
                    
                    if let strongSelf = self, let controller = controller {
                        let createGroup = strongSelf.context.sharedContext.makeCreateGroupController(context: strongSelf.context, peerIds: peerIds.compactMap({ peerId in
                            if case let .peer(peerId) = peerId {
                                return peerId
                            } else {
                                return nil
                            }
                        }), initialTitle: nil, mode: .supergroup, completion: nil)
                        (controller.navigationController as? NavigationController)?.pushViewController(createGroup)
                    }
                }))
            }
        }
        
        self.contactsNode.openCreateNewSecretChat = { [weak self] in
            if let strongSelf = self {
                let controller = ContactSelectionControllerImpl(ContactSelectionControllerParams(context: strongSelf.context, autoDismiss: false, title: { $0.Compose_NewEncryptedChatTitle }))
                strongSelf.createActionDisposable.set((controller.result
                    |> take(1)
                    |> deliverOnMainQueue).start(next: { [weak controller] result in
                    if let strongSelf = self, let (contactPeers, _, _, _, _) = result, case let .peer(peer, _, _) = contactPeers.first {
                        controller?.dismissSearch()
                        controller?.displayNavigationActivity = true
                        strongSelf.createActionDisposable.set((strongSelf.context.engine.peers.createSecretChat(peerId: peer.id) |> deliverOnMainQueue).start(next: { peerId in
                            if let strongSelf = self, let controller = controller {
                                controller.displayNavigationActivity = false
                                (controller.navigationController as? NavigationController)?.replaceAllButRootController(ChatControllerImpl(context: strongSelf.context, chatLocation: .peer(id: peerId)), animated: true)
                            }
                        }, error: { error in
                            if let strongSelf = self, let controller = controller {
                                let presentationData = strongSelf.context.sharedContext.currentPresentationData.with { $0 }
                                controller.displayNavigationActivity = false
                                let text: String
                                switch error {
                                    case .limitExceeded:
                                        text = presentationData.strings.TwoStepAuth_FloodError
                                    default:
                                        text = presentationData.strings.Login_UnknownError
                                }
                                controller.present(textAlertController(context: strongSelf.context, title: nil, text: text, actions: [TextAlertAction(type: .defaultAction, title: presentationData.strings.Common_OK, action: {})]), in: .window(.root))
                            }
                        }))
                    }
                }))
                (strongSelf.navigationController as? NavigationController)?.pushViewController(controller, completion: { [weak self] in
                    if let strongSelf = self {
                        strongSelf.contactsNode.contactListNode.listNode.clearHighlightAnimated(true)
                    }
                })
            }
        }
        
        self.contactsNode.openCreateContact = { [weak self] in
            let _ = (DeviceAccess.authorizationStatus(subject: .contacts)
            |> take(1)
            |> deliverOnMainQueue).start(next: { status in
                guard let strongSelf = self else {
                    return
                }
                
                switch status {
                    case .allowed:
                        let contactData = DeviceContactExtendedData(basicData: DeviceContactBasicData(firstName: "", lastName: "", userNames: [DeviceContactUserNameData(label: "_$!<Mobile>!$_", value: "+")]), middleName: "", prefix: "", suffix: "", organization: "", jobTitle: "", department: "", emailAddresses: [], urls: [], addresses: [], birthdayDate: nil, socialProfiles: [], instantMessagingProfiles: [], note: "")
                        (strongSelf.navigationController as? NavigationController)?.pushViewController(strongSelf.context.sharedContext.makeDeviceContactInfoController(context: strongSelf.context, subject: .create(peer: nil, contactData: contactData, isSharing: false, shareViaException: false, completion: { peer, stableId, contactData in
                            guard let strongSelf = self else {
                                return
                            }
                            if let peer = peer {
                                DispatchQueue.main.async {
                                    if let navigationController = strongSelf.navigationController as? NavigationController {
                                        strongSelf.context.sharedContext.navigateToChatController(NavigateToChatControllerParams(navigationController: navigationController, context: strongSelf.context, chatLocation: .peer(id: peer.id)))
                                    }
                                }
                            } else {
                                (strongSelf.navigationController as? NavigationController)?.replaceAllButRootController(strongSelf.context.sharedContext.makeDeviceContactInfoController(context: strongSelf.context, subject: .vcard(nil, stableId, contactData), isTitleHidden: false, completed: nil, cancelled: nil), animated: true)
                            }
                        }), isTitleHidden: false, completed: nil, cancelled: nil))
                    case .notDetermined:
                        DeviceAccess.authorizeAccess(to: .contacts)
                    default:
                        let presentationData = strongSelf.presentationData
                        strongSelf.present(textAlertController(context: strongSelf.context, title: presentationData.strings.AccessDenied_Title, text: presentationData.strings.Contacts_AccessDeniedError, actions: [TextAlertAction(type: .defaultAction, title: presentationData.strings.Common_NotNow, action: {}), TextAlertAction(type: .genericAction, title: presentationData.strings.AccessDenied_Settings, action: {
                            self?.context.sharedContext.applicationBindings.openSettings()
                        })]), in: .window(.root))
                }
            })
        }
        
        self.contactsNode.openCreateNewChannel = { [weak self] in
            guard let self else { return }
//            let presentationData = strongSelf.context.sharedContext.currentPresentationData.with { $0 }
//                let controller = PermissionController(context: strongSelf.context, splashScreen: true)
//                controller.setState(.custom(icon: /*.animation("Channel")*/.image(nil), title: presentationData.strings.ChannelIntro_Title, subtitle: nil, text: presentationData.strings.ChannelIntro_Text, buttonTitle: presentationData.strings.ChannelIntro_CreateChannel, secondaryButtonTitle: nil, footerText: nil), animated: false)
//                controller.proceed = { [weak self] result in
//            if let strongSelf = self {
//                        (strongSelf.navigationController as? NavigationController)?.replaceTopController(createChannelController(context: strongSelf.context), animated: true)
            let peerId = PeerId(namespace: Namespaces.Peer.CloudChannel, id: PeerId.Id._internalFromInt64Value(0))
            let channelVisibilityController = channelVisibilityController(
                context: self.context,
                peerId: peerId,
                mode: .initialSetup,
                upgradedToSupergroup: { _, f in f()},
                onSelectionContactsNextTappedHandler: { navigationController, addressName, filteredPeerIds, payType in
                    switch payType {
                    case .subscription:
                        let subscriptionPriceController = SubscriptionChannelPriceController(context: self.context)
                        (self.navigationController as? NavigationController)?.pushViewController(subscriptionPriceController, animated: true)
                        let _ = (subscriptionPriceController.nextSignal
                                 |> deliverOnMainQueue).start { price in
                            navigationController.pushViewController(
                                createChannelController(
                                    context: self.context,
                                    on: navigationController,
                                    updatedAddressName: addressName,
                                    filteredPeerIds: filteredPeerIds,
                                    price: price,
                                    payType: .subscription
                                ),
                                animated: true
                            )
                        }
                    case .onlineCourse:
                        break
                    case .free:
                        navigationController.pushViewController(
                            createChannelController(
                                context: self.context,
                                on: navigationController,
                                updatedAddressName: addressName,
                                filteredPeerIds: filteredPeerIds,
                                payType: .free
                            ),
                            animated: true
                        )
                    }
                }
            )
            (self.navigationController as? NavigationController)?.replaceTopController(channelVisibilityController, animated: true)
//            }
//                }
//                (strongSelf.navigationController as? NavigationController)?.pushViewController(controller, completion: { [weak self] in
//                    if let strongSelf = self {
//                        strongSelf.contactsNode.contactListNode.listNode.clearHighlightAnimated(true)
//                    }
//                })
//            }
        }
        
        contactsNode.openCreateNewOnlineCourse = { [weak self] in
            guard let self else { return }
            
            let peerId = PeerId(namespace: Namespaces.Peer.CloudChannel, id: PeerId.Id._internalFromInt64Value(0))
            let channelVisibilityController = channelVisibilityController(
                context: self.context,
                peerId: peerId,
                mode: .initialSetupOnlineCourse,
                upgradedToSupergroup: { _, f in f()},
                onSelectionContactsNextTappedHandler: { navigationController, addressName, filteredPeerIds, isSubscriptionChannel in
                    let controller = OnlineCoursePriceViewController.controller(with: getAppBundle())
                    controller?.confirmHandled = { data in
                        var startDate: Int64?
                        if let startDateTimeInterval = data.startDate {
                            startDate = Int64(startDateTimeInterval)
                        }
                        
                        var endDate: Int64?
                        if let endDateTimeInterval = data.endDate {
                            endDate = Int64(endDateTimeInterval)
                        }
                        navigationController.pushViewController(
                            createChannelController(
                                context: self.context,
                                on: navigationController,
                                updatedAddressName: addressName,
                                filteredPeerIds: filteredPeerIds,
                                price: data.price,
                                payType: .onlineCourse,
                                startDate: startDate,
                                endDate: endDate
                            ),
                            animated: true
                        )
                    }
                    let adopt = AdaptingController(viewController: controller)
                    controller?.onTapBack = { [weak navigationController] in
                        _ = navigationController?.popViewController(animated: true)
                    }
                    navigationController.pushViewController(adopt)
                },
                onSelectionPrivateOrPublicChannelNextTappedHandler: { isPublicChannel, showContactsHandler in
                    let subscriptionController = CreateChannelDescriptionController(
                        context: self.context,
                        channelType: isPublicChannel ? .public : .private
                    )
                    (self.navigationController as? NavigationController)?.pushViewController(subscriptionController, animated: true)
                    let _ = (subscriptionController.nextSignal
                             |> deliverOnMainQueue).start { _ in
                        showContactsHandler?()
                    }
                }
            )
            (self.navigationController as? NavigationController)?.replaceTopController(channelVisibilityController, animated: true)
        }
        
        self.contactsNode.contactListNode.suppressPermissionWarning = { [weak self] in
            if let strongSelf = self {
                strongSelf.context.sharedContext.presentContactsWarningSuppression(context: strongSelf.context, present: { c, a in
                    strongSelf.present(c, in: .window(.root), with: a)
                })
            }
        }
        
        self.contactsNode.contactListNode.contentOffsetChanged = { [weak self] offset in
            if let strongSelf = self, let searchContentNode = strongSelf.searchContentNode {
                searchContentNode.updateListVisibleContentOffset(offset)
            }
        }
        
        self.contactsNode.contactListNode.contentScrollingEnded = { [weak self] listView in
            if let strongSelf = self, let searchContentNode = strongSelf.searchContentNode {
                return fixNavigationSearchableListNodeScrolling(listView, searchNode: searchContentNode)
            } else {
                return false
            }
        }
        
        self.displayNodeDidLoad()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.contactsNode.contactListNode.enableUpdates = true
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.contactsNode.contactListNode.enableUpdates = false
    }
    
    override public func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        
        self.contactsNode.containerLayoutUpdated(layout, navigationBarHeight: self.cleanNavigationHeight, actualNavigationBarHeight: self.navigationLayout(layout: layout).navigationFrame.maxY, transition: transition)
    }
    
    private func activateSearch() {
        if self.displayNavigationBar {
            if let searchContentNode = self.searchContentNode {
                self.contactsNode.activateSearch(placeholderNode: searchContentNode.placeholderNode)
            }
            self.setDisplayNavigationBar(false, transition: .animated(duration: 0.5, curve: .spring))
        }
    }
    
    private func deactivateSearch() {
        if !self.displayNavigationBar {
            self.setDisplayNavigationBar(true, transition: .animated(duration: 0.5, curve: .spring))
            if let searchContentNode = self.searchContentNode {
                self.contactsNode.deactivateSearch(placeholderNode: searchContentNode.placeholderNode)
            }
        }
    }
    
    private func openPeer(peerId: PeerId) {
        (self.navigationController as? NavigationController)?.replaceTopController(ChatControllerImpl(context: self.context, chatLocation: .peer(id: peerId)), animated: true)
    }
    
    @objc private func cancelPressed() {
        (self.navigationController as? NavigationController)?.filterController(self, animated: true)
    }
}

// MARK: - SubscriptionChannelController
class CreateChannelDescriptionController: ViewController {
    enum ChannelType {
        case `public`
        case `private`
        case subscription
    }
    
    private let context: AccountContext
    private var presentationData: PresentationData
    private let channelType: ChannelType
    
    private let _next = Promise<Void>()
    var nextSignal: Signal<Void, NoError> {
        _next.get()
    }
    
    init(context: AccountContext, channelType: ChannelType) {
        self.context = context
        self.presentationData = context.sharedContext.currentPresentationData.with { $0 }
        self.channelType = channelType
        
        let navigationBarPresentationData = NavigationBarPresentationData(
            theme: NavigationBarTheme(
                buttonColor: presentationData.theme.rootController.navigationBar.accentTextColor,
                disabledButtonColor: presentationData.theme.rootController.navigationBar.disabledButtonColor,
                primaryTextColor: presentationData.theme.rootController.navigationBar.primaryTextColor,
                backgroundColor: .clear,
                enableBackgroundBlur: false,
                separatorColor: .clear,
                badgeBackgroundColor: .clear,
                badgeStrokeColor: .clear,
                badgeTextColor: .clear
            ),
            strings: NavigationBarStrings(presentationStrings: presentationData.strings)
        )
        
        super.init(navigationBarPresentationData: navigationBarPresentationData)
        
        switch channelType {
        case .private:
            title = presentationData.strings.CreateChannelDescription_NavigationBar_Title_Private
        case .public:
            title = presentationData.strings.CreateChannelDescription_NavigationBar_Title_Public
        case .subscription:
            title = presentationData.strings.CreateChannelDescription_NavigationBar_Title_Subscription
        }
        
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: presentationData.strings.Common_Back,
            style: .plain,
            target: nil,
            action: nil
        )
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func donePressed() {
        self.dismiss()
    }
    
    override public func loadDisplayNode() {
        self.displayNode = SubscriptionChannelControllerNode(presentationStrings: presentationData.strings, channelType: channelType, nextPromise: _next)
        self.displayNodeDidLoad()
    }
    
    override public func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        
        controllerNode.containerLayoutUpdated(
            layout,
            navigationBarHeight: navigationLayout(layout: layout).navigationFrame.maxY,
            transition: transition
        )
    }
    
    private var controllerNode: SubscriptionChannelControllerNode {
        displayNode as! SubscriptionChannelControllerNode
    }
}

public class SubscriptionChannelControllerNode: ASDisplayNode {
    private var constraints: [NSLayoutConstraint] = []
    
    private let nextPromise: Promise<Void>
    
    private let presentationStrings: PresentationStrings
    private let channelType: CreateChannelDescriptionController.ChannelType
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(bundleImageName: "SubscriptionChannel/LogoPanda")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hex: 0x070708)
        label.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.textColor = UIColor(hex: 0x929298)
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.showsVerticalScrollIndicator = false
        textView.textAlignment = .center
        
        return textView
    }()
    let button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.cornerRadius = 18
        button.backgroundColor = UIColor(hex: 0x0A49A5)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.tintColor = .white
        
        return button
    }()
    
    init(presentationStrings: PresentationStrings, channelType: CreateChannelDescriptionController.ChannelType, nextPromise: Promise<Void>) {
        self.nextPromise = nextPromise
        self.presentationStrings = presentationStrings
        self.channelType = channelType
        
        super.init()
        
        backgroundColor = .white
        view.disablesInteractiveTransitionGestureRecognizer = true
        
        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(textView)
        view.addSubview(button)
    }
    
    public override func didLoad() {
        super.didLoad()
        
        switch channelType {
        case .public:
            label.text = presentationStrings.CreateChannelDescription_Title_Public
            textView.text = presentationStrings.CreateChannelDescription_Description_Public
            button.setTitle(presentationStrings.Continue, for: .normal)
        case .private:
            label.text = presentationStrings.CreateChannelDescription_Title_Private
            textView.text = presentationStrings.CreateChannelDescription_Description_Private
            button.setTitle(presentationStrings.Continue, for: .normal)
        case .subscription:
            label.text = presentationStrings.CreateChannelDescription_Title_Subscription
            textView.text = presentationStrings.CreateChannelDescription_Description_Subscription
            button.setTitle(presentationStrings.ChannelIntro_CreateChannel, for: .normal)
        }
        
        button.addAction { [weak self] in
            self?.nextPromise.set(.single(Void()))
        }
    }
    
    private func configureLayout(navigationBarHeight: CGFloat) {
        clearConstraints()
        
        constraints = [
            view.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: navigationBarHeight + 41),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 16),
            
            textView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 30),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 16),

            button.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 30),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: 16),
            view.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: 34),
            button.heightAnchor.constraint(equalToConstant: 56)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func clearConstraints() {
        constraints.forEach { $0.isActive = false }
        constraints.removeAll()
    }
    
    func containerLayoutUpdated(_ layout: ContainerViewLayout, navigationBarHeight: CGFloat, transition: ContainedViewLayoutTransition) {
        configureLayout(navigationBarHeight: navigationBarHeight)
    }
}

// MARK: - SubscriptionChannelPriceController
public class SubscriptionChannelPriceController: ViewController {
    private let context: AccountContext
    private var presentationData: PresentationData
    private var textFieldObservation: NSKeyValueObservation?
    
    private let _next = Promise<Double>()
    var nextSignal: Signal<Double, NoError> {
        _next.get()
    }
    
    public init(context: AccountContext) {
        self.context = context
        self.presentationData = context.sharedContext.currentPresentationData.with { $0 }
        
        let navigationBarPresentationData = NavigationBarPresentationData(
            theme: NavigationBarTheme(
                buttonColor: presentationData.theme.rootController.navigationBar.accentTextColor,
                disabledButtonColor: presentationData.theme.rootController.navigationBar.disabledButtonColor,
                primaryTextColor: presentationData.theme.rootController.navigationBar.primaryTextColor,
                backgroundColor: .clear,
                enableBackgroundBlur: false,
                separatorColor: .clear,
                badgeBackgroundColor: .clear,
                badgeStrokeColor: .clear,
                badgeTextColor: .clear
            ),
            strings: NavigationBarStrings(presentationStrings: presentationData.strings)
        )
        
        super.init(navigationBarPresentationData: navigationBarPresentationData)
        
        title = "Paid channel"
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: presentationData.strings.Common_Back,
            style: .plain,
            target: nil,
            action: nil
        )
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func displayNodeDidLoad() {
        super.displayNodeDidLoad()
        
        controllerNode.priceChangedHandler = { [weak self] text in
            guard let price = text?.double else { return }
            guard let self else { return }
            
            if price <= 0 {
                navigationItem.rightBarButtonItem = nil
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                    title: self.presentationData.strings.Common_Next,
                    style: .done,
                    target: self,
                    action: #selector(self.nextPressed)
                )
            }
        }
    }
    
    deinit {
        textFieldObservation?.invalidate()
        textFieldObservation = nil
    }
    
    @objc private func nextPressed() {
        guard let priceString = controllerNode.textField.text else { return }
        guard let price = Double(priceString) else { return }
        
        _next.set(.single(price))
    }
    
    override public func loadDisplayNode() {
        displayNode = SubscriptionChannelPriceControllerNode(theme: presentationData.theme, nextPromise: _next)
        displayNodeDidLoad()
    }
    
    override public func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        
        controllerNode.containerLayoutUpdated(
            layout,
            navigationBarHeight: navigationLayout(layout: layout).navigationFrame.maxY,
            transition: transition
        )
    }
    
    private var controllerNode: SubscriptionChannelPriceControllerNode {
        displayNode as! SubscriptionChannelPriceControllerNode
    }
}

public class SubscriptionChannelPriceControllerNode: ASDisplayNode {
    private var constraints: [NSLayoutConstraint] = []
    var buttonTappedHandler: (() -> Void)?
    var priceChangedHandler: ((String?) -> Void)?
    
    private let nextPromise: Promise<Double>
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hex: 0x070708)
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        label.text = "PaidChannel.Create.Title.MonthlyPayment".localized
        label.numberOfLines = 0
        
        return label
    }()
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(bundleImageName: "SubscriptionChannel/MonthlySubscriptionPanda")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.init(249), for: .vertical)
        imageView.setContentCompressionResistancePriority(.init(749), for: .vertical)
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hex: 0x070708)
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Price"
        label.numberOfLines = 0
        
        return label
    }()
    let textField: SubscriptionChannelPriceTextField = {
        let textField = SubscriptionChannelPriceTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "0.00"
        textField.textColor = UIColor(hex: 0x070708)
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.borderStyle = .none
        textField.backgroundColor = UIColor(hex: 0xEEEEEF)
        textField.keyboardType = .decimalPad
        textField.cornerRadius = 14
        textField.borderColor = UIColor(hex: 0x0A49A5)
        textField.clearButtonMode = .whileEditing
        
        return textField
    }()
    let infoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(bundleImageName: "SubscriptionChannel/SubscriptionInfoCircle")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.init(249), for: .vertical)
        imageView.setContentCompressionResistancePriority(.init(749), for: .vertical)
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    let infoTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hex: 0x070708)
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.text = "PaidChannel.Create.Info.Title".localized
        
        return label
    }()
    let infoSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hex: 0x070708)
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.text = "PaidChannel.Create.Info.Subtitle".localized
        label.numberOfLines = 0
        
        return label
    }()
    let button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.cornerRadius = 18
        button.setTitle("Confirm", for: .normal)
        button.backgroundColor = UIColor(hex: 0xCFCFD2)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor(hex: 0x929298), for: .disabled)
        button.tintColor = .white
        button.isEnabled = false
        
        return button
    }()
    
    init(theme: PresentationTheme? = nil, nextPromise: Promise<Double>) {
        self.nextPromise = nextPromise
        super.init()
        
        backgroundColor = .white
        view.disablesInteractiveTransitionGestureRecognizer = true
        
        view.addSubview(label)
        view.addSubview(imageView)
        view.addSubview(priceLabel)
        view.addSubview(textField)
        view.addSubview(infoImageView)
        view.addSubview(infoTitleLabel)
        view.addSubview(infoSubtitleLabel)
        view.addSubview(button)
        
        button.addAction { [weak self] in
            guard let priceString = self?.textField.text else { return }
            guard let price = Double(priceString) else { return }
            
            self?.nextPromise.set(.single(price))
        }
        textField.addAction(for: .editingChanged) { [weak textField, weak button, weak self] in
            let price = textField?.text?.double ?? 0.0
            let isButtonEnabled = price > 0.0
            
            if !isButtonEnabled {
                textField?.backgroundColor = UIColor(hex: 0xEEEEEF)
                textField?.borderWidth = 0
                
                button?.backgroundColor = UIColor(hex: 0xCFCFD2)
            } else {
                textField?.backgroundColor = .clear
                textField?.borderWidth = 1
                
                button?.backgroundColor = UIColor(hex: 0x0A49A5)
            }
            self?.button.isEnabled = isButtonEnabled
            self?.priceChangedHandler?(textField?.text)
        }
    }
    
    public override func didLoad() {
        super.didLoad()
        
        textField.delegate = self
        textField.becomeFirstResponder()
    }
    
    private func configureLayout(navigationBarHeight: CGFloat) {
        clearConstraints()
        
        let constraintToKeyboard = view.keyboardLayoutGuideNoSafeArea.topAnchor.constraint(
            equalTo: button.bottomAnchor, constant: 16
        )
        constraintToKeyboard.priority = UILayoutPriority(999)
        
        constraints = [
            view.centerXAnchor.constraint(equalTo: label.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: navigationBarHeight + 66),
            
            view.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
            
            priceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            priceLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            priceLabel.widthAnchor.constraint(equalToConstant: 228),
            
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            textField.widthAnchor.constraint(equalToConstant: 228),
            textField.heightAnchor.constraint(equalToConstant: 50),
            
            infoImageView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 34),
            infoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17),
            
            infoTitleLabel.centerYAnchor.constraint(equalTo: infoImageView.centerYAnchor),
            infoTitleLabel.leadingAnchor.constraint(equalTo: infoImageView.trailingAnchor, constant: 8),
            infoTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -17),
            
            infoSubtitleLabel.topAnchor.constraint(equalTo: infoImageView.bottomAnchor, constant: 8),
            infoSubtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17),
            infoSubtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -17),
            
            button.topAnchor.constraint(greaterThanOrEqualTo: textField.bottomAnchor, constant: 42),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: 16),
            constraintToKeyboard,
            view.bottomAnchor.constraint(greaterThanOrEqualTo: button.bottomAnchor, constant: 34),
            button.heightAnchor.constraint(equalToConstant: 56)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func clearConstraints() {
        constraints.forEach { $0.isActive = false }
        constraints.removeAll()
    }
    
    func containerLayoutUpdated(_ layout: ContainerViewLayout, navigationBarHeight: CGFloat, transition: ContainedViewLayoutTransition) {
        configureLayout(navigationBarHeight: navigationBarHeight)
    }
}

// MARK: - UITextFieldDelegate
extension SubscriptionChannelPriceControllerNode: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.shouldPriceChangeCharactersIn(range, replacementString: string)
    }
}

class SubscriptionChannelWithInsetsTextField: UITextField {
    private let padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 5)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
}

class SubscriptionChannelPriceTextField: UITextField {
    private let paddingWithLeftView = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 5)
    
    private lazy var _leftView: UIView = {
        var _leftView = UILabel()
        _leftView.translatesAutoresizingMaskIntoConstraints = false
        _leftView.font = font
        _leftView.textColor = textColor
        _leftView.text = "$"
        
        return _leftView
        
//        let elloCoinImage = UIImage(systemName: "dollarsign")
//        return UIImageView(image: elloCoinImage)
    }()
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        leftViewMode = .always
        leftView = _leftView
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: paddingWithLeftView)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: paddingWithLeftView)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: paddingWithLeftView)
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x = 16.0
//        rect.origin.y = 17.0
//        rect.size = CGSize(width: 16, height: 16)
        
        return rect
    }
}
