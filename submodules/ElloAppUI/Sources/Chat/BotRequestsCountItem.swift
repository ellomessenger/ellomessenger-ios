//
//  BotRequestsCountItem.swift
//  _idx_Lib_ElloAppUI_312C5CC5_ios_min15.4
//
//

import ElloAppUIPeerInfoItem
import ElloAppPresentationData
import ELBase
import Display
import AsyncDisplayKit
import UIKit
import ELCommonUI

public class BotRequestsCountItem {
    
    public enum RequestType: Int {
        case notInited, text, image
    }
    
    public let id: AnyHashable
    
    public let count: Int
    public let type: RequestType
    public let buyMoreAction: VoidClosure?
    
    public init(id: AnyHashable, count: Int, type: RequestType, buyMoreAction: @escaping VoidClosure) {
        self.id = id
        self.count = count
        self.type = type
        self.buyMoreAction = buyMoreAction
    }
    
    public func node() -> BotRequestsCountItemNode {
        let node = BotRequestsCountItemNode()
        node.updateItem(self)
        return node
    }
}

public class BotRequestsCountItemNode: ASDisplayNode {
    
    public var item: BotRequestsCountItem?
    
    private let uiview: BotRequestCountView
    
    override init() {
        self.uiview = BotRequestCountView()
        super.init()
        
        self.view.addSubview(uiview)
    }
    
    func updateItem(_ item: BotRequestsCountItem) {
        self.item = item
        var link: String?
        let title = {
            switch item.type {
            case .image:
                if item.count == 0 {
                    link = "Bot.AI.Image.Request.BuyMore".localized
                    return "Bot.AI.Image.Request.Count.0".localized
                } else if item.count == 1 {
                    return "Bot.AI.Image.Request.Count.1".localized
                } else {
                    return String(format: "Bot.AI.Image.Request.Count.Many".localized, "\(item.count)")
                }
            case .text:
                if item.count == 0 {
                    link = "Bot.AI.Image.Request.BuyMore".localized
                    return "Bot.AI.Text.Request.Count.0".localized
                } else if item.count == 1 {
                    return "Bot.AI.Text.Request.Count.1".localized
                } else {
                    return String(format: "Bot.AI.Text.Request.Count.Many".localized, "\(item.count)")
                }
            default:
                return ""
            }
        }()
        self.uiview.updateTitle(title, link: link)
        self.uiview.buyMoreAction = item.buyMoreAction
    }
    
    public func updateViewFrameOnAppearing() {
        uiview.frame = bounds
        uiview.layoutIfNeeded()
    }
}

