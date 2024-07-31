import Foundation
import AnimationUI
import ElloAppAnimatedStickerNode
import AnimatedStickerNode
import UIKit
import Display
import AsyncDisplayKit
import SwiftSignalKit
import ElloAppPresentationData
import TextFormat
import Markdown

public class ItemListAnimationItem: ListViewItem, ItemListItem {
    let name: String
    public let sectionId: ItemListSectionId
    
    public init(name: String, sectionId: ItemListSectionId) {
        self.name = name
        self.sectionId = sectionId
    }
    
    public func nodeConfiguredForParams(async: @escaping (@escaping () -> Void) -> Void, params: ListViewItemLayoutParams, synchronousLoads: Bool, previousItem: ListViewItem?, nextItem: ListViewItem?, completion: @escaping (ListViewItemNode, @escaping () -> (Signal<Void, NoError>?, (ListViewItemApply) -> Void)) -> Void) {
        async {
            let node = ItemListAnimationItemNode()
            let (layout, apply) = node.asyncLayout()(self, params, itemListNeighbors(item: self, topItem: previousItem as? ItemListItem, bottomItem: nextItem as? ItemListItem))
            
            node.contentSize = layout.contentSize
            node.insets = layout.insets
            
            Queue.mainQueue().async {
                completion(node, {
                    return (nil, { _ in apply() })
                })
            }
        }
    }
    
    public func updateNode(async: @escaping (@escaping () -> Void) -> Void, node: @escaping () -> ListViewItemNode, params: ListViewItemLayoutParams, previousItem: ListViewItem?, nextItem: ListViewItem?, animation: ListViewItemUpdateAnimation, completion: @escaping (ListViewItemNodeLayout, @escaping (ListViewItemApply) -> Void) -> Void) {
        Queue.mainQueue().async {
            guard let nodeValue = node() as? ItemListAnimationItemNode else {
                assertionFailure()
                return
            }
        
            let makeLayout = nodeValue.asyncLayout()
            
            async {
                let (layout, apply) = makeLayout(self, params, itemListNeighbors(item: self, topItem: previousItem as? ItemListItem, bottomItem: nextItem as? ItemListItem))
                Queue.mainQueue().async {
                    completion(layout, { _ in
                        apply()
                    })
                }
            }
        }
    }
}

public class ItemListAnimationItemNode: ListViewItemNode, ItemListItemNode {
    private let animationNode: AnimationNode
    private let activateArea: AccessibilityAreaNode
    
    private var item: ItemListAnimationItem?
    
    public var tag: ItemListItemTag? {
        return self.item?.tag
    }
    
    public init() {
        animationNode = AnimationNode()
        animationNode.loop()
        
        activateArea = AccessibilityAreaNode()
        activateArea.accessibilityTraits = .staticText
        
        super.init(layerBacked: false, dynamicBounce: false)
        
        addSubnode(animationNode)
        addSubnode(activateArea)
    }
    
    public func asyncLayout() -> (_ item: ItemListAnimationItem, _ params: ListViewItemLayoutParams, _ neighbors: ItemListNeighbors) -> (ListViewItemNodeLayout, () -> Void) {
        return { item, params, neighbors in
            let insets = itemListNeighborsGroupedInsets(neighbors, params)
            
            let topInset = 0.0
            let imageWidth = 200.0
            let imageHeight = 200.0
            let contentSize = CGSize(width: params.width, height: imageHeight + topInset)
            
            let layout = ListViewItemNodeLayout(contentSize: contentSize, insets: insets)
            
            return (layout, { [weak self] in
                guard let self else { return }
                
                self.item = item
                
                activateArea.frame = CGRect(origin: CGPoint(x: params.leftInset, y: 0.0), size: CGSize(width: params.width - params.leftInset - params.rightInset, height: layout.contentSize.height))
                activateArea.accessibilityLabel = "Panda"
                
                animationNode.setAnimation(name: item.name)
                animationNode.frame = CGRect(origin: CGPoint(x: params.width / 2 - imageWidth / 2, y: topInset), size: CGSize(width: 200.0, height: 200.0))
                animationNode.play()
            })
        }
    }
    
    override public func animateInsertion(_ currentTimestamp: Double, duration: Double, short: Bool) {
        layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.4)
    }
    
    override public func animateRemoved(_ currentTimestamp: Double, duration: Double) {
        layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.15, removeOnCompletion: false)
    }
}
