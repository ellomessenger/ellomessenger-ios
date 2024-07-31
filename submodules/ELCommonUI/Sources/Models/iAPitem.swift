//
//  iAPitem.swift
//  _idx_AccountContext_262CEDDD_ios_min15.4
//
//

import UIKit
import ELBase
import StoreKit

struct iAPItemModel {
    
    private static let bundle = Bundle(for: BaseViewController.self)
    enum Icon: String {
        case text = "aiTextIcon", image = "aiImageIcon", textImage = "aiTextImageIcon"
        var image: UIImage? {
            UIImage(named: rawValue, in: iAPItemModel.bundle, with: nil)
        }
    }
    enum Background: String {
        case text = "gradientTextBG", image = "gradientImageBG", textImage = "gradientTextImageBG"
        
        var image: UIImage? {
            UIImage(named: rawValue, in: iAPItemModel.bundle, with: nil)
        }
    }
    
    enum AIType: Int, Comparable {
        static func < (lhs: iAPItemModel.AIType, rhs: iAPItemModel.AIType) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
        
        case text, image, textImage
        var price: String {
            switch self {
            case .image:
                return "5.99"
            case .text:
                return "5.99"
            case .textImage:
                return "5.99"
            }
        }
        
        var freeText: Int {
            switch self {
            case .image:
                return 0
            case .text:
                return 10
            case .textImage:
                return 10
            }
        }
        
        var freeImage: Int {
            switch self {
            case .image:
                return 5
            case .text:
                return 0
            case .textImage:
                return 5
            }
        }
    }
    enum Avatar: String {
        case text = "aiTextRounded", image = "aiImageRounded"
        
        var image: UIImage? {
            UIImage(named: rawValue, in: iAPItemModel.bundle, with: nil)
        }
    }
    
    struct ListItem {
        let title: String
        let description: String
        static let textItems: [ListItem] = {
            [.init(title: "iAP.AI.Text.0.Title".localized, description: "iAP.AI.Text.0.Description".localized),
             .init(title: "iAP.AI.Text.1.Title".localized, description: "iAP.AI.Text.1.Description".localized),
             .init(title: "iAP.AI.Text.2.Title".localized, description: "iAP.AI.Text.2.Description".localized),
             .init(title: "iAP.AI.Text.3.Title".localized, description: "iAP.AI.Text.3.Description".localized),
             .init(title: "iAP.AI.Text.4.Title".localized, description: "iAP.AI.Text.4.Description".localized),
             .init(title: "iAP.AI.Text.5.Title".localized, description: "iAP.AI.Text.5.Description".localized),
             .init(title: "iAP.AI.Text.6.Title".localized, description: "iAP.AI.Text.6.Description".localized),
             .init(title: "iAP.AI.Text.7.Title".localized, description: "iAP.AI.Text.7.Description".localized),
             .init(title: "iAP.AI.Text.8.Title".localized, description: "iAP.AI.Text.8.Description".localized),
             .init(title: "iAP.AI.Text.9.Title".localized, description: "iAP.AI.Text.9.Description".localized),
             .init(title: "iAP.AI.Text.10.Title".localized, description: "iAP.AI.Text.10.Description".localized),
             .init(title: "iAP.AI.Text.11.Title".localized, description: "iAP.AI.Text.11.Description".localized),
             .init(title: "iAP.AI.Text.12.Title".localized, description: "iAP.AI.Text.12.Description".localized),
             .init(title: "iAP.AI.Text.13.Title".localized, description: "iAP.AI.Text.13.Description".localized),
             .init(title: "iAP.AI.Text.14.Title".localized, description: "iAP.AI.Text.14.Description".localized)]
//             .init(title: "iAP.AI.Text.15.Title".localized, description: "iAP.AI.Text.15.Description".localized)]
        }()
        
