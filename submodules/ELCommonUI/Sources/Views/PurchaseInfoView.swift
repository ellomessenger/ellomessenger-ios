//
//  PurchaseInfoView.swift
//  _idx_ELCommonUI_128253A2_ios_min15.4
//
//

import UIKit
import ELBase

class PurchaseInfoView: BaseView {
    
    struct iAPModelView {
        let segment: String?
        let freeTitle: String
        let items: [iAPItemModel.ListItem]
    }
    
    @IBOutlet private var freeView: UIView?
    @IBOutlet private var freeBGView: UIView?
    @IBOutlet private var freeLabel: UILabel?
    @IBOutlet private var freeInfoLabel: UILabel?
    @IBOutlet var infoListView: UIStackView?
    @IBOutlet private var segmentedControl: UISegmentedControl?
    @IBOutlet private var scrollView: UIScrollView?
    @IBOutlet private var scrollViewHeight: NSLayoutConstraint?
    
    var itemUpdated: EventClosure<CGFloat>?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        freeView?.layer.cornerRadius = (freeView?.bounds.height ?? 0) / 2
        freeBGView?.layer.cornerRadius = (freeBGView?.bounds.height ?? 0) / 2
        let itemAttibutes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: UIColor.black]
        segmentedControl?.setTitleTextAttributes(itemAttibutes, for: .normal)
        segmentedControl?.setTitleTextAttributes(itemAttibutes, for: .selected)
    }
    
    func config(items: [iAPItemModel.ListItem], freeCount: Int) {
        freeInfoLabel?.text = String(format: "iAP.AI.Consumable.Label".localized, "\(freeCount)")
        items.forEach { item in
            let infoView = PurchaseInfoItemView()
            infoView.config(title: item.title, description: item.description)
            infoListView?.addArrangedSubview(infoView)
        }
        layoutIfNeeded()
    }
    
    func config(models: [iAPModelView]) {
        if models.count > 1 {
            segmentedControl?.removeAllSegments()
            segmentedControl?.isHidden = false
            models.forEach {
                segmentedControl?.insertSegment(withTitle: $0.segment, at: segmentedControl?.numberOfSegments ?? 0, animated: true)
            }
            segmentedControl?.selectedSegmentIndex = 0
        } else {
            segmentedControl?.isHidden = true
        }
        
        freeInfoLabel?.text = models.map { $0.freeTitle }.joined(separator: " | " )
        //String(format: "iAP.AI.Consumable.Label".localized, "\(freeCount)")
        models.forEach { model in
            let contentStackView = UIStackView(frame: self.bounds)
            infoListView?.addArrangedSubview(contentStackView)
            contentStackView.translatesAutoresizingMaskIntoConstraints = false
            if let scrollView {
                contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1).isActive = true
            }
            contentStackView.axis = .vertical
            contentStackView.spacing = 16
            contentStackView.isLayoutMarginsRelativeArrangement = true
            contentStackView.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
            model.items.forEach { item in
                let infoView = PurchaseInfoItemView()
                infoView.config(title: item.title, description: item.description)
                contentStackView.addArrangedSubview(infoView)
            }
            contentStackView.layoutIfNeeded()
        }
        scrollViewHeight?.constant = infoListView?.arrangedSubviews.first?.bounds.height ?? 0
        layoutIfNeeded()
        
    }
    
    @IBAction
    func segmentChanged() {
        if let segmentedControl, let scrollView, let height = infoListView?.arrangedSubviews[segmentedControl.selectedSegmentIndex].bounds.height {
            scrollView.setContentOffset(CGPoint(x: scrollView.bounds.width * CGFloat(segmentedControl.selectedSegmentIndex), y: 0), animated: true)
            scrollViewHeight?.constant = height
            layoutIfNeeded()
            itemUpdated?(self.bounds.height)
        }
    }
}
