
import Foundation

public extension Api.likes {
    typealias LikeResponse<T> = (FunctionDescription, Buffer, DeserializeFunctionResponse<T>)
    internal static var likesService: LikesService {
        LikesService()
    }
    
    static func getLikes(userId: Int64, messageId: Int, peerType: LikesPeerType, peerId: Int64) -> LikeResponse<UserIdsItem> {
        likesService.getLikes(userId: userId, messageId: messageId, peerType: peerType, peerId: peerId)
    }
    
    static func addLike(userId: Int64, messageId: Int, peerType: LikesPeerType, peerId: Int64) -> LikeResponse<LikesStatusItem> {
        likesService.addLike(userId: userId, messageId: messageId, peerType: peerType, peerId: peerId)
    }
    
    static func removeLike(userId: Int64, messageId: Int, peerType: LikesPeerType, peerId: Int64) -> LikeResponse<LikesStatusItem> {
        likesService.removeLike(userId: userId, messageId: messageId, peerType: peerType, peerId: peerId)
    }
}

// Linker bug fix to success compilation need present any class
private class ApiLikes { }