        static let imageItems: [ListItem] = {
            [.init(title: "iAP.AI.Image.0.Title".localized, description: "iAP.AI.Image.0.Description".localized),
             .init(title: "iAP.AI.Image.1.Title".localized, description: "iAP.AI.Image.1.Description".localized),
             .init(title: "iAP.AI.Image.2.Title".localized, description: "iAP.AI.Image.2.Description".localized),
             .init(title: "iAP.AI.Image.3.Title".localized, description: "iAP.AI.Image.3.Description".localized),
             .init(title: "iAP.AI.Image.4.Title".localized, description: "iAP.AI.Image.4.Description".localized)]
        }()
    }
    let id: String
    lazy private(set) var icon: UIImage? = {
        switch type {
        case .image: return Icon.image.image
        case .text: return Icon.text.image
        case .textImage: return Icon.textImage.image
        }
    }()
    lazy private(set) var background: UIImage? = {
        switch type {
        case .image: return Background.image.image
        case .text: return Background.text.image
        case .textImage: return Background.textImage.image
        }
    }()
    
    lazy private(set) var rounded: UIImage? = {
        switch type {
        case .image: return Avatar.image.image
        case .text: return Avatar.text.image
        default: return nil
        }
    }()
    
    let title: String
    let description: String
    let count: Int
    let freeCount: Int
    let list: [ListItem]
    var product: Product?
    let type: AIType
    
    var propose: String {
        if type == .textImage {
            return String(format: "iAP.AI.Text.Image.Propose".localized, "40", "50")
        } else {
            return String(count)
        }
    }
    
    var priceString: String {
        guard let price = product?.displayPrice else {
            return ""
        }
        return String(format: "iAP.AI.Count.Label".localized, "\(count)", price)
    }
    
    var displayPrice: String {
        guard let price = product?.displayPrice else {
            return ""
        }
        return price
    }
    
    var priceWithoutCurrency: String {
        guard let price = product?.price else {
            return "0"
        }
        
        return String(format: "%.2f", Double(price.description) ?? 0)
    }
    
    static var itemsForSubscriptions: [iAPItemModel] {
        let textSubscription = iAPItemModel(id: "ai.subscription.text.1month",
                                            title: "iAP.AI.Text.Title".localized,
                                            description: "iAP.AI.Text.Description".localized,
                                            count: 1000,
                                            freeCount: 10,
                                            list: ListItem.textItems,
                                            type: .text)
        let imagetSubscription = iAPItemModel(id: "ai.subscription.image.1month",
                                              title: "iAP.AI.Image.Title".localized,
                                              description: "iAP.AI.Image.Description".localized,
                                              count: 400,
                                              freeCount: 5,
                                              list: ListItem.imageItems,
                                              type: .image)
        let imageTextSubscription = iAPItemModel(id: "ai.subscription.image.text.1month",
                                              title: "iAP.AI.Text.Image.Title".localized,
                                              description: "iAP.AI.Text.Image.Description".localized,
                                              count: 400,
                                              freeCount: 5,
                                              list: ListItem.imageItems,
                                              type: .textImage)
        return [textSubscription, imagetSubscription, imageTextSubscription]
    }
    
    static var itemsForConsumable: [iAPItemModel] {
        let textConsumable = iAPItemModel(id: "ai.consumable.text.200.requests",
                                          title: "iAP.AI.Text.Title".localized,
                                          description: "iAP.AI.Text.Description".localized,
                                          count: 80,
                                          freeCount: AIType.text.freeText,
                                          list: ListItem.textItems,
                                          type: .text)
        let imageConsumable = iAPItemModel(id: "ai.consumable.image.120.requests",
                                            title: "iAP.AI.Image.Title".localized,
                                            description: "iAP.AI.Image.Description".localized,
                                            count: 100,
                                           freeCount: AIType.image.freeImage,
                                            list: ListItem.imageItems,
                                            type: .image)
        let imageTextConsumable = iAPItemModel(id: "ai.consumable.image.text.pack",
                                            title: "iAP.AI.Text.Image.Title".localized,
                                            description: "iAP.AI.Text.Image.Description".localized,
                                            count: 100,
                                           freeCount: 5,
                                            list: ListItem.imageItems,
                                            type: .textImage)
        return [textConsumable, imageConsumable, imageTextConsumable]
    }
}
