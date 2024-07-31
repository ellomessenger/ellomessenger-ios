import Foundation
import Postbox
import ElloAppApi


extension ElloAppMediaGame {
    convenience init(apiGame: Api.Game) {
        switch apiGame {
            case let .game(_, id, accessHash, shortName, title, description, photo, document):
                var file: ElloAppMediaFile?
                if let document = document {
                    file = elloappMediaFileFromApiDocument(document)
                }
                self.init(gameId: id, accessHash: accessHash, name: shortName, title: title, description: description, image: elloappMediaImageFromApiPhoto(photo), file: file)
        }
    }
}
