import Foundation
import UIKit
import Display
import AsyncDisplayKit
import Postbox
import ElloAppCore
import SwiftSignalKit
import ElloAppPresentationData
import AccountContext
import ContactListUI
import CallListUI
import ChatListUI
import SettingsUI
import AppBundle
import DatePickerNode
import DebugSettingsUI
import TabBarUI
import PremiumUI

import ELProfileUI
import ELCallsUI
import ELContactsUI
import UndoUI
import ElloAppIntents
import PresentationDataUtils
import ELBase

public final class ElloAppRootController: NavigationController {
    private let context: AccountContext
    
    public var rootTabController: TabBarController?
    
    public var contactsController: ViewController?
    public var callListController: ViewController?
    public var chatListController: ChatListController?
    public var feedListController: ViewController?
    
//    public var accountSettingsController: PeerInfoScreen?
    public var accountSettingsController: ViewController?
    
    private var permissionsDisposable: Disposable?
    private var presentationDataDisposable: Disposable?
    private var presentationData: PresentationData
    
    private var applicationInFocusDisposable: Disposable?
        
    public init(context: AccountContext) {
        self.context = context
        
        self.presentationData = context.sharedContext.currentPresentationData.with { $0 }
        
        let navigationDetailsBackgroundMode: NavigationEmptyDetailsBackgoundMode?
        switch presentationData.chatWallpaper {
        case .color:
            let image = generateTintedImage(image: UIImage(bundleImageName: "Chat List/EmptyMasterDetailIcon"), color: presentationData.theme.chatList.messageTextColor.withAlphaComponent(0.2))
            navigationDetailsBackgroundMode = image != nil ? .image(image!) : nil
        default:
            let image = chatControllerBackgroundImage(theme: presentationData.theme, 
                                                      wallpaper: presentationData.chatWallpaper,
                                                      mediaBox: context.account.postbox.mediaBox,
                                                      knockoutMode: context.sharedContext.immediateExperimentalUISettings.knockoutWallpaper)
            
            navigationDetailsBackgroundMode = image != nil ? .wallpaper(image!) : nil
        }
        
        super.init(mode: .automaticMasterDetail, theme: NavigationControllerTheme(presentationTheme: self.presentationData.theme), backgroundDetailsMode: navigationDetailsBackgroundMode)
        
        self.presentationDataDisposable = (context.sharedContext.presentationData
        |> deliverOnMainQueue).start(next: { [weak self] presentationData in
            if let strongSelf = self {
                if presentationData.chatWallpaper != strongSelf.presentationData.chatWallpaper {
                    let navigationDetailsBackgroundMode: NavigationEmptyDetailsBackgoundMode?
                    switch presentationData.chatWallpaper {
                        case .color:
                            let image = generateTintedImage(image: UIImage(bundleImageName: "Chat List/EmptyMasterDetailIcon"), color: presentationData.theme.chatList.messageTextColor.withAlphaComponent(0.2))
                            navigationDetailsBackgroundMode = image != nil ? .image(image!) : nil
                        default:
                            navigationDetailsBackgroundMode = chatControllerBackgroundImage(theme: presentationData.theme,
                                                                                            wallpaper: presentationData.chatWallpaper,
                                                                                            mediaBox: strongSelf.context.sharedContext.accountManager.mediaBox,
                                                                                            knockoutMode: strongSelf.context.sharedContext.immediateExperimentalUISettings.knockoutWallpaper).flatMap(NavigationEmptyDetailsBackgoundMode.wallpaper)
                    }
                    strongSelf.updateBackgroundDetailsMode(navigationDetailsBackgroundMode, transition: .immediate)
                }

                let previousTheme = strongSelf.presentationData.theme
                strongSelf.presentationData = presentationData
                if previousTheme !== presentationData.theme {
                    (strongSelf.rootTabController as? TabBarControllerImpl)?.updateTheme(navigationBarPresentationData: NavigationBarPresentationData(presentationData: presentationData), theme: TabBarControllerTheme(rootControllerTheme: presentationData.theme))
                    strongSelf.rootTabController?.statusBar.statusBarStyle = presentationData.theme.rootController.statusBarStyle.style
                }
            }
        })
        
        if context.sharedContext.applicationBindings.isMainApp {
            self.applicationInFocusDisposable = (context.sharedContext.applicationBindings.applicationIsActive
            |> distinctUntilChanged
            |> deliverOn(Queue.mainQueue())).start(next: { value in
                context.sharedContext.mainWindow?.setForceBadgeHidden(!value)
            })
        }
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.permissionsDisposable?.dispose()
        self.presentationDataDisposable?.dispose()
        self.applicationInFocusDisposable?.dispose()
    }
    
