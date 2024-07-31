//
//  GraphsActivityViewController.swift
//  _idx_ELProfileUI_B2691B91_ios_min14.0
//
//

import UIKit
import ELBase
import ElloAppApi
import SwiftUI
import Charts

class GraphsActivityViewController: BaseViewController, TransactionControllerContainable, ObservableObject {
    
    static let withdrawButtonKey = "withdrawButtonKey"
    static let depositButtonKey = "depositButtonKey"
    
    // MARK: - IBOutlets
    @IBOutlet private var navigationTitleLabel: UILabel!
    @IBOutlet private var periodLabel: UILabel!
    @IBOutlet private var totalLabel: UILabel!
    @IBOutlet private var totalValueLabel: UILabel!
    @IBOutlet private var chartView: UIView!
    @IBOutlet private var periodSegmentedControl: SegmentedControl!
    @IBOutlet private var transactionsContainerView: UIView!
    @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var tableViewTopToNavbarConstraint: NSLayoutConstraint!
    @IBOutlet private var historyTitleLabel: UILabel!
    @IBOutlet private var withdrawButton: UIButton!
    @IBOutlet private var depositButton: UIButton!
    
    // MARK: - Properties
    var requestService: RequestService?
    var wallet: Api.wallet.WalletItem?
    var arrayWithDates: [String] = []
    var onTapTransaction: EventClosure<WalletTransaction>?
    var defaultTableViewHeight: CGFloat { max(self.view.bounds.height - historyTitleLabel.frame.maxY - 12, 170) }
    private var period: TransferStatisticGraphicItem.Period = .week
    private var transactionController: TransactionHistoryViewController?
    private var currentChartViewController: UIHostingController<TransferStatisticContentView>?
    private var periodActivityItemTransactions: [TransferStatisticGraphicItem] = [] {
        didSet {
            addChartsView(periodActivityItemTransactions)
        }
    }
    
    var typeGraphs: TransferStatisticGraphicItem.`Type`  = {
        if UserDefaults.standard.bool(forKey: "withdrawButtonKey") {
            return .withdraw
        } else if UserDefaults.standard.bool(forKey: "depositButtonKey") {
            return .deposit
        } else {
            return .withdraw
        }
    }()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transferStatisticGraphic(typeGraphs: typeGraphs, period: period)
        setupUI()
        localize()
        
