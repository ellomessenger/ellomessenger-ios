import Foundation
import ElloAppCore
import WidgetItems

public extension WidgetDataPeer.Message {
    init(accountPeerId: EnginePeer.Id, message: EngineMessage) {
        var content: WidgetDataPeer.Message.Content = .text
        for media in message.media {
            switch media {
            case _ as ElloAppMediaImage:
                content = .image(WidgetDataPeer.Message.Content.Image())
            case let file as ElloAppMediaFile:
                var fileName = "file"
                for attribute in file.attributes {
                    if case let .FileName(value) = attribute {
                        fileName = value
                        break
                    }
                }
                content = .file(WidgetDataPeer.Message.Content.File(name: fileName))
                for attribute in file.attributes {
                    switch attribute {
                    case let .Sticker(altText, _, _):
                        content = .sticker(WidgetDataPeer.Message.Content.Sticker(altText: altText))
                    case let .Video(duration, _, flags):
                        if flags.contains(.instantRoundVideo) {
                            content = .videoMessage(WidgetDataPeer.Message.Content.VideoMessage(duration: Int32(duration)))
                        } else {
                            content = .video(WidgetDataPeer.Message.Content.Video())
                        }
                    case let .Audio(isVoice, duration, title, performer, _):
                        if isVoice {
                            content = .voiceMessage(WidgetDataPeer.Message.Content.VoiceMessage(duration: Int32(duration)))
                        } else {
                            content = .music(WidgetDataPeer.Message.Content.Music(artist: performer ?? "", title: title ?? "", duration: Int32(duration)))
                        }
                    default:
                        break
                    }
                }
            case let action as ElloAppMediaAction:
                switch action.action {
                case let .phoneCall(_, _, _, isVideo):
                    content = .call(WidgetDataPeer.Message.Content.Call(isVideo: isVideo))
                default:
                    break
                }
            case _ as ElloAppMediaMap:
                content = .mapLocation(WidgetDataPeer.Message.Content.MapLocation())
            default:
                break
            }
        }
        
        var author: Author?
        if let _ = message.peers[message.id.peerId] as? ElloAppGroup {
            if let authorPeer = message.author {
                author = Author(isMe: authorPeer.id == accountPeerId, title: authorPeer.debugDisplayTitle)
            }
        } else if let channel = message.peers[message.id.peerId] as? ElloAppChannel, case .group = channel.info {
            if let authorPeer = message.author {
                author = Author(isMe: authorPeer.id == accountPeerId, title: authorPeer.debugDisplayTitle)
            }
        }
        
        self.init(author: author, text: message.text, content: content, timestamp: message.timestamp)
    }
}
