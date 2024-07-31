import Foundation
import UIKit
import AsyncDisplayKit
import Display
import SwiftSignalKit

public final class ItemListTextEmptyStateItem: ListViewItem, ItemListItem {
    public let sectionId: ItemListSectionId
    
    public let text: String
    let presentationData: ItemListPresentationData
    
    public init(presentationData: ItemListPresentationData, text: String, sectionId: ItemListSectionId) {
        self.text = text
        self.sectionId = sectionId
        self.presentationData = presentationData
    }
    
    
    public func nodeConfiguredForParams(async: @escaping (@escaping () -> Void) -> Void, params: ListViewItemLayoutParams, synchronousLoads: Bool, previousItem: ListViewItem?, nextItem: ListViewItem?, completion: @escaping (ListViewItemNode, @escaping () -> (Signal<Void, NoError>?, (ListViewItemApply) -> Void)) -> Void) {
        async {
            let node = ItemListTextEmptyStateItemNode()
            let neighbors = itemListNeighbors(item: self, topItem: previousItem as? ItemListItem, bottomItem: nextItem as? ItemListItem)
            let (layout, apply) = node.asyncLayout()(self, params, neighbors)
            
            node.contentSize = layout.contentSize
            node.insets = layout.insets
            
            node.update(item: self)
            Queue.mainQueue().async {
                completion(node, {
                    return (nil, { _ in apply(false) })
                })
            }
        }
    }
    
    public func updateNode(async: @escaping (@escaping () -> Void) -> Void, node: @escaping () -> ListViewItemNode, params: ListViewItemLayoutParams, previousItem: ListViewItem?, nextItem: ListViewItem?, animation: ListViewItemUpdateAnimation, completion: @escaping (ListViewItemNodeLayout, @escaping (ListViewItemApply) -> Void) -> Void) {
        Queue.mainQueue().async {
            if let nodeValue = node() as? ItemListTextEmptyStateItemNode {
                let makeLayout = nodeValue.asyncLayout()
                
                var animated = true
                if case .None = animation {
                    animated = false
                }
                
                async {
                    let neighbors = itemListNeighbors(item: self, topItem: previousItem as? ItemListItem, bottomItem: nextItem as? ItemListItem)
                    let (layout, apply) = makeLayout(self, params, neighbors)
                    Queue.mainQueue().async {
                        completion(layout, { _ in
                            apply(animated)
                        })
                    }
                }
            }
        }
    }
}

public final class ItemListTextEmptyStateItemNode: ListViewItemNode {
    private let textNode: ASTextNode
    
    private var item: ItemListTextEmptyStateItem?
    
    init() {
        self.textNode = ASTextNode()
        self.textNode.isUserInteractionEnabled = false
        self.textNode.textAlignment = .left
        super.init(layerBacked: false, dynamicBounce: false)
        self.addSubnode(self.textNode)
    }
    
    public func update(item: ItemListTextEmptyStateItem) {
        if self.item?.text != item.text {
            self.item = item
            
            self.textNode.attributedText = NSAttributedString(string: item.text, font: Font.regular(14.0), textColor: .gray, paragraphAlignment: .left)
        }
    }
    
    func asyncLayout() -> (_ item: ItemListTextEmptyStateItem, _ params: ListViewItemLayoutParams, _ neighbors: ItemListNeighbors) -> (ListViewItemNodeLayout, (Bool) -> Void) {
        let makeTitleLayout = TextNode.asyncLayout(self.textNode)
        
        return { item, params, neighbors in
//            let separatorHeight = UIScreenPixel
            let (titleLayout, _) = makeTitleLayout(TextNodeLayoutArguments(attributedString: NSAttributedString(string: item.text, font: Font.regular(14.0), textColor: .gray, paragraphAlignment: .left), backgroundColor: nil, maximumNumberOfLines: 0, truncationType: .end, constrainedSize: CGSize(width: params.width - 40, height: CGFloat.greatestFiniteMagnitude), alignment: .natural, cutout: nil, insets: UIEdgeInsets()))
            let contentSize = CGSize(width: params.width - 40, height: titleLayout.size.height)
            
            let layout = ListViewItemNodeLayout(contentSize: contentSize, insets: .zero)
//            let layoutSize = layout.size
            return (layout, { [weak self] animated in
                if let strongSelf = self {
                    strongSelf.item = item
//                    let insets = layout.insets
                    let textSize = strongSelf.textNode.measure(layout.size)
                    let x = 20
                    let point = CGPoint(x: x, y: 15)
                    strongSelf.textNode.frame = CGRect(origin: point, size: textSize)
                    
                }
            })
        }
    }
}
