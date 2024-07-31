//
//  OnlineCousePeerHeaderActionSheetView.swift
//  _idx_ElloAppCore_886B874C_ios_min14.0
//
//

import UIKit
import AppBundle
import ELBase
import ElloAppCore
import ElloAppPresentationData
import AccountContext
import SwiftSignalKit

final class SubscribePeerHeaderActionSheetView: BaseView {
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var payTypeImageView: UIImageView!
    @IBOutlet var adultImageView: UIImageView! {
        didSet {
            adultImageView.image = UIImage(bundleImageName: "Chat List/PaidChannel/18+Icon")
        }
    }
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var verifiedImageView: UIImageView! {
        didSet {
            verifiedImageView.image = UIImage(bundleImageName: "Item List/PeerVerifiedIcon")
        }
    }
    @IBOutlet var subscribersLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var subscriptionInfoStackView: UIStackView!
    @IBOutlet var payTypeTitleLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var coinImageView: UIImageView! {
        didSet {
            coinImageView.image = UIImage(systemName: "dollarsign")
        }
    }
    @IBOutlet var coursePeriodStackView: UIStackView!
    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var endDateLabel: UILabel!
    @IBOutlet var infoStackView: UIStackView!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var benefitsStackView: UIStackView!
    @IBOutlet var paymentInfoBenefit2Label: UILabel!
    @IBOutlet var paymentInfoBenefitLabel: UILabel!
    @IBOutlet var adultStackView: UIStackView!
    @IBOutlet var adultBackgroundImageView: UIImageView! {
        didSet {
            adultBackgroundImageView.image = UIImage(bundleImageName: "Chat List/PaidChannel/18+Background")
        }
    }
    @IBOutlet var adultIconImageView: UIImageView! {
        didSet {
            adultIconImageView.image = UIImage(bundleImageName: "Chat List/PaidChannel/18+Icon")
        }
    }
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var containerStackView: UIStackView!
    
    private let channel: ElloAppChannel
    private let localizedStrings: PresentationStrings
    private let context: AccountContext
    
    init(channel: ElloAppChannel, localizedStrings: PresentationStrings, context: AccountContext) {
        self.channel = channel
        self.localizedStrings = localizedStrings
        self.context = context
        
        super.init(frame: .zero)
        
        updateUI()
        fillData()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateUI() {
        payTypeImageView.isHidden = channel.isFree
        adultImageView.isHidden = !channel.isAdult
        verifiedImageView.isHidden = !channel.isVerified
        subscriptionInfoStackView.isHidden = channel.isFree
//        infoStackView.isHidden = channel.isFree
        benefitsStackView.isHidden = channel.isAdult && channel.isFree
        adultStackView.isHidden = !channel.isAdult
        coursePeriodStackView.isHidden = !channel.isCourse
        
    }
    
    private func fillData() {
        payTypeImageView.image = UIImage(bundleImageName: channel.payType.payTypeImageName)
        titleLabel.text = channel.title
        _ = (context.account.viewTracker.peerView(channel.id)
         |> deliverOnMainQueue).start { [weak self] peerView in
            guard let cachedData = peerView.cachedData as? CachedChannelData else { return }
            
            self?.descriptionLabel.text = cachedData.about
            self?.descriptionLabel.isHidden = cachedData.about?.isEmpty ?? true
        }
        payTypeTitleLabel.text = channel.payType.payTypeTitleLabel(localizedStrings: localizedStrings)
        
        let priceString = String(format: "%.2f", channel.cost ?? 0.0)
        priceLabel.text = channel.payType.priceText(localizedStrings: localizedStrings, price: priceString)
        
        infoLabel.text = channel.payType.infoText(localizedStrings: localizedStrings)
        if let startDate = channel.startDate {
            startDateLabel.text = Date(timeIntervalSince1970: TimeInterval(startDate)).toString(dateFormat: .MMMddyyyy)
        }
        if let endDate = channel.endDate {
            endDateLabel.text = Date(timeIntervalSince1970: TimeInterval(endDate)).toString(dateFormat: .MMMddyyyy)
        }
        paymentInfoBenefit2Label.text = channel.payType.benefit2(localizedStrings: localizedStrings)
        paymentInfoBenefitLabel.text = channel.payType.benefit3(localizedStrings: localizedStrings)
    }
}

private extension ElloAppChannelPayType {
    var payTypeImageName: String {
        switch self {
        case .free:
            return ""
        case .onlineCourse:
            return "Chat List/PaidChannel/OnlineCourseIcon"
        case .subscription:
            return "Chat List/PaidChannel/SubscriptionIcon"
        }
    }
    
    func payTypeTitleLabel(localizedStrings: PresentationStrings) -> String? {
        switch self {
        case .free:
            return nil
        case .onlineCourse:
            return localizedStrings.OnlineCourse
        case .subscription:
            return localizedStrings.SubscribePeerHeaderActionSheetItem_SubscriptionChannel
        }
    }
    
    func priceText(localizedStrings: PresentationStrings, price: String) -> String? {
        switch self {
        case .free:
            return nil
        case .onlineCourse:
            return localizedStrings.Premium_PricePerOneTime(price).string
        case .subscription:
            return localizedStrings.Premium_PricePerMonth(price).string
        }
    }
    
    func infoText(localizedStrings: PresentationStrings) -> String? {
        switch self {
        case .free:
            return nil
        case .onlineCourse:
            return localizedStrings.SubscribePeerHeaderActionSheetItem_CourseChannel_Info
        case .subscription:
            return localizedStrings.SubscribePeerHeaderActionSheetItem_SubscriptionChannel_Info
        }
    }
    
    func benefit2(localizedStrings: PresentationStrings) -> String? {
        switch self {
        case .free:
            return nil
        case .onlineCourse:
            return localizedStrings.SubscribePeerHeaderActionSheetItem_CourseChannel_Benefits_Item2
        case .subscription:
            return localizedStrings.SubscribePeerHeaderActionSheetItem_SubscriptionChannel_Benefits_Item2
        }
    }
    
    func benefit3(localizedStrings: PresentationStrings) -> String? {
        switch self {
        case .free:
            return nil
        case .onlineCourse:
            return localizedStrings.SubscribePeerHeaderActionSheetItem_CourseChannel_Benefits_Item3
        case .subscription:
            return localizedStrings.SubscribePeerHeaderActionSheetItem_SubscriptionChannel_Benefits_Item3
        }
    }
}
