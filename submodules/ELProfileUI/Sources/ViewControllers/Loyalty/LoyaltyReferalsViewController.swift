//
//  LoyaltyReferalsViewController.swift
//  ELProfileUI
//
//  Created by Oleksii Zabrodin on 16.01.2024.
//

import UIKit
import ELBase
import ElloAppApi
import Combine
import AccountContext
import AnimationUI

private enum ControllerState {
    case compact
    case full
    case dragging
    
    var toNavBarPriority: UILayoutPriority {
        switch self {
        case .compact, .dragging:
            return UILayoutPriority(rawValue: 250)
        case .full:
            return UILayoutPriority(rawValue: 999)
        }
    }
    
    var heightPriority: UILayoutPriority {
        switch self {
        case .compact, .dragging:
            return UILayoutPriority(rawValue: 999)
        case .full:
            return UILayoutPriority(rawValue: 250)
        }
    }
}

class LoyaltyReferalsViewController: BaseViewController {
    @IBOutlet private weak var titleL: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var menuButton: UIButton!
    @IBOutlet private weak var emptyStackView: UIStackView?
    @IBOutlet private weak var emptyAnimationView: UIView?
    @IBOutlet private weak var emptyTitleLabel: UILabel?
    @IBOutlet var searchTextField: TextFieldPadding!

    private var controllerState: ControllerState = .compact {didSet{
        self.showEmptyView()
    }}
    
    private var parenController: TransactionControllerContainable? {
        parent as? TransactionControllerContainable
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .yellow
    }
    
    @IBAction func onPanView(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            controllerState = .dragging
        case .changed:
            let translation = sender.translation(in: view)
            if parenController?.tableViewHeightConstraint.priority.rawValue == 999 {
                parenController?.tableViewHeightConstraint.constant -= translation.y
            } else {
                parenController?.tableViewTopToNavbarConstraint.constant += translation.y
            }
            sender.setTranslation(.zero, in: view)
        default:
            break
//            let velocity = sender.velocity(in: view)
//            let direction = ScrollDirection(velocity: velocity.y)
//            updateTableViewTopConstraint(with: direction)
        }
    }

    private func showEmptyView() {
//        emptyStackView?.isHidden = !(walletTransactions.isEmpty && self.controllerState == .full)
//        if walletTransactions.isEmpty {
//            animationNode.setAnimation(name: "TransactionHistoryNoResults")
//            animationNode.loop()
//        }
    }

}
