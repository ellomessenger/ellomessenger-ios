//
//  TransactionHistoryViewController.swift
//  _idx_ELProfileUI_A1C769BD_ios_min14.0
//
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

private enum ScrollDirection {
    case up
    case down
    
    init(velocity: CGFloat) {
        if velocity <= 0 {
            self = .up
        } else {
            self = .down
        }
    }
}

class TransactionHistoryViewController: BaseViewController {
    private typealias DataSource = UITableViewDiffableDataSource<String, WalletTransaction>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<String, WalletTransaction>
    
    // MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchTextField: TextFieldPadding!
    @IBOutlet private weak var emptyStackView: UIStackView?
    @IBOutlet private weak var emptyAnimationView: UIView?
    @IBOutlet private weak var emptyTitleLabel: UILabel?
    
    // MARK: - Properties
    private let animationNode = AnimationNode()
    var requestService: RequestService?
    
    var wallet: Api.wallet.WalletItem?
    var walletTransactions: [WalletTransaction] = [] {
        didSet {
            createSnapshot()
            showEmptyView()
        }
    }
    var sections: [String] = []
    private lazy var dataSource = makeDataSource()
    
    private var parenController: TransactionControllerContainable? {
        parent as? TransactionControllerContainable
    }
    
    private var controllerState: ControllerState = .compact {didSet{
        self.showEmptyView()
    }}
    
    let generator = PassthroughSubject<String, Never>()
    var bag = Set<AnyCancellable>()
    
    var onTapTransaction: EventClosure<WalletTransaction>?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        requestTransaction()
        showEmptyView()
    }
    
    // MARK: - Set up
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let animationView = emptyAnimationView {
            animationNode.frame = animationView.bounds
            animationView.addSubnode(animationNode)
        }
    }
    
    // MARK: - Set up
    override func localize() {
        emptyTitleLabel?.text = "transactionHistory.emptyView".localized
    }
    
    private func showEmptyView() {
        emptyStackView?.isHidden = !(walletTransactions.isEmpty && self.controllerState == .full)
        if walletTransactions.isEmpty {
            animationNode.setAnimation(name: "TransactionHistoryNoResults")
            animationNode.loop()
        }
    }

    private func configureTableView() {
        tableView.register(
            TransactionHistoryHeaderView.nib,
            forHeaderFooterViewReuseIdentifier: TransactionHistoryHeaderView.reuseIdentifier
        )
        tableView.sectionHeaderTopPadding = 0
    }
    
    // MARK: - IBActions
    @IBAction func cancelSearchTapped(_ sender: UIButton) {
        if (searchTextField.text ?? "").count > 0 {
            searchTextField.text = ""
            requestTransaction()
        }
        searchTextField.resignFirstResponder()
        
        updateTableViewTopConstraint(with: .down)
    }
    
    @IBAction func textViewEditingChanged(_ sender: TextFieldPadding) {
        bag.removeAll()
        
        generator.delay(for: 0.5, scheduler: RunLoop.main).sink { [weak self] value in
            guard value.count == 0 || value.count > 2 else {
                return
            }
            
            self?.requestTransaction()
        }.store(in: &bag)
        
        generator.send(sender.text ?? "")
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
            let velocity = sender.velocity(in: view)
            let direction = ScrollDirection(velocity: velocity.y)
            updateTableViewTopConstraint(with: direction)
        }
    }
    
    // MARK: - Actions
    private func makeDataSource() -> DataSource {
        DataSource(tableView: tableView) { [weak self] tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TransactionHistoryTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? TransactionHistoryTableViewCell
            
            cell?.configure(item: item, requestService: self?.requestService)
            
            return cell
        }
    }
    
    private func createSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections(sections)
        for section in sections {
            let items = walletTransactions
                .lazy
                .filter { $0.transaction.createdAtFormatted == section }
            snapshot.appendItems(Array(items), toSection: section)
        }
        
        dataSource.defaultRowAnimation = .fade
        dataSource.apply(snapshot)
    }
    
    private func updateTableViewTopConstraint(with direction: ScrollDirection) {
        if controllerState == .compact, direction == .up {
            controllerState = .full
        } else if controllerState == .full, direction == .down {
            guard tableView.contentOffset.y == 0 else {
                return
            }
            
            controllerState = .compact
            if dataSource.numberOfSections(in: tableView) > 0 {
                tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            }
        } else if controllerState == .dragging {
            switch direction {
            case .up:
                controllerState = .full
            case .down:
                guard controllerState != .compact else { return }
                controllerState = .compact
                if dataSource.numberOfSections(in: tableView) > 0 {
                    tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
                    tableView.contentOffset = CGPoint.zero
                }
            }
        } else {
            return
        }
        
        parenController?.tableViewHeightConstraint.priority = controllerState.heightPriority
        parenController?.tableViewTopToNavbarConstraint.priority = controllerState.toNavBarPriority
        parenController?.tableViewHeightConstraint.constant = parenController?.defaultTableViewHeight ?? 0
        parenController?.tableViewTopToNavbarConstraint.constant = 12
        
        tableView.isScrollEnabled = false
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.parenController?.view.layoutIfNeeded()
        } completion: { _ in
            self.tableView.isScrollEnabled = true
        }
    }
    
    // MARK: - Navigation
    
    // MARK: - Network Manager calls
    func requestTransaction() {
        guard let wallet else { return }
            
        requestService?.getWalletTransactions(
            walletId: wallet.id,
            paymentType: "all",
            search: searchTextField.text ?? "",
            dateFrom: "",
            dateTo: "",
            limit: 100,
            offset: 0,
            completionHandler: { result in
                switch result {
                case .success(let history):
                    debugPrint(history)
                    
                    var set = Set<String>()
                    self.sections = history.transactions
                        .filter { set.insert($0[keyPath: \.transaction.createdAtFormatted]).inserted }
                        .compactMap { $0.transaction.createdAtFormatted }
                    self.walletTransactions = history.transactions
                case .failure(let error):
                    debugPrint(error)
                }
            })
    }
}

// MARK: - UITableViewDelegate
extension TransactionHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: TransactionHistoryHeaderView.reuseIdentifier
        ) as? TransactionHistoryHeaderView
        
        if sections.count > section {
            view?.titleLabel?.text = sections[section]
        }
        
        return view
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView.superview)
        updateTableViewTopConstraint(with: ScrollDirection(velocity: velocity.y))
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let transactionItem = dataSource.itemIdentifier(for: indexPath) else { return }
        
        onTapTransaction?(transactionItem)
    }
}

// MARK: - UITextFieldDelegate
extension TransactionHistoryViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateTableViewTopConstraint(with: .up)
    }
}
