import Foundation
import Postbox
import ElloAppApi


func elloappMediaWebpageAttributeFromApiWebpageAttribute(_ attribute: Api.WebPageAttribute) -> ElloAppMediaWebpageAttribute? {
    switch attribute {
        case let .webPageAttributeTheme(_, documents, settings):
            var files: [ElloAppMediaFile] = []
            if let documents = documents {
                files = documents.compactMap { elloappMediaFileFromApiDocument($0) }
            }
            return .theme(ElloAppMediaWebpageThemeAttribute(files: files, settings: settings.flatMap { ElloAppThemeSettings(apiThemeSettings: $0) }))
    }
}

func elloappMediaWebpageFromApiWebpage(_ webpage: Api.WebPage, url: String?) -> ElloAppMediaWebpage? {
    switch webpage {
        case .webPageNotModified:
            return nil
        case let .webPagePending(id, date):
            return ElloAppMediaWebpage(webpageId: MediaId(namespace: Namespaces.Media.CloudWebpage, id: id), content: .Pending(date, url))
        case let .webPage(_, id, url, displayUrl, hash, type, siteName, title, description, photo, embedUrl, embedType, embedWidth, embedHeight, duration, author, document, cachedPage, attributes):
            var embedSize: PixelDimensions?
            if let embedWidth = embedWidth, let embedHeight = embedHeight {
                embedSize = PixelDimensions(width: embedWidth, height: embedHeight)
            }
            var webpageDuration: Int?
            if let duration = duration {
                webpageDuration = Int(duration)
            }
            var image: ElloAppMediaImage?
            if let photo = photo {
                image = elloappMediaImageFromApiPhoto(photo)
            }
            var file: ElloAppMediaFile?
            if let document = document {
                file = elloappMediaFileFromApiDocument(document)
            }
            var webpageAttributes: [ElloAppMediaWebpageAttribute] = []
            if let attributes = attributes {
                webpageAttributes = attributes.compactMap(elloappMediaWebpageAttributeFromApiWebpageAttribute)
            }
            var instantPage: InstantPage?
            if let cachedPage = cachedPage {
                instantPage = InstantPage(apiPage: cachedPage)
            }
            return ElloAppMediaWebpage(webpageId: MediaId(namespace: Namespaces.Media.CloudWebpage, id: id), content: .Loaded(ElloAppMediaWebpageLoadedContent(url: url, displayUrl: displayUrl, hash: hash, type: type, websiteName: siteName, title: title, text: description, embedUrl: embedUrl, embedType: embedType, embedSize: embedSize, duration: webpageDuration, author: author, image: image, file: file, attributes: webpageAttributes, instantPage: instantPage)))
        case .webPageEmpty:
            return nil
    }
}
