import Foundation
import SwiftSignalKit
import Postbox
import ElloAppCore
import ElloAppUIPreferences
import AccountContext
import PhotoResources
import UniversalMediaPlayer

private final class PrefetchMediaContext {
    let fetchDisposable = MetaDisposable()
    
    init() {
    }
}

struct InChatPrefetchOptions: Equatable {
    let networkType: MediaAutoDownloadNetworkType
    let peerType: MediaAutoDownloadPeerType
}

final class InChatPrefetchManager {
    private let context: AccountContext
    private var settings: MediaAutoDownloadSettings
    private var options: InChatPrefetchOptions?
    
    private var messages: [(Message, Media)] = []
    private var directionIsToLater: Bool = true
    
    private var contexts: [MediaId: PrefetchMediaContext] = [:]
    
    init(context: AccountContext) {
        self.context = context
        self.settings = context.sharedContext.currentAutomaticMediaDownloadSettings.with { $0 }
    }
    
    func updateAutoDownloadSettings(_ settings: MediaAutoDownloadSettings) {
        if self.settings != settings {
            self.settings = settings
            self.update()
        }
    }
    
    func updateOptions(_ options: InChatPrefetchOptions) {
        if self.options != options {
            self.options = options
            self.update()
        }
    }
    
    func updateMessages(_ messages: [(Message, Media)], directionIsToLater: Bool) {
        self.messages = messages
        self.directionIsToLater = directionIsToLater
        self.update()
    }
    
    private func update() {
        guard let options = self.options else {
            return
        }
        
        var validIds = Set<MediaId>()
        for (message, media) in self.messages {
            guard let id = media.id else {
                continue
            }
            
            if validIds.contains(id) {
                continue
            }
            
            var mediaResource: MediaResource?
            var automaticDownload: InteractiveMediaNodeAutodownloadMode = .none
            
            if let elloappImage = media as? ElloAppMediaImage {
                mediaResource = largestRepresentationForPhoto(elloappImage)?.resource
                if shouldDownloadMediaAutomatically(settings: self.settings, 
                                                    peerType: options.peerType,
                                                    networkType: options.networkType,
                                                    authorPeerId: nil,
                                                    contactsPeerIds: [],
                                                    media: elloappImage) {
                    automaticDownload = .full
                }
            } else if let elloappFile = media as? ElloAppMediaFile {
                mediaResource = elloappFile.resource
                if shouldDownloadMediaAutomatically(settings: self.settings, 
                                                    peerType: options.peerType,
                                                    networkType: options.networkType,
                                                    authorPeerId: nil,
                                                    contactsPeerIds: [],
                                                    media: elloappFile) {
                    automaticDownload = .full
                } else if shouldPredownloadMedia(settings: self.settings, 
                                                 peerType: options.peerType,
                                                 networkType: options.networkType,
                                                 media: elloappFile) {
                    automaticDownload = .prefetch
                }
            }
            
            if case .none = automaticDownload {
                continue
            }
            
            guard let resource = mediaResource else {
                continue
            }
            
            validIds.insert(id)
            let context: PrefetchMediaContext
            if let current = self.contexts[id] {
                context = current
            } else {
                context = PrefetchMediaContext()
                self.contexts[id] = context
                
                let priority: FetchManagerPriority = .foregroundPrefetch(direction: self.directionIsToLater ? .toLater : .toEarlier, localOrder: message.index)
                
                if case .full = automaticDownload {
                    if let image = media as? ElloAppMediaImage {
                        context.fetchDisposable.set(messageMediaImageInteractiveFetched(fetchManager: self.context.fetchManager, 
                                                                                        messageId: message.id,
                                                                                        messageReference: MessageReference(message),
                                                                                        image: image,
                                                                                        resource: resource,
                                                                                        userInitiated: false,
                                                                                        priority: priority,
                                                                                        storeToDownloadsPeerType: nil).start())
                    } else if let _ = media as? ElloAppMediaWebFile {
                        //strongSelf.fetchDisposable.set(chatMessageWebFileInteractiveFetched(account: context.account, image: image).start())
                    } else if let file = media as? ElloAppMediaFile {
                        let fetchSignal = messageMediaFileInteractiveFetched(fetchManager: self.context.fetchManager, 
                                                                             messageId: message.id,
                                                                             messageReference: MessageReference(message),
                                                                             file: file,
                                                                             userInitiated: false,
                                                                             priority: priority)
                        context.fetchDisposable.set(fetchSignal.start())
                    }
                } else if case .prefetch = automaticDownload, message.id.peerId.namespace != Namespaces.Peer.SecretChat {
                    if let file = media as? ElloAppMediaFile, let _ = file.size {
                        context.fetchDisposable.set(preloadVideoResource(postbox: self.context.account.postbox, 
                                                                         resourceReference: FileMediaReference.message(message: MessageReference(message), media: file).resourceReference(file.resource),
                                                                         duration: 4.0).start())
                    }
                }
            }
        }
        
        var removeIds: [MediaId] = []
        for key in self.contexts.keys {
            if !validIds.contains(key) {
                removeIds.append(key)
            }
        }
        
        for id in removeIds {
            if let context = self.contexts.removeValue(forKey: id) {
                context.fetchDisposable.dispose()
            }
        }
    }
}
