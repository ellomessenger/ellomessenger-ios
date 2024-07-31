//
//  ELContactsController.swift
//  _idx_ELWelcomeUI_DF76EB68_ios_min11.0
//
//

import Foundation
import UIKit
import Display
import ELBase
import ElloAppCore
import SwiftSignalKit
import AccountContext
import Postbox

public final class ELContactsController {
    
    private static var context: AccountContext?
    private static var contactsListDisp: Disposable?
    private static var contactsSearchDisp: Disposable?
    
    private static let contactPeersViewPromise = Promise<(EngineContactList, EnginePeer?)>()
    
    private static var isSearching = false
        
    private static var loadedEngineContactList: EngineContactList = EngineContactList(peers: [], presences: [:])
    
    private static var searchedContacts = [EnginePeer]()
    
    private static func reloadContacts(_ complete: (([Contact])->())?) {
        contactsListDisp = (reloadUserContacts() |> deliverOnMainQueue).start(next:{ contacts in
            if !isSearching {
                complete?(contacts)
            }
        })
    }
    
    public static var onContactDeleted: EventClosure<Contact>?
    
    public static func root(_ context: AccountContext, switchToChat:VoidClosure?, deleteContact: EventClosure<Contact>?) -> ViewController {
        self.context = context
        setupContactsLoad(context: context)
        
       
        
        let adopt = AdaptingController(viewController: nil)
        if let vc = ContactsListViewController.controller {
            
            reloadContacts {
                vc.contacts = $0
            }
            
            onContactDeleted = { [weak vc] contact in
                vc?.contacts.removeAll(where: { $0.id == contact.id })
            }
                       
            vc.onTapContact = { contact in
                debugLog("selected item: \(contact)")
                      guard let context = self.context else {return}
                
                if let navigationController = adopt.navigationController as? NavigationController {
                    let scrollToEndIfExists = false
                    let peerId: PeerId = PeerId(Int64(contact.id) ?? 0)
                    let chatParams = NavigateToChatControllerParams(navigationController: navigationController, context: context, chatLocation: .peer(id: peerId), purposefulAction: {
                        if isSearching {
                            vc.deactivateSearch()
                            switchToChat?()
                        }
                    }, scrollToEndIfExists: scrollToEndIfExists, options: [.removeOnMasterDetails], completion: { _ in
//                        if let strongSelf = self {
//                            strongSelf.contactsNode.contactListNode.listNode.clearHighlightAnimated(true)
//                        }
                    })
                    context.sharedContext.navigateToChatController(chatParams)
                }
                vc.deactivateSearch()
                switchToChat?()
            }
            vc.onSearch = { query in
                guard !query.isEmpty else {
                    isSearching = false
                    DispatchQueue.main.async {
                        let contacts = transform(endinePeers: loadedEngineContactList)
                        vc.contacts = contacts
                    }
                    return
                }
                
                isSearching = true

                contactsSearchDisp = (combineLatest(context.engine.contacts.searchRemotePeers(query: query.lowercased()),
                    context.engine.contacts.searchContacts(query: query.lowercased()) )
                |> deliverOnMainQueue )
                .start(next:{ remote, _ in

                    
                    let remotePeers = [remote.0, remote.1].flatMap{$0}
                    let filtered = remotePeers.filter { foundPeer in
                        return foundPeer.peer.id.id != context.account.peerId.id
                    }
                    let contacts = filtered.map { foundPeer in
                        var name = ""
                        if let userPeer = foundPeer.peer as? ElloAppUser {
                            name = [userPeer.firstName ?? "", userPeer.lastName ?? ""].joined(separator: " ")
                        }
                        let contact = Contact(id: foundPeer.peer.id.id.description, name: name, peerId: foundPeer.peer.id)
                        return contact
                    }
                                        
                    vc.contacts = contacts
                })
                
            }
            vc.onTapShare = {
                let string = "Hey, I’m using Ello to chat. Join me!"
                let activityController = UIActivityViewController(activityItems: [string], applicationActivities: nil)
                if let window = vc.view.window {
                    activityController.popoverPresentationController?.sourceView = window
                    activityController.popoverPresentationController?.sourceRect = CGRect(origin: CGPoint(x: window.bounds.width / 2.0, y: window.bounds.size.height - 1.0), size: CGSize(width: 1.0, height: 1.0))
                }
                context.sharedContext.applicationBindings.presentNativeController(activityController)
            }
            
            vc.onDeleteContact = deleteContact
            vc.needReload = { resultClosure in
                reloadContacts(resultClosure)
            }
            
            adopt.altController = vc
            
//            adopt.tabBarItem.title = "contacts".localized(Bundle(for: Self.self))
            adopt.tabBarItem.image = UIImage(named: "contacts-tab", in: Bundle(for: Self.self), compatibleWith: nil)
            adopt.tabBarItem.selectedImage = UIImage(named: "contacts-tab", in: Bundle(for: Self.self), compatibleWith: nil)
        }
        return adopt
    }
    
    private static func setupContactsLoad(context: AccountContext) {
        self.contactPeersViewPromise.set(context.engine.data.subscribe(
            ElloAppEngine.EngineData.Item.Contacts.List(includePresences: true),
            ElloAppEngine.EngineData.Item.Peer.Peer(id: context.engine.account.peerId)
        )
                                         |> mapToThrottled { next -> Signal<(EngineContactList, EnginePeer?), NoError> in
            return .single(next)
            |> then(
                .complete()
                |> delay(5.0, queue: Queue.concurrentDefaultQueue())
            )
        })
    }
    
    private static func reloadUserContacts() -> Signal<[Contact], NoError> {
        return contactPeersViewPromise.get()
        |> mapToSignal{ (engineContactList, _) in
            loadedEngineContactList = engineContactList
            
            let contacts = transform(endinePeers: engineContactList)
            return .single(contacts)
        }
    }
    
    private static func searchContacts(query: String) -> Signal<[Contact], NoError> {
        return .single([])
    }
    
    private static func transform(endinePeers: EngineContactList) -> [Contact] {
        let peers = endinePeers.peers
        
        let foundPeers = peers.map { enginePeer in
            let foundPeer = FoundPeer(peer: enginePeer._asPeer(), subscribers: nil)
            return foundPeer
        }
        
        let contacts = foundPeers.map { foundPeer in
            var name = ""
            if let userPeer = foundPeer.peer as? ElloAppUser {
                name = [userPeer.firstName ?? "", userPeer.lastName ?? ""].joined(separator: " ")
            }
            let peerId = foundPeer.peer.id.id.description
            
            let contact = Contact(id: peerId, name: name, peerId: foundPeer.peer.id)
            return contact
        }
        
        let presences = endinePeers.presences
        
        var statedContacts = [Contact]()
        
        for var cc in contacts {
            if let presenceKey = presences.keys.first(where: {$0.id.description == cc.id}) {
                let presence = presences[presenceKey]
                if let p = presence {
                    if case let .present(timestamp) = p.status {
                        if Double(timestamp) >= Date().timeIntervalSince1970 {
                            cc.state = .online
                        } else {
                            cc.state = .lastSeeen(Date(timeIntervalSince1970: Double(timestamp) ))
                        }
                    }
                }
            }
            statedContacts.append(cc)
        }
        return statedContacts
    }
}