    public func addRootControllers(showCallsTab: Bool) {
        let tabBarController = TabBarControllerImpl(
            navigationBarPresentationData: NavigationBarPresentationData(
                presentationData: presentationData),
            theme: TabBarControllerTheme(rootControllerTheme: presentationData.theme))
        tabBarController.navigationPresentation = .master
        
        let chatListController = context.sharedContext.makeChatListController(
            context: context,
            groupId: .root,
            controlsHistoryPreload: true,
            hideNetworkActivityStatus: false,
            previewing: false,
            enableDebugActions: !GlobalExperimentalSettings.isAppStoreBuild)
        if let sharedContext = context.sharedContext as? SharedAccountContextImpl {
            chatListController.tabBarItem.badgeValue = sharedContext.switchingData.chatListBadge
        }
        
//        let callListController = ELCallsController.root()//CallListController(context: self.context, mode: .tab)
        let callListController = CallListController(context: context, mode: .tab)
        
        let feedListController = ELFeedController.root(context: context) {
            tabBarController.selectedIndex = 2
        }//CallListController(context: self.context, mode: .tab, isPlaceholder:true)
        
        let contactsController = ContactsController(context: context)
        contactsController.switchToChatsController = { [weak self] in
            self?.openChatsController(activateSearch: false)
        }
        
        if !PresentationTheme.isTabbarTitleShown {
            callListController.tabBarItem.title = ""
            feedListController.tabBarItem.title = ""
            contactsController.tabBarItem.title = ""
        }
        
//        let deleteContactAction: EventClosure<Contact> = { [weak self] contact in
//            guard let self else {
//                return
//            }
//            
//            let deleteContactFromDevice: Signal<Never, NoError>
//            if let contactDataManager = self.context.sharedContext.contactDataManager {
//                deleteContactFromDevice = contactDataManager.deleteContactWithAppSpecificReference(peerId: contact.peerId)
//            } else {
//                deleteContactFromDevice = .complete()
//            }
//            
//            var deleteSignal = self.context.engine.contacts.deleteContactPeerInteractively(peerId: contact.peerId)
//            |> then(deleteContactFromDevice)
//            
//            let progressSignal = Signal<Never, NoError> { [weak self] subscriber in
//                guard let strongSelf = self else {
//                    return EmptyDisposable
//                }
//                
//                let presentationData = strongSelf.context.sharedContext.currentPresentationData.with { $0 }
//                let statusController = OverlayStatusController(theme: presentationData.theme, type: .loading(cancelled: nil))
//                strongSelf.contactsController?.present(statusController, in: .window(.root))
//                return ActionDisposable { [weak statusController] in
//                    Queue.mainQueue().async() {
//                        statusController?.dismiss()
//                    }
//                }
//            }
//            |> runOn(Queue.mainQueue())
//            |> delay(0.15, queue: Queue.mainQueue())
//            let progressDisposable = progressSignal.start()
//            
//            deleteSignal = deleteSignal
//            |> afterDisposed {
//                Queue.mainQueue().async {
//                    progressDisposable.dispose()
//                }
//            }
//            
//            _ = (deleteSignal
//                 |> deliverOnMainQueue).start(completed: { [weak self] in
//                ELContactsController.onContactDeleted?(contact)
//                if let strongSelf = self {
//                    let presentationData = strongSelf.context.sharedContext.currentPresentationData.with { $0 }
//                    let controller = UndoOverlayController(presentationData: presentationData, content: .info(title: nil, text: presentationData.strings.Conversation_DeletedFromContacts(contact.name).string), elevatedLayout: false, animateInAsReplacement: false, action: { _ in return false })
//                    controller.keepOnParentDismissal = true
//                    strongSelf.contactsController?.present(controller, in: .window(.root))
//                }
//            })
//            
//            deleteSendMessageIntents(peerId: contact.peerId)
//            
//        }
//        
//        let contactsController = ELContactsController.root(self.context) { [weak self] in
//            self?.openChatsController(activateSearch: false)
//        } deleteContact: { [weak self] contact in
//            guard let self else {
//                return
//            }
//            
//            self.showDeleteAccount(name: contact.name) {
//                deleteContactAction(contact)
//            }
//        }
        
        var restoreSettignsController: (ViewController & SettingsController)?
        if let sharedContext = self.context.sharedContext as? SharedAccountContextImpl {
            restoreSettignsController = sharedContext.switchingData.settingsController
        }
        restoreSettignsController?.updateContext(context: context)
        
        if let sharedContext = self.context.sharedContext as? SharedAccountContextImpl {
            sharedContext.switchingData = (nil, nil, nil)
        }
        
        let accountSettingsController = PeerInfoScreenImpl(
            context: context,
            updatedPresentationData: nil,
            peerId: context.account.peerId,
            avatarInitiallyExpanded: false,
            isOpenedFromChat: false,
            nearbyPeerDistance: nil,
            reactionSourceMessageId: nil,
            callMessages: [],
            isSettings: true)
        accountSettingsController.tabBarItemDebugTapAction = { [weak self] in
            guard let self else { return }
            
            self.pushViewController(
                debugController(sharedContext: self.context.sharedContext, context: self.context)
            )
        }

        var controllers: [ViewController] = []
        controllers.append(callListController)
        controllers.append(contactsController)
        controllers.append(chatListController)
        controllers.append(feedListController)
        controllers.append(accountSettingsController)
        
        tabBarController.setControllers(
            controllers,
            selectedIndex: restoreSettignsController != nil
            ? controllers.firstIndex(of: accountSettingsController)
            : controllers.firstIndex(of: chatListController)
        )
        
        self.contactsController = contactsController
        self.callListController = callListController
        self.chatListController = chatListController
        self.feedListController = feedListController
        self.accountSettingsController = accountSettingsController
        self.rootTabController = tabBarController
        self.pushViewController(tabBarController, animated: false)
    }
    