        addTransactionHistoryContainerController()
    }
    
    func addChartsView(_ items: [TransferStatisticGraphicItem]) {
        if let existingController = currentChartViewController {
            existingController.willMove(toParent: nil)
            existingController.view.removeFromSuperview()
            existingController.removeFromParent()
        }
        
        var chart = TransferStatisticContentView.createWithDates(
            period: period,
            periodActivityItemTransactions: items,
            typeGraphs: typeGraphs)
        
        chart.onPeriodChange = { [weak self] period in
            self?.periodLabel.text = period.capitalizeFirst()
        }
        
        chart.onTotalChange = { [weak self] total in
            self?.totalValueLabel.text = total
        }
        
        let controller = UIHostingController(rootView: chart)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        currentChartViewController = controller
        
        UIView.animate(withDuration: 0.3, animations: {
            self.addChild(controller)
            self.chartView.insertSubview(controller.view, at: 0)
            controller.didMove(toParent: self)
        })
        
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: chartView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: chartView.trailingAnchor),
            
            controller.view.topAnchor.constraint(equalTo: chartView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: chartView.bottomAnchor)
        ])
    }
   
    // MARK: - Set up
    override func storyboardName() -> String {
        return "GraphsActivity"
    }
    
    override func localize() {
        periodSegmentedControl?.removeAllSegments()
        TransferStatisticGraphicItem.Period.allCases.reversed().forEach{ [weak self] in
            self?.periodSegmentedControl?.insertSegment(withTitle: $0.rawValue.capitalizeFirst(), at: 0, animated: false)
        }
        periodSegmentedControl?.selectedSegmentIndex = 0
        navigationTitleLabel?.text = "Wallets.FinancialActivity".localized
    }
    
    func setupUI() {
        totalLabel.text = "Wallets.Total".localized
        periodSegmentedControl.clipsToBounds = true
        periodSegmentedControl.layer.cornerRadius = 30
        periodSegmentedControl.layer.borderWidth = 1.0
        periodSegmentedControl.layer.borderColor = UIColor(red: 0.812, green: 0.812, blue: 0.824, alpha: 1).cgColor
        periodSegmentedControl.setNeedsLayout()
        periodSegmentedControl.layoutIfNeeded()
        if typeGraphs == .deposit {
            depositButton.isSelected = true
            withdrawButton.isSelected = false
        } else {
            depositButton.isSelected = false
            withdrawButton.isSelected = true
        }
        withdrawButton.setImage(UIImage(named: "Wallet/withdrawButtonIcon", in: Bundle(for: Self.self), compatibleWith: nil), for: .normal)
        withdrawButton.setImage(UIImage(named: "Wallet/withdrawActiveButtonIcon", in: Bundle(for: Self.self), compatibleWith: nil), for: .selected)
        depositButton.setImage(UIImage(named: "Wallet/debitInactiveButtonIcon", in: Bundle(for: Self.self), compatibleWith: nil), for: .normal)
        depositButton.setImage(UIImage(named: "Wallet/debitactiveButtonIcon", in: Bundle(for: Self.self), compatibleWith: nil), for: .selected)
    }
    
    private func addTransactionHistoryContainerController() {
        let storyboard = UIStoryboard(name: "Transactions", bundle: Bundle(for: Self.self))
        transactionController = storyboard.instantiateViewController(withIdentifier: "TransactionHistoryViewController") as? TransactionHistoryViewController
        transactionController?.requestService = requestService
        transactionController?.wallet = wallet
        transactionController?.onTapTransaction = onTapTransaction
        add(transactionController, toContainerView: transactionsContainerView)
        tableViewHeightConstraint.constant = defaultTableViewHeight
    }
    
    // MARK: - IBActions
    @IBAction func segmentDidTap(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            period = .week
        case 1:
            period = .month
        case 2:
            period = .year
        default: 
            period = .week
        }
        transferStatisticGraphic(typeGraphs: typeGraphs, period: period)
    }
    
    @IBAction func didTapWithdraw(sender: UIButton) {
        handleTransactionButtonTap(type: .withdraw)
    }
    
    @IBAction func didTapDebit(sender: UIButton) {
        handleTransactionButtonTap(type: .deposit)
    }
    
    private func handleTransactionButtonTap(type: TransferStatisticGraphicItem.`Type`) {
        
        UserDefaults.standard.set(type == .withdraw, forKey: GraphsActivityViewController.withdrawButtonKey)
        UserDefaults.standard.set(type == .deposit, forKey: GraphsActivityViewController.depositButtonKey)
        UserDefaults.standard.synchronize()
        
        switch type {
        case .deposit:
            depositButton.isSelected = true
            withdrawButton.isSelected = false
        case .withdraw:
            withdrawButton.isSelected = true
            depositButton.isSelected = false
        }
        
        self.typeGraphs = type
        transferStatisticGraphic(typeGraphs: type, period: period)
    }
    
    // MARK: - Network Manager calls
    func transferStatisticGraphic(typeGraphs: TransferStatisticGraphicItem.`Type`, period: TransferStatisticGraphicItem.Period) {
        guard let wallet else { return }
        requestService?.transferStatisticGraphic(walletId: wallet.id, period: period, type: typeGraphs, limit: 100, page: 0) { [weak self] result in
            switch result {
            case .success(let transactionActivity):
                if transactionActivity.data.isEmpty {
                    self?.periodLabel?.text = self?.setPeriodForEmptyGraphs()
                }
                self?.periodActivityItemTransactions = transactionActivity.data.sorted(by: { leftItem, rightItem in
                    guard let leftDateFrom = leftItem.data.first?.dateFrom else { return true }
                    guard let rightDateFrom = rightItem.data.first?.dateFrom else { return true }
                    return leftDateFrom > rightDateFrom
                })
                guard let item = self?.periodActivityItemTransactions else { return }
                self?.addChartsView(item)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    private func setPeriodForEmptyGraphs() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
        var emptyPeriodString = ""

        switch period {
        case .week:
            guard let oneWeekLater = calendar.date(byAdding: .day, value: -7, to: currentDate) else { return "" }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM"
            
            let currentDateStr = dateFormatter.string(from: currentDate)
            dateFormatter.dateFormat = "dd"
            let oneWeekLaterStr = dateFormatter.string(from: oneWeekLater)
            
            emptyPeriodString = "\(oneWeekLaterStr)-\(currentDateStr)"
        case .month:
            dateFormatter.dateFormat = "MMMM"
            emptyPeriodString = dateFormatter.string(from: currentDate)
        case .year:
            dateFormatter.dateFormat = "YYYY"
            emptyPeriodString = dateFormatter.string(from: currentDate)
        }
        return emptyPeriodString
    }

}

// MARK: - Custom Segmented Control
class SegmentedControl: UISegmentedControl {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 20
    }
}
