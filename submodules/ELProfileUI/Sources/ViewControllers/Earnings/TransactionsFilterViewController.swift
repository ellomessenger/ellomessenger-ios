//
//  TransactionsFilterViewController.swift
//  _idx_ELFeedUI_76522291_ios_min11.0
//
//

import UIKit
import ELBase


public struct Filter {
    var channel: String
    var dateFrom: Date
    var dateTo: Date
    
    public init(channel: String, dateFrom: Date = Date(), dateTo: Date = Date()) {
        self.channel = channel
        self.dateFrom = dateFrom
        self.dateTo = dateTo
    }
}

class TransactionsFilterViewController: BaseViewController {
    
    // MARK: - Public
    
    var filter: Filter?
    { didSet{ setupFilterData() }}
    
    var onTapChannel: VoidClosure?
    var onTapDateFrom: VoidClosure?
    var onTapDateTo: VoidClosure?
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFilterData()
    }
    
    override func localize() {
        titleL?.text = Localization.filter.localized(Bundle(for: Self.self))
        channelTitleL?.text = Localization.selectChannel.localized(Bundle(for: Self.self))
        dateFromTitleL?.text = Localization.dateFrom.localized(Bundle(for: Self.self))
        dateToTitleL?.text = Localization.dateTo.localized(Bundle(for: Self.self))
    }
    
    override func storyboardName() -> String {
        return "ELProfileUI"
    }
        
    // MARK: - Private
    
    @IBOutlet private weak var titleL: UILabel?
    @IBOutlet private weak var channelTitleL: UILabel?
    @IBOutlet private weak var channelValueL: UILabel?
    @IBOutlet private weak var dateFromTitleL: UILabel?
    @IBOutlet private weak var dateFromValueL: UILabel?
    @IBOutlet private weak var dateToTitleL: UILabel?
    @IBOutlet private weak var dateToValueL: UILabel?
    
    private func setupFilterData() {
        channelValueL?.text = filter?.channel
        dateFromValueL?.text = filter?.dateFrom.stringWithFormat(.MMMddyyyy)
        dateToValueL?.text = filter?.dateTo.stringWithFormat(.MMMddyyyy)
    }
}


 // MARK: - Actions

extension TransactionsFilterViewController {
    
    @IBAction private func selectChannelsBtnDidTap(_ sender: AnyObject?) {
        onTapChannel?()
    }
    
    @IBAction private func dateFromBtnDidTap(_ sender: AnyObject?) {
        onTapDateFrom?()
    }
    
    @IBAction private func dateToBtnDidTap(_ sender: AnyObject?) {
        onTapDateTo?()
    }
}

// MARK: - Localization

private enum Localization: String {
    case filter
    case selectChannel
    case dateFrom
    case dateTo
}
