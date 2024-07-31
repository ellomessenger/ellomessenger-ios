//
//  SettingsViewController.swift
//  _idx_ELFeedUI_2BBFB180_ios_min11.0
//
//

import UIKit
import ELBase
import ElloAppApi
import AccountContext

class FeedSettingsViewController: BaseViewController {
    typealias UpdateFeedFilterItem = Api.functions.feeds.UpdateFeedFilterItem
    typealias AllChannelsWithActiveChannels = (allChannels: [Int], switchedOnChannels: [Int], switchedOnChanged: EventClosure<[Int]>)
    
    // MARK: - Private
    @IBOutlet private weak var titleL: UILabel?
    @IBOutlet private weak var hiddenTitleL: UILabel?
    @IBOutlet private weak var hiddenCountL: UILabel?
    @IBOutlet private weak var pinnedTitleL: UILabel?
    @IBOutlet private weak var pinnedCountL: UILabel?
    @IBOutlet private weak var recommendedTitleL: UILabel?
    @IBOutlet private weak var recommendedStateSW: UISwitch!
    @IBOutlet private weak var onlySubcsriptionTitleL: UILabel?
    @IBOutlet private weak var onlySubcsriptionStateSW: UISwitch!
    @IBOutlet private weak var adultChannelsTitleL: UILabel?
    @IBOutlet private weak var adultChannelsStateSW: UISwitch!
    
    // MARK: - Public
    var filterItem = FeedFilterItem()
    var accountContext: AccountContext!
    var requestManager = RequestsManager()
    
    var onTapHiddenChannels: EventClosure<AllChannelsWithActiveChannels>?
    var onTapPinnedChannels: EventClosure<AllChannelsWithActiveChannels>?
    var onUpdateOptions: EventClosure<FeedFilterItem>?
    var onUpdateFiltersHandler: EventClosure<FeedFilterItem>?
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func localize() {
        titleL?.text = Localization.feedSettings.localized(Bundle(for: Self.self))
        hiddenTitleL?.text = Localization.hiddenChannels.localized(Bundle(for: Self.self))
        pinnedTitleL?.text = Localization.pinnedChannels.localized(Bundle(for: Self.self))
        recommendedTitleL?.text = Localization.showRecommendedChannels.localized(Bundle(for: Self.self))
        onlySubcsriptionTitleL?.text = Localization.showOnlySubscriptionChannels.localized(Bundle(for: Self.self))
        adultChannelsTitleL?.text = Localization.show18PlusChannels.localized(Bundle(for: Self.self))
    }
    
    override func storyboardName() -> String {
        return "ELFeedUI"
    }
    
    private func setupData() {
        hiddenCountL?.text = String(filterItem.hidden.count)
        pinnedCountL?.text = String(filterItem.pinned.count)
        recommendedStateSW?.isOn = filterItem.showRecommended
        onlySubcsriptionStateSW?.isOn = filterItem.showOnlySubscriptions
        adultChannelsStateSW?.isOn = filterItem.showAdult
    }
    
    override func backBtnDidTap(_ sender: AnyObject?) {
        onUpdateFiltersHandler?(filterItem)
        
        super.backBtnDidTap(sender)
    }
}

// MARK: - Actions
extension FeedSettingsViewController {
    
    @IBAction private func hiddenChannelsBtnDidTap(_ sender: AnyObject?) {
        onTapHiddenChannels?(AllChannelsWithActiveChannels(filterItem.all, filterItem.hidden) { [weak self] hiddenObjects in
            self?.filterItem.hidden = hiddenObjects
        })
    }
    
    @IBAction private func pinnedChannelsBtnDidTap(_ sender: AnyObject?) {
        onTapPinnedChannels?(AllChannelsWithActiveChannels(filterItem.all, filterItem.pinned) { [weak self] hiddenObjects in
            self?.filterItem.pinned = hiddenObjects
        })
    }
    
    @IBAction private func switchDidChange(_ sender: UISwitch) {
        switch sender {
        case recommendedStateSW:
            filterItem.showRecommended.toggle()
            filterItem.showOnlySubscriptions = !filterItem.showRecommended
        case onlySubcsriptionStateSW:
            filterItem.showOnlySubscriptions.toggle()
            filterItem.showRecommended = !filterItem.showOnlySubscriptions
        case adultChannelsStateSW:
            filterItem.showAdult.toggle()
        default: break
        }
        
        setupData()
    }
}

// MARK: - Localization
private enum Localization: String {
    case feedSettings
    case hiddenChannels
    case pinnedChannels
    case showRecommendedChannels
    case showOnlySubscriptionChannels
    case show18PlusChannels
}
