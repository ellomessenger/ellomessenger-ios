//
//  TransactionsViewController.swift
//  _idx_ELProfileUI_41162252_ios_min11.0
//
//

import UIKit
import ELBase

public struct Transaction {
    var owner: Owner = Owner(name: "")
    var state: State = .pending
    var totalAmount: Int = 0
    var commissions: Int = 0
    var amountReceivedDate: Date = Date()
    var paymentDate: Date = Date()
    var withdrawRequestedDate: Date = Date()
    var transferedDate: Date = Date()
    
    public init(owner: Owner, totalAmount: Int, commissions: Int, state: State = .pending, amountReceivedDate: Date = Date(), paymentDate: Date = Date(), withdrawRequestedDate: Date = Date(), transferedDate: Date = Date()) {
        self.owner = owner
        self.state = state
        self.totalAmount = totalAmount
        self.commissions = commissions
        self.amountReceivedDate = amountReceivedDate
        self.paymentDate = paymentDate
        self.withdrawRequestedDate = withdrawRequestedDate
        self.transferedDate = transferedDate
    }
}

public extension Transaction {
    
    struct Owner {
        var avatar: UIImage?
        var name: String = ""
        
        public init(avatar: UIImage? = nil, name: String) {
            self.avatar = avatar
            self.name = name
        }
    }
    
    enum State: String {
        case approved
        case rejected
        case pending
    }
}



class TransactionsViewController: BaseViewController {
    
    // MARK: - Public
    
    var transactions: [Transaction] = []
    { didSet{ tableView?.reloadData() }}
    
    var onTapFilter: VoidClosure?
    var onTapItem: EventClosure<Transaction>?
    
    // MARK: - Lifecycle
    
    override func localize() {
        titleL?.text = Localization.transactions.localized(Bundle(for: Self.self))
        totalBalanceTitleL?.text = Localization.totalBalance.localized(Bundle(for: Self.self))
    }
    
    override func storyboardName() -> String {
        return "ELProfileUI"
    }
    
    // MARK: - Private
    
    @IBOutlet private weak var titleL: UILabel?
    @IBOutlet private weak var totalBalanceTitleL: UILabel?
    @IBOutlet private weak var totalBalanceValueL: UILabel?
    @IBOutlet private weak var tableView: UITableView?
}

// MARK: - Actions

extension TransactionsViewController {
    
    @IBAction private func filterBtnDidTap(_ sender: AnyObject?) {
        onTapFilter?()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension TransactionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if let c = tableView.dequeueReusableCell(withIdentifier: "transaction") as? TransactionCell {
            c.transaction = transactions[indexPath.row]
            cell = c
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        onTapItem?(transactions[indexPath.row])
    }
}

private enum Localization: String {
    case transactions
    case totalBalance
}