    private func showDeleteAccount(name: String, completion: @escaping VoidClosure) {
        let presentationData = context.sharedContext.currentPresentationData.with { $0 }
        let alertController = textAlertController(context: context, title: "", text: presentationData.strings.Contacts_DeleteTitle(name).string, actions: [
            TextAlertAction(type: .genericAction, title: presentationData.strings.Common_Cancel, action: {
            }),
            TextAlertAction(type: .defaultAction, title: presentationData.strings.Common_Confirm, action: completion)
        ])
        contactsController?.present(alertController, in: .window(.root), with: ViewControllerPresentationArguments(presentationAnimation: .modalSheet))
    }
        
    public func updateRootControllers(showCallsTab: Bool) {
        guard let rootTabController = self.rootTabController as? TabBarControllerImpl else {
            return
        }
        
        var controllers: [ViewController] = []
        controllers.append(self.callListController!)
        controllers.append(self.contactsController!)
        controllers.append(self.chatListController!)
        controllers.append(self.feedListController!)
        controllers.append(self.accountSettingsController!)
        rootTabController.setControllers(controllers, selectedIndex: nil)
    }
    
    public func openChatsController(activateSearch: Bool, filter: ChatListSearchFilter = .chats, query: String? = nil) {
        guard let rootTabController = self.rootTabController else {
            return
        }
        
        if activateSearch {
            self.popToRoot(animated: false)
        }
        
        if let index = rootTabController.controllers.firstIndex(where: { $0 is ChatListController}) {
            rootTabController.selectedIndex = index
        }
        
        if activateSearch {
            self.chatListController?.activateSearch(filter: filter, query: query)
        }
    }
    
    public func openRootCompose() {
        self.chatListController?.activateCompose()
    }
    
    public func openRootCamera() {
        guard let controller = self.viewControllers.last as? ViewController else {
            return
        }
        
        controller.view.endEditing(true)
        presentedLegacyShortcutCamera(context: self.context, saveCapturedMedia: false, saveEditedPhotos: false, mediaGrouping: true, parentController: controller)
    }
    
    public func openFeedController(activateRecomended: Bool) {
        if let index = rootTabController?.controllers.firstIndex(where: { $0 == feedListController}) {
            rootTabController?.selectedIndex = index
            
            if activateRecomended {
                let controller = feedListController as? AdaptingController
                let feedContcontroller = controller?.altController as? FeedRootViewController
                feedContcontroller?.openRecomendedTab()
            }
        }
    }
    
    public func openContactsController() {
        if let index = rootTabController?.controllers.firstIndex(where: { $0 == contactsController}) {
            rootTabController?.selectedIndex = index
        }
    }

}
