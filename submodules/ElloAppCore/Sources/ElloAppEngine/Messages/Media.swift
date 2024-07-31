import Postbox

public enum EngineMedia {
    public typealias Id = MediaId

    case image(ElloAppMediaImage)
    case file(ElloAppMediaFile)
    case geo(ElloAppMediaMap)
    case contact(ElloAppMediaContact)
    case action(ElloAppMediaAction)
    case dice(ElloAppMediaDice)
    case expiredContent(ElloAppMediaExpiredContent)
    case game(ElloAppMediaGame)
    case invoice(ElloAppMediaInvoice)
    case poll(ElloAppMediaPoll)
    case unsupported(ElloAppMediaUnsupported)
    case webFile(ElloAppMediaWebFile)
    case webpage(ElloAppMediaWebpage)
}

public extension EngineMedia {
    var id: Id? {
        switch self {
        case let .image(image):
            return image.id
        case let .file(file):
            return file.id
        case let .geo(geo):
            return geo.id
        case let .contact(contact):
            return contact.id
        case let .action(action):
            return action.id
        case let .dice(dice):
            return dice.id
        case let .expiredContent(expiredContent):
            return expiredContent.id
        case let .game(game):
            return game.id
        case let .invoice(invoice):
            return invoice.id
        case let .poll(poll):
            return poll.id
        case let .unsupported(unsupported):
            return unsupported.id
        case let .webFile(webFile):
            return webFile.id
        case let .webpage(webpage):
            return webpage.id
        }
    }
}

public extension EngineMedia {
    init(_ media: Media) {
        switch media {
        case let image as ElloAppMediaImage:
            self = .image(image)
        case let file as ElloAppMediaFile:
            self = .file(file)
        case let geo as ElloAppMediaMap:
            self = .geo(geo)
        case let contact as ElloAppMediaContact:
            self = .contact(contact)
        case let action as ElloAppMediaAction:
            self = .action(action)
        case let dice as ElloAppMediaDice:
            self = .dice(dice)
        case let expiredContent as ElloAppMediaExpiredContent:
            self = .expiredContent(expiredContent)
        case let game as ElloAppMediaGame:
            self = .game(game)
        case let invoice as ElloAppMediaInvoice:
            self = .invoice(invoice)
        case let poll as ElloAppMediaPoll:
            self = .poll(poll)
        case let unsupported as ElloAppMediaUnsupported:
            self = .unsupported(unsupported)
        case let webFile as ElloAppMediaWebFile:
            self = .webFile(webFile)
        case let webpage as ElloAppMediaWebpage:
            self = .webpage(webpage)
        default:
            preconditionFailure()
        }
    }

    func _asMedia() -> Media {
        switch self {
        case let .image(image):
            return image
        case let .file(file):
            return file
        case let .geo(geo):
            return geo
        case let .contact(contact):
            return contact
        case let .action(action):
            return action
        case let .dice(dice):
            return dice
        case let .expiredContent(expiredContent):
            return expiredContent
        case let .game(game):
            return game
        case let .invoice(invoice):
            return invoice
        case let .poll(poll):
            return poll
        case let .unsupported(unsupported):
            return unsupported
        case let .webFile(webFile):
            return webFile
        case let .webpage(webpage):
            return webpage
        }
    }
}
