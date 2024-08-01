import Foundation
import UIKit
import Display
import AsyncDisplayKit
import SwiftSignalKit
import Postbox
import ElloAppCore
import ElloAppPresentationData
import ElloAppUIPreferences
import ItemListUI
import PresentationDataUtils
import OverlayStatusController
import AccountContext
import ShareController
import AlertUI
import PresentationDataUtils
import ElloAppNotices
import ItemListPeerItem
import ItemListPeerActionItem
import AccountContext
import InviteLinksUI
import ContextUI
import UndoUI
import QrCodeUI
import PremiumUI

private final class ChannelVisibilityControllerArguments {
    let context: AccountContext
    let updateCurrentType: (CurrentChannelType, (() -> Void)?) -> Void
    let updatePublicLinkText: (String?, String) -> Void
    let scrollToPublicLinkText: () -> Void
    let setPeerIdWithRevealedOptions: (PeerId?, PeerId?) -> Void
    let revokePeerId: (PeerId) -> Void
    let copyLink: (ExportedInvitation) -> Void
    let shareLink: (ExportedInvitation) -> Void
    let linkContextAction: (ASDisplayNode, ContextGesture?) -> Void
    let manageInviteLinks: () -> Void
    let openLink: (ExportedInvitation) -> Void
    let toggleForwarding: (Bool) -> Void
    let updateJoinToSend: (CurrentChannelJoinToSend) -> Void
    let toggleApproveMembers: (Bool) -> Void

    init(context: AccountContext, 
         updateCurrentType: @escaping (CurrentChannelType, (() -> Void)?) -> Void,
         updatePublicLinkText: @escaping (String?, String) -> Void,
         scrollToPublicLinkText: @escaping () -> Void,
         setPeerIdWithRevealedOptions: @escaping (PeerId?, PeerId?) -> Void,
         revokePeerId: @escaping (PeerId) -> Void,
         copyLink: @escaping (ExportedInvitation) -> Void,
         shareLink: @escaping (ExportedInvitation) -> Void,
         linkContextAction: @escaping (ASDisplayNode, ContextGesture?) -> Void,
         manageInviteLinks: @escaping () -> Void,
         openLink: @escaping (ExportedInvitation) -> Void,
         toggleForwarding: @escaping (Bool) -> Void,
         updateJoinToSend: @escaping (CurrentChannelJoinToSend) -> Void,
         toggleApproveMembers: @escaping (Bool) -> Void) {
        
        self.context = context
        self.updateCurrentType = updateCurrentType
        self.updatePublicLinkText = updatePublicLinkText
        self.scrollToPublicLinkText = scrollToPublicLinkText
        self.setPeerIdWithRevealedOptions = setPeerIdWithRevealedOptions
        self.revokePeerId = revokePeerId
        self.copyLink = copyLink
        self.shareLink = shareLink
        self.linkContextAction = linkContextAction
        self.manageInviteLinks = manageInviteLinks
        self.openLink = openLink
        self.toggleForwarding = toggleForwarding
        self.updateJoinToSend = updateJoinToSend
        self.toggleApproveMembers = toggleApproveMembers
    }
}

private enum ChannelVisibilitySection: Int32 {
    case type
    case limitInfo
    case link
    case linkActions
    case joinToSend
    case approveMembers
    case forwarding
    case image
}

private enum ChannelVisibilityEntryTag: ItemListItemTag {
    case publicLink
    case privateLink
    
    func isEqual(to other: ItemListItemTag) -> Bool {
        if let other = other as? ChannelVisibilityEntryTag, self == other {
            return true
        } else {
            return false
        }
    }
}

private enum ChannelVisibilityEntry: ItemListNodeEntry {
    case typeHeader(PresentationTheme, String)
    case typePublic(PresentationTheme, String, Bool)
    case typePrivate(PresentationTheme, String, Bool)
    case typeSubscription(PresentationTheme, String, Bool)
    case typeOnlineCourse(PresentationTheme, String, Bool)
    case typeInfo(PresentationTheme, String)
    
    case publicLinkHeader(PresentationTheme, String)
    case publicLinkAvailability(PresentationTheme, String, Bool)
    case linksLimitInfo(PresentationTheme, String, Int32, Int32, Int32, Bool)
    case editablePublicLink(PresentationTheme, PresentationStrings, String, String)
    case privateLinkHeader(PresentationTheme, String)
    case privateLink(PresentationTheme, ExportedInvitation?, [EnginePeer], Int32, Bool)
    case privateLinkInfo(PresentationTheme, String)
    case privateLinkManage(PresentationTheme, String)
    case privateLinkManageInfo(PresentationTheme, String)
    
    case publicLinkInfo(PresentationTheme, String)
    case publicLinkStatus(PresentationTheme, String, AddressNameValidationStatus)
    
    case existingLinksInfo(PresentationTheme, String)
    case existingLinkPeerItem(Int32, PresentationTheme, PresentationStrings, PresentationDateTimeFormat, PresentationPersonNameOrder, Peer, ItemListPeerItemEditing, Bool)
    
    case joinToSendHeader(PresentationTheme, String)
    case joinToSendEveryone(PresentationTheme, String, Bool)
    case joinToSendMembers(PresentationTheme, String, Bool)
    
    case approveMembers(PresentationTheme, String, Bool)
    case approveMembersInfo(PresentationTheme, String)
    
    case forwardingHeader(PresentationTheme, String)
    case forwardingDisabled(PresentationTheme, String, Bool)
    case forwardingInfo(PresentationTheme, String)
    case typeDescriptionAnimation(_ name: String)
    case typeDescriptionTitle(PresentationTheme, String)
    case typeDescriptionText(PresentationTheme, String)
    
    var section: ItemListSectionId {
        switch self {
        case .typeHeader, .typePublic, .typePrivate, .typeInfo, .typeSubscription, .typeOnlineCourse:
            return ChannelVisibilitySection.type.rawValue
        case .linksLimitInfo:
            return ChannelVisibilitySection.limitInfo.rawValue
        case .publicLinkHeader, .publicLinkAvailability, .privateLinkHeader, .privateLink, .editablePublicLink, .privateLinkInfo, .publicLinkInfo, .publicLinkStatus:
            return ChannelVisibilitySection.link.rawValue
        case .privateLinkManage, .privateLinkManageInfo:
            return ChannelVisibilitySection.linkActions.rawValue
        case .existingLinksInfo, .existingLinkPeerItem:
            return ChannelVisibilitySection.link.rawValue
        case .joinToSendHeader, .joinToSendEveryone, .joinToSendMembers:
            return ChannelVisibilitySection.joinToSend.rawValue
        case .approveMembers, .approveMembersInfo:
            return ChannelVisibilitySection.approveMembers.rawValue
        case .forwardingHeader, .forwardingDisabled, .forwardingInfo:
            return ChannelVisibilitySection.forwarding.rawValue
        case .typeDescriptionAnimation, .typeDescriptionTitle, .typeDescriptionText:
            return ChannelVisibilitySection.image.rawValue
        }
    }
    
    var stableId: Int32 {
        switch self {
        case .typeHeader:
            return 0
        case .typePublic:
            return 1
        case .typePrivate:
            return 2
        case .typeSubscription:
            return 3
        case .typeOnlineCourse:
            return 4
        case .typeInfo:
            return 5
        case .publicLinkHeader:
            return 6
        case .publicLinkAvailability:
            return 7
        case .linksLimitInfo:
            return 8
        case .privateLinkHeader:
            return 9
        case .privateLink:
            return 10
        case .editablePublicLink:
            return 11
        case .privateLinkInfo:
            return 12
        case .publicLinkStatus:
            return 13
        case .publicLinkInfo:
            return 14
        case .existingLinksInfo:
            return 15
        case let .existingLinkPeerItem(index, _, _, _, _, _, _, _):
            return 16 + index
        case .privateLinkManage:
            return 1000
        case .privateLinkManageInfo:
            return 1001
        case .joinToSendHeader:
            return 1002
        case .joinToSendEveryone:
            return 1003
        case .joinToSendMembers:
            return 1004
        case .approveMembers:
            return 1005
        case .approveMembersInfo:
            return 1006
        case .forwardingHeader:
            return 1007
        case .forwardingDisabled:
            return 1008
        case .forwardingInfo:
            return 1009
        case .typeDescriptionAnimation:
            return 1010
        case .typeDescriptionTitle:
            return 1011
        case .typeDescriptionText:
            return 1012
        }
    }
    
    static func ==(lhs: ChannelVisibilityEntry, rhs: ChannelVisibilityEntry) -> Bool {
        switch lhs {
        case let .typeHeader(lhsTheme, lhsTitle):
            if case let .typeHeader(rhsTheme, rhsTitle) = rhs, lhsTheme === rhsTheme, lhsTitle == rhsTitle {
                return true
            } else {
                return false
            }
        case let .typePublic(lhsTheme, lhsTitle, lhsSelected):
            if case let .typePublic(rhsTheme, rhsTitle, rhsSelected) = rhs, lhsTheme === rhsTheme, lhsTitle == rhsTitle, lhsSelected == rhsSelected {
                return true
            } else {
                return false
            }
        case let .typePrivate(lhsTheme, lhsTitle, lhsSelected):
            if case let .typePrivate(rhsTheme, rhsTitle, rhsSelected) = rhs, lhsTheme === rhsTheme, lhsTitle == rhsTitle, lhsSelected == rhsSelected {
                return true
            } else {
                return false
            }
        case let .typeSubscription(lhsTheme, lhsTitle, lhsSelected):
            if case let .typeSubscription(rhsTheme, rhsTitle, rhsSelected) = rhs, lhsTheme === rhsTheme, lhsTitle == rhsTitle, lhsSelected == rhsSelected {
                return true
            } else {
                return false
            }
        case let .typeOnlineCourse(lhsTheme, lhsTitle, lhsSelected):
            if case let .typeOnlineCourse(rhsTheme, rhsTitle, rhsSelected) = rhs, lhsTheme === rhsTheme, lhsTitle == rhsTitle, lhsSelected == rhsSelected {
                return true
            } else {
                return false
            }
        case let .typeInfo(lhsTheme, lhsText):
            if case let .typeInfo(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .publicLinkHeader(lhsTheme, lhsTitle):
            if case let .publicLinkHeader(rhsTheme, rhsTitle) = rhs, lhsTheme === rhsTheme, lhsTitle == rhsTitle {
                return true
            } else {
                return false
            }
        case let .publicLinkAvailability(lhsTheme, lhsText, lhsValue):
            if case let .publicLinkAvailability(rhsTheme, rhsText, rhsValue) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsValue == rhsValue {
                return true
            } else {
                return false
            }
        case let .linksLimitInfo(lhsTheme, lhsText, lhsCount, lhsLimit, lhsPremiumLimit, lhsIsPremiumDisabled):
            if case let .linksLimitInfo(rhsTheme, rhsText, rhsCount, rhsLimit, rhsPremiumLimit, rhsIsPremiumDisabled) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsCount == rhsCount, lhsLimit == rhsLimit, lhsPremiumLimit == rhsPremiumLimit, lhsIsPremiumDisabled == rhsIsPremiumDisabled {
                return true
            } else {
                return false
            }
        case let .privateLinkHeader(lhsTheme, lhsTitle):
            if case let .privateLinkHeader(rhsTheme, rhsTitle) = rhs, lhsTheme === rhsTheme, lhsTitle == rhsTitle {
                return true
            } else {
                return false
            }
        case let .privateLink(lhsTheme, lhsInvite, lhsPeers, lhsImportersCount, lhsDisplayImporters):
            if case let .privateLink(rhsTheme, rhsInvite, rhsPeers, rhsImportersCount, rhsDisplayImporters) = rhs, lhsTheme === rhsTheme, lhsInvite == rhsInvite, lhsPeers == rhsPeers, lhsImportersCount == rhsImportersCount, lhsDisplayImporters == rhsDisplayImporters {
                return true
            } else {
                return false
            }
        case let .editablePublicLink(lhsTheme, lhsStrings, lhsPlaceholder, lhsCurrentText):
            if case let .editablePublicLink(rhsTheme, rhsStrings, rhsPlaceholder, rhsCurrentText) = rhs, lhsTheme === rhsTheme, lhsStrings === rhsStrings, lhsPlaceholder == rhsPlaceholder, lhsCurrentText == rhsCurrentText {
                return true
            } else {
                return false
            }
        case let .privateLinkInfo(lhsTheme, lhsText):
            if case let .privateLinkInfo(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .privateLinkManage(lhsTheme, lhsText):
            if case let .privateLinkManage(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .privateLinkManageInfo(lhsTheme, lhsText):
            if case let .privateLinkManageInfo(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .publicLinkInfo(lhsTheme, lhsText):
            if case let .publicLinkInfo(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .publicLinkStatus(lhsTheme, lhsText, lhsStatus):
            if case let .publicLinkStatus(rhsTheme, rhsText, rhsStatus) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsStatus == rhsStatus {
                return true
            } else {
                return false
            }
        case let .existingLinksInfo(lhsTheme, lhsText):
            if case let .existingLinksInfo(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .existingLinkPeerItem(lhsIndex, lhsTheme, lhsStrings, lhsDateTimeFormat, lhsNameOrder, lhsPeer, lhsEditing, lhsEnabled):
            if case let .existingLinkPeerItem(rhsIndex, rhsTheme, rhsStrings, rhsDateTimeFormat, rhsNameOrder, rhsPeer, rhsEditing, rhsEnabled) = rhs {
                if lhsIndex != rhsIndex {
                    return false
                }
                if lhsTheme !== rhsTheme {
                    return false
                }
                if lhsStrings !== rhsStrings {
                    return false
                }
                if lhsDateTimeFormat != rhsDateTimeFormat {
                    return false
                }
                if lhsNameOrder != rhsNameOrder {
                    return false
                }
                if !lhsPeer.isEqual(rhsPeer) {
                    return false
                }
                if lhsEditing != rhsEditing {
                    return false
                }
                if lhsEnabled != rhsEnabled {
                    return false
                }
                return true
            } else {
                return false
            }
        case let .joinToSendHeader(lhsTheme, lhsText):
            if case let .joinToSendHeader(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .joinToSendEveryone(lhsTheme, lhsText, lhsValue):
            if case let .joinToSendEveryone(rhsTheme, rhsText, rhsValue) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsValue == rhsValue {
                return true
            } else {
                return false
            }
        case let .joinToSendMembers(lhsTheme, lhsText, lhsValue):
            if case let .joinToSendMembers(rhsTheme, rhsText, rhsValue) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsValue == rhsValue {
                return true
            } else {
                return false
            }
        case let .approveMembers(lhsTheme, lhsText, lhsValue):
            if case let .approveMembers(rhsTheme, rhsText, rhsValue) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsValue == rhsValue {
                return true
            } else {
                return false
            }
        case let .approveMembersInfo(lhsTheme, lhsText):
            if case let .approveMembersInfo(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .forwardingHeader(lhsTheme, lhsText):
            if case let .forwardingHeader(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .forwardingDisabled(lhsTheme, lhsText, lhsValue):
            if case let .forwardingDisabled(rhsTheme, rhsText, rhsValue) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsValue == rhsValue {
                return true
            } else {
                return false
            }
        case let .forwardingInfo(lhsTheme, lhsText):
            if case let .forwardingInfo(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .typeDescriptionAnimation(lhsName):
            if case let .typeDescriptionAnimation(rhsName) = rhs, lhsName == rhsName {
                return true
            }
            
            return false
        case let .typeDescriptionTitle(lhsTheme, lhsTitle):
            if case let .typeDescriptionTitle(rhsTheme, rhsTitle) = rhs, lhsTheme === rhsTheme, lhsTitle == rhsTitle {
                return true
            }
                
            return false
        case let .typeDescriptionText(lhsTheme, lhsTitle):
            if case let .typeDescriptionText(rhsTheme, rhsTitle) = rhs, lhsTheme === rhsTheme, lhsTitle == rhsTitle {
                return true
            }
                
            return false
        }
    }
    
    static func <(lhs: ChannelVisibilityEntry, rhs: ChannelVisibilityEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }
    
    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! ChannelVisibilityControllerArguments
        switch self {
        case let .typeHeader(_, title):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: title, sectionId: self.section)
        case let .typePublic(_, text, selected):
            return ItemListCheckboxItem(presentationData: presentationData, title: text, style: .left, checked: selected, zeroSeparatorInsets: false, sectionId: self.section, action: {
                arguments.updateCurrentType(.publicChannel, nil)
            })
        case let .typePrivate(_, text, selected):
            return ItemListCheckboxItem(presentationData: presentationData, title: text, style: .left, checked: selected, zeroSeparatorInsets: false, sectionId: self.section, action: {
                arguments.updateCurrentType(.privateChannel, nil)
            })
        case let .typeSubscription(_, text, selected):
            return ItemListCheckboxItem(presentationData: presentationData, title: text, style: .left, checked: selected, zeroSeparatorInsets: false, sectionId: self.section, action: {
                arguments.updateCurrentType(.subscriptionChannel, nil)
            })
        case let .typeOnlineCourse(_, text, selected):
            return ItemListCheckboxItem(presentationData: presentationData, title: text, style: .left, checked: selected, zeroSeparatorInsets: false, sectionId: self.section, action: {
                arguments.updateCurrentType(.onlineCourse, nil)
            })
        case let .typeInfo(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .publicLinkHeader(_, title):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: title, sectionId: self.section)
        case let .publicLinkAvailability(theme, text, value):
            let attr = NSMutableAttributedString(string: text, textColor: value ? theme.list.freeTextColor : theme.list.freeTextErrorColor)
            attr.addAttribute(.font, value: Font.regular(13), range: NSMakeRange(0, attr.length))
            return ItemListActivityTextItem(displayActivity: value, presentationData: presentationData, text: attr, sectionId: self.section)
        case let .linksLimitInfo(theme, text, count, limit, premiumLimit, isPremiumDisabled):
            return IncreaseLimitHeaderItem(theme: theme, 
                                           strings: presentationData.strings,
                                           icon: .link,
                                           count: count,
                                           limit: limit,
                                           premiumCount: premiumLimit,
                                           text: text,
                                           isPremiumDisabled: isPremiumDisabled,
                                           sectionId: self.section)
        case let .privateLinkHeader(_, title):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: title, sectionId: self.section)
        case let .privateLink(_, invite, peers, importersCount, displayImporters):
            return ItemListPermanentInviteLinkItem(
                context: arguments.context,
                presentationData: presentationData,
                invite: invite,
                count: importersCount,
                peers: peers,
                displayButton: true,
                displayImporters: displayImporters,
                buttonColor: nil,
                sectionId: self.section,
                style: .blocks,
                copyAction: {
                    if let invite = invite {
                        arguments.copyLink(invite)
                    }
                }, shareAction: {
                    if let invite = invite {
                        arguments.shareLink(invite)
                    }
                }, contextAction: { node, gesture in
                    arguments.linkContextAction(node, gesture)
                }, viewAction: {
                    if let invite = invite {
                        arguments.openLink(invite)
                    }
                })
        case let .editablePublicLink(theme, _, placeholder, currentText):
            return ItemListSingleLineInputItem(
                presentationData: presentationData,
                title: NSAttributedString(
                    string: "@",
                    textColor: UIColor(bundleColorName: "TextGray") ?? theme.list.itemPrimaryTextColor
                ),
                text: currentText,
                textColor: UIColor(bundleColorName: "IconsDark"),
                placeholder: placeholder,
                type: .regular(capitalization: false, autocorrection: false),
                clearType: .always,
                tag: ChannelVisibilityEntryTag.publicLink,
                sectionId: self.section,
                textUpdated: { updatedText in
                    arguments.updatePublicLinkText(currentText, updatedText)
                }, updatedFocus: { focus in
                    if focus {
                        arguments.scrollToPublicLinkText()
                    }
                }, action: { }
            )
        case let .privateLinkInfo(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .privateLinkManage(theme, text):
            return ItemListPeerActionItem(presentationData: presentationData, icon: PresentationResourcesItemList.linkIcon(theme), title: text, sectionId: self.section, height: .compactInsets, editing: false, action: {
                arguments.manageInviteLinks()
            })
        case let .privateLinkManageInfo(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .markdown(text), sectionId: self.section)
        case let .publicLinkInfo(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .markdown(text), sectionId: self.section)
        case let .publicLinkStatus(theme, text, status):
            var displayActivity = false
            let color: UIColor
            switch status {
            case .invalidFormat:
                color = theme.list.freeTextErrorColor
            case let .availability(availability):
                switch availability {
                case .available:
                    color = theme.list.freeTextSuccessColor
                case .invalid:
                    color = theme.list.freeTextErrorColor
                case .taken:
                    color = theme.list.freeTextErrorColor
                }
            case .checking:
                color = theme.list.freeTextColor
                displayActivity = true
            }
            return ItemListActivityTextItem(displayActivity: displayActivity, presentationData: presentationData, text: NSAttributedString(string: text, textColor: color), sectionId: self.section)
        case let .existingLinksInfo(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .existingLinkPeerItem(_, _, _, dateTimeFormat, nameDisplayOrder, peer, editing, enabled):
            var label = ""
            if let addressName = peer.addressName {
                label = "https://ello.team/" + addressName
            }
            
            return ItemListPeerItem(presentationData: presentationData,
                                    dateTimeFormat: dateTimeFormat,
                                    nameDisplayOrder: nameDisplayOrder,
                                    context: arguments.context,
                                    peer: EnginePeer(peer),
                                    presence: nil,
                                    text: .text(label, .secondary),
                                    label: .none,
                                    editing: editing,
                                    switchValue: nil,
                                    enabled: enabled,
                                    selectable: true,
                                    sectionId: self.section,
                                    action: nil,
                                    setPeerIdWithRevealedOptions: { previousId, id in
                arguments.setPeerIdWithRevealedOptions(previousId, id)
            }, removePeer: { peerId in
                arguments.revokePeerId(peerId)
            })
        case let .joinToSendHeader(_, title):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: title, sectionId: self.section)
        case let .joinToSendEveryone(_, text, selected):
            return ItemListCheckboxItem(presentationData: presentationData, title: text, style: .left, checked: selected, zeroSeparatorInsets: false, sectionId: self.section, action: {
                arguments.updateJoinToSend(.everyone)
                arguments.toggleApproveMembers(false)
            })
        case let .joinToSendMembers(_, text, selected):
            return ItemListCheckboxItem(presentationData: presentationData, title: text, style: .left, checked: selected, zeroSeparatorInsets: false, sectionId: self.section, action: {
                arguments.updateJoinToSend(.members)
            })
        case let .approveMembers(_, text, selected):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: selected, sectionId: self.section, style: .blocks, updated: { value in
                arguments.toggleApproveMembers(value)
            })
        case let .approveMembersInfo(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .forwardingHeader(_, title):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: title, sectionId: self.section)
        case let .forwardingDisabled(_, text, selected):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: selected, sectionId: self.section, style: .blocks, updated: { value in
                arguments.toggleForwarding(!value)
            })
        case let .forwardingInfo(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .typeDescriptionAnimation(name):
            return ItemListAnimationItem(name: name, sectionId: section)
        case let .typeDescriptionTitle(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .custom(fontSize: 24.0, weight: .semibold, text: text, color: UIColor(hexString: "#070708")), sectionId: section, alignment: .center)
        case let .typeDescriptionText(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .custom(fontSize: 16.0, weight: .regular, text: text, color: UIColor(hexString: "#929298")), sectionId: section)
        }
    }
}

private enum CurrentChannelType {
    case publicChannel
    case privateChannel
    case subscriptionChannel
    case onlineCourse
}

private enum CurrentChannelLocation: Equatable {
    case removed
    case location(PeerGeoLocation)
}

private enum CurrentChannelJoinToSend {
    case everyone
    case members
}

private struct ChannelVisibilityControllerState: Equatable {
    let selectedType: CurrentChannelType?
    let editingPublicLinkText: String?
    let addressNameValidationStatus: AddressNameValidationStatus?
    let updatingAddressName: Bool
    let revealedRevokePeerId: PeerId?
    let revokingPeerId: PeerId?
    let revokingPrivateLink: Bool
    let forwardingEnabled: Bool?
    let joinToSend: CurrentChannelJoinToSend?
    let approveMembers: Bool?
    
    init() {
        self.selectedType = nil
        self.editingPublicLinkText = nil
        self.addressNameValidationStatus = nil
        self.updatingAddressName = false
        self.revealedRevokePeerId = nil
        self.revokingPeerId = nil
        self.revokingPrivateLink = false
        self.forwardingEnabled = nil
        self.joinToSend = nil
        self.approveMembers = nil
    }
    
    init(selectedType: CurrentChannelType?, editingPublicLinkText: String?, addressNameValidationStatus: AddressNameValidationStatus?, updatingAddressName: Bool, revealedRevokePeerId: PeerId?, revokingPeerId: PeerId?, revokingPrivateLink: Bool, forwardingEnabled: Bool?, joinToSend: CurrentChannelJoinToSend?, approveMembers: Bool?) {
        self.selectedType = selectedType
        self.editingPublicLinkText = editingPublicLinkText
        self.addressNameValidationStatus = addressNameValidationStatus
        self.updatingAddressName = updatingAddressName
        self.revealedRevokePeerId = revealedRevokePeerId
        self.revokingPeerId = revokingPeerId
        self.revokingPrivateLink = revokingPrivateLink
        self.forwardingEnabled = forwardingEnabled
        self.joinToSend = joinToSend
        self.approveMembers = approveMembers
    }
    
    static func ==(lhs: ChannelVisibilityControllerState, rhs: ChannelVisibilityControllerState) -> Bool {
        if lhs.selectedType != rhs.selectedType {
            return false
        }
        if lhs.editingPublicLinkText != rhs.editingPublicLinkText {
            return false
        }
        if lhs.addressNameValidationStatus != rhs.addressNameValidationStatus {
            return false
        }
        if lhs.updatingAddressName != rhs.updatingAddressName {
            return false
        }
        if lhs.revealedRevokePeerId != rhs.revealedRevokePeerId {
            return false
        }
        if lhs.revokingPeerId != rhs.revokingPeerId {
            return false
        }
        if lhs.revokingPrivateLink != rhs.revokingPrivateLink {
            return false
        }
        if lhs.forwardingEnabled != rhs.forwardingEnabled {
            return false
        }
        if lhs.joinToSend != rhs.joinToSend {
            return false
        }
        if lhs.approveMembers != rhs.approveMembers {
            return false
        }
        return true
    }
    
    func withUpdatedSelectedType(_ selectedType: CurrentChannelType?) -> ChannelVisibilityControllerState {
        return ChannelVisibilityControllerState(selectedType: selectedType, editingPublicLinkText: self.editingPublicLinkText, addressNameValidationStatus: self.addressNameValidationStatus, updatingAddressName: self.updatingAddressName, revealedRevokePeerId: self.revealedRevokePeerId, revokingPeerId: self.revokingPeerId, revokingPrivateLink: self.revokingPrivateLink, forwardingEnabled: self.forwardingEnabled, joinToSend: self.joinToSend, approveMembers: self.approveMembers)
    }
    
    func withUpdatedEditingPublicLinkText(_ editingPublicLinkText: String?) -> ChannelVisibilityControllerState {
        return ChannelVisibilityControllerState(selectedType: self.selectedType, editingPublicLinkText: editingPublicLinkText, addressNameValidationStatus: self.addressNameValidationStatus, updatingAddressName: self.updatingAddressName, revealedRevokePeerId: self.revealedRevokePeerId, revokingPeerId: self.revokingPeerId, revokingPrivateLink: self.revokingPrivateLink, forwardingEnabled: self.forwardingEnabled, joinToSend: self.joinToSend, approveMembers: self.approveMembers)
    }
    
    func withUpdatedAddressNameValidationStatus(_ addressNameValidationStatus: AddressNameValidationStatus?) -> ChannelVisibilityControllerState {
        return ChannelVisibilityControllerState(selectedType: self.selectedType, editingPublicLinkText: self.editingPublicLinkText, addressNameValidationStatus: addressNameValidationStatus, updatingAddressName: self.updatingAddressName, revealedRevokePeerId: self.revealedRevokePeerId, revokingPeerId: self.revokingPeerId, revokingPrivateLink: self.revokingPrivateLink, forwardingEnabled: self.forwardingEnabled, joinToSend: self.joinToSend, approveMembers: self.approveMembers)
    }
    
    func withUpdatedUpdatingAddressName(_ updatingAddressName: Bool) -> ChannelVisibilityControllerState {
        return ChannelVisibilityControllerState(selectedType: self.selectedType, editingPublicLinkText: self.editingPublicLinkText, addressNameValidationStatus: self.addressNameValidationStatus, updatingAddressName: updatingAddressName, revealedRevokePeerId: self.revealedRevokePeerId, revokingPeerId: self.revokingPeerId, revokingPrivateLink: self.revokingPrivateLink, forwardingEnabled: self.forwardingEnabled, joinToSend: self.joinToSend, approveMembers: self.approveMembers)
    }
    
    func withUpdatedRevealedRevokePeerId(_ revealedRevokePeerId: PeerId?) -> ChannelVisibilityControllerState {
        return ChannelVisibilityControllerState(selectedType: self.selectedType, editingPublicLinkText: self.editingPublicLinkText, addressNameValidationStatus: self.addressNameValidationStatus, updatingAddressName: updatingAddressName, revealedRevokePeerId: revealedRevokePeerId, revokingPeerId: self.revokingPeerId, revokingPrivateLink: self.revokingPrivateLink, forwardingEnabled: self.forwardingEnabled, joinToSend: self.joinToSend, approveMembers: self.approveMembers)
    }
    
    func withUpdatedRevokingPeerId(_ revokingPeerId: PeerId?) -> ChannelVisibilityControllerState {
        return ChannelVisibilityControllerState(selectedType: self.selectedType, editingPublicLinkText: self.editingPublicLinkText, addressNameValidationStatus: self.addressNameValidationStatus, updatingAddressName: updatingAddressName, revealedRevokePeerId: self.revealedRevokePeerId, revokingPeerId: revokingPeerId, revokingPrivateLink: self.revokingPrivateLink, forwardingEnabled: self.forwardingEnabled, joinToSend: self.joinToSend, approveMembers: self.approveMembers)
    }
    
    func withUpdatedRevokingPrivateLink(_ revokingPrivateLink: Bool) -> ChannelVisibilityControllerState {
        return ChannelVisibilityControllerState(selectedType: self.selectedType, editingPublicLinkText: self.editingPublicLinkText, addressNameValidationStatus: self.addressNameValidationStatus, updatingAddressName: updatingAddressName, revealedRevokePeerId: self.revealedRevokePeerId, revokingPeerId: self.revokingPeerId, revokingPrivateLink: revokingPrivateLink, forwardingEnabled: self.forwardingEnabled, joinToSend: self.joinToSend, approveMembers: self.approveMembers)
    }
    
    func withUpdatedForwardingEnabled(_ forwardingEnabled: Bool) -> ChannelVisibilityControllerState {
        return ChannelVisibilityControllerState(selectedType: self.selectedType, editingPublicLinkText: self.editingPublicLinkText, addressNameValidationStatus: self.addressNameValidationStatus, updatingAddressName: updatingAddressName, revealedRevokePeerId: self.revealedRevokePeerId, revokingPeerId: self.revokingPeerId, revokingPrivateLink: self.revokingPrivateLink, forwardingEnabled: forwardingEnabled, joinToSend: self.joinToSend, approveMembers: self.approveMembers)
    }
    
    func withUpdatedJoinToSend(_ joinToSend: CurrentChannelJoinToSend?) -> ChannelVisibilityControllerState {
        return ChannelVisibilityControllerState(selectedType: self.selectedType, editingPublicLinkText: self.editingPublicLinkText, addressNameValidationStatus: self.addressNameValidationStatus, updatingAddressName: updatingAddressName, revealedRevokePeerId: self.revealedRevokePeerId, revokingPeerId: self.revokingPeerId, revokingPrivateLink: self.revokingPrivateLink, forwardingEnabled: self.forwardingEnabled, joinToSend: joinToSend, approveMembers: self.approveMembers)
    }
    
    func withUpdatedApproveMembers(_ approveMembers: Bool) -> ChannelVisibilityControllerState {
        return ChannelVisibilityControllerState(selectedType: self.selectedType, editingPublicLinkText: self.editingPublicLinkText, addressNameValidationStatus: self.addressNameValidationStatus, updatingAddressName: updatingAddressName, revealedRevokePeerId: self.revealedRevokePeerId, revokingPeerId: self.revokingPeerId, revokingPrivateLink: self.revokingPrivateLink, forwardingEnabled: self.forwardingEnabled, joinToSend: self.joinToSend, approveMembers: approveMembers)
    }
}

private func channelVisibilityControllerEntries(peerId: PeerId, 
                                                presentationData: PresentationData,
                                                mode: ChannelVisibilityControllerMode,
                                                view: PeerView,
                                                publicChannelsToRevoke: [Peer]?,
                                                importers: PeerInvitationImportersState?,
                                                state: ChannelVisibilityControllerState,
                                                limits: EngineConfiguration.UserLimits,
                                                premiumLimits: EngineConfiguration.UserLimits,
                                                isPremium: Bool,
                                                isPremiumDisabled: Bool) -> [ChannelVisibilityEntry] {
    var entries: [ChannelVisibilityEntry] = []
    
    let isInitialSetup: Bool
    if case .initialSetup = mode {
        isInitialSetup = true
    } else {
        isInitialSetup = false
    }
    
    let peer = view.peers[view.peerId] ?? peer(with: peerId, presentationData: presentationData)
    if let peer = peer as? ElloAppChannel {
        var isGroup = false
        if case .group = peer.info {
            isGroup = true
        }
        
        let selectedType: CurrentChannelType
        if case .privateLink = mode {
            selectedType = .privateChannel
        } else {
            if let current = state.selectedType {
                selectedType = current
            } else {
                if peer.isSubscription {
                    selectedType = .subscriptionChannel
                } else if peer.isCourse {
                    selectedType = .onlineCourse
                } else if let addressName = peer.addressName, !addressName.isEmpty {
                    selectedType = .publicChannel
                } else if let cachedChannelData = view.cachedData as? CachedChannelData, cachedChannelData.peerGeoLocation != nil  {
                    selectedType = .publicChannel
                } else if case .initialSetup = mode {
                    selectedType = .publicChannel
                } else if case .initialSetupOnlineCourse = mode {
                    selectedType = .onlineCourse
                } else {
                    selectedType = .privateChannel
                }
            }
        }
        
        let joinToSend: CurrentChannelJoinToSend
        if let current = state.joinToSend {
            joinToSend = current
        } else {
            if peer.flags.contains(.joinToSend) {
                joinToSend = .members
            } else {
                joinToSend = .everyone
            }
        }
        
//        let approveMembers: Bool
//        if let enabled = state.approveMembers {
//            approveMembers = enabled
//        } else {
//            if peer.flags.contains(.requestToJoin) {
//                approveMembers = true
//            } else {
//                approveMembers = false
//            }
//        }
        
        let forwardingEnabled: Bool
        if let enabled = state.forwardingEnabled {
            forwardingEnabled = enabled
        } else {
            if peer.flags.contains(.copyProtectionEnabled) {
                forwardingEnabled = false
            } else {
                forwardingEnabled = true
            }
        }
        
        let currentAddressName: String
        if let current = state.editingPublicLinkText {
            currentAddressName = current
        } else {
            if let addressName = peer.addressName {
                currentAddressName = addressName
            } else {
                currentAddressName = ""
            }
        }
        
        if (view.cachedData as? CachedChannelData)?.peerGeoLocation == nil {
            switch mode {
            case .privateLink, .revokeNames:
                break
            case .initialSetup:
                if selectedType == .onlineCourse {
                    entries.append(.typeOnlineCourse(presentationData.theme, presentationData.strings.Channel_Setup_TypeOnlineCourse, true))
                } else {
                    entries.append(.typeHeader(presentationData.theme, isGroup ? presentationData.strings.Group_Setup_TypeHeader.uppercased() : presentationData.strings.Channel_Setup_TypeHeader.uppercased()))
                    entries.append(.typePublic(presentationData.theme, isGroup ? presentationData.strings.Group_Setup_TypePublic : presentationData.strings.Channel_Setup_LinkTypePublic, selectedType == .publicChannel))
                    entries.append(.typePrivate(presentationData.theme, isGroup ? presentationData.strings.Group_Setup_TypePrivate : presentationData.strings.Channel_Setup_LinkTypePrivate, selectedType == .privateChannel))
                    if !isGroup {
                        entries.append(.typeSubscription(presentationData.theme, presentationData.strings.Channel_Setup_TypeSubscription, selectedType == .subscriptionChannel))
                    }
                }
                
                switch selectedType {
                case .publicChannel:
                    if isGroup {
                        entries.append(.typeInfo(presentationData.theme, presentationData.strings.Group_Setup_TypePublicHelp))
                    } else {
                        entries.append(.typeInfo(presentationData.theme, presentationData.strings.Channel_Setup_TypePublicHelp))
                    }
                case .privateChannel:
                    if isGroup {
                        entries.append(.typeInfo(presentationData.theme, presentationData.strings.Group_Setup_TypePrivateHelp))
                    } else {
                        entries.append(.typeInfo(presentationData.theme, presentationData.strings.Channel_Setup_TypePrivateHelp))
                    }
                case .subscriptionChannel:
                    entries.append(.typeInfo(presentationData.theme, presentationData.strings.Channel_Setup_TypeSubscriptionHelp))
                case .onlineCourse:
                    entries.append(.typeInfo(presentationData.theme, presentationData.strings.Channel_Setup_TypeOnlineCourseHelp))
                }
            case .generic:
                if isGroup {
                    entries.append(
                        .typeHeader(presentationData.theme, presentationData.strings.Group_Setup_TypeHeader.uppercased())
                    )
                } else {
                    if selectedType != .onlineCourse {
                        entries.append(
                            .typeHeader(presentationData.theme, presentationData.strings.Channel_Setup_TypeHeader.uppercased())
                        )
                    }
                }
                
                switch selectedType {
                case .publicChannel:
                    if isGroup {
                        entries.append(.typePublic(presentationData.theme, presentationData.strings.Group_Setup_TypePublic, selectedType == .publicChannel))
                        entries.append(.typePrivate(presentationData.theme, presentationData.strings.Group_Setup_TypePrivate, selectedType == .privateChannel))
                        entries.append(.typeInfo(presentationData.theme, presentationData.strings.Group_Setup_TypePublicHelp))
                    } else {
                        entries.append(.typePublic(presentationData.theme, presentationData.strings.Channel_Setup_LinkTypePublic, selectedType == .publicChannel))
                        entries.append(.typePrivate(presentationData.theme, presentationData.strings.Channel_Setup_LinkTypePrivate, selectedType == .privateChannel))
                        entries.append(.typeInfo(presentationData.theme, presentationData.strings.Channel_Setup_TypePublicHelp))
                    }
                case .privateChannel:
                    if isGroup {
                        entries.append(.typePublic(presentationData.theme, presentationData.strings.Group_Setup_TypePublic, selectedType == .publicChannel))
                        entries.append(.typePrivate(presentationData.theme, presentationData.strings.Group_Setup_TypePrivate, selectedType == .privateChannel))
                        entries.append(.typeInfo(presentationData.theme, presentationData.strings.Group_Setup_TypePrivateHelp))
                    } else {
                        entries.append(.typePublic(presentationData.theme, presentationData.strings.Channel_Setup_LinkTypePublic, selectedType == .publicChannel))
                        entries.append(.typePrivate(presentationData.theme, presentationData.strings.Channel_Setup_LinkTypePrivate, selectedType == .privateChannel))
                        entries.append(.typeInfo(presentationData.theme, presentationData.strings.Channel_Setup_TypePrivateHelp))
                    }
                case .subscriptionChannel:
                    entries.append(.typeSubscription(presentationData.theme, presentationData.strings.Channel_Setup_TypeSubscription, selectedType == .subscriptionChannel))
                    entries.append(.typeInfo(presentationData.theme, presentationData.strings.Channel_Setup_TypeSubscriptionHelp))
                case .onlineCourse:
                    entries.append(.typeOnlineCourse(presentationData.theme, presentationData.strings.Channel_Setup_TypeOnlineCourse, true))
                    entries.append(.typeInfo(presentationData.theme, presentationData.strings.Channel_Setup_TypeOnlineCourseHelp))
                }
            case .initialSetupOnlineCourse:
                entries.append(.typeOnlineCourse(presentationData.theme, presentationData.strings.Compose_NewOnlineCourse, true))
                entries.append(.typeInfo(presentationData.theme, presentationData.strings.Channel_Setup_TypeOnlineCourseHelp))
            }
        }
        
        if case .revokeNames = mode {
            let count = Int32(publicChannelsToRevoke?.count ?? 0)
            
            let text: String
            if count >= premiumLimits.maxPublicLinksCount {
                text = presentationData.strings.Group_Username_RemoveExistingUsernamesFinalInfo
            } else {
                if isPremiumDisabled {
                    text = presentationData.strings.Group_Username_RemoveExistingUsernamesNoPremiumInfo
                } else {
                    text = presentationData.strings.Group_Username_RemoveExistingUsernamesOrExtendInfo("\(premiumLimits.maxPublicLinksCount)").string
                }
            }
            
            entries.append(.linksLimitInfo(presentationData.theme, text, count, limits.maxPublicLinksCount, premiumLimits.maxPublicLinksCount, isPremiumDisabled))
            
            if let publicChannelsToRevoke = publicChannelsToRevoke {
                var index: Int32 = 0
                for peer in publicChannelsToRevoke.sorted(by: { lhs, rhs in
                    var lhsDate: Int32 = 0
                    var rhsDate: Int32 = 0
                    if let lhs = lhs as? ElloAppChannel {
                        lhsDate = lhs.creationDate
                    }
                    if let rhs = rhs as? ElloAppChannel {
                        rhsDate = rhs.creationDate
                    }
                    return lhsDate > rhsDate
                }) {
                    entries.append(.existingLinkPeerItem(index, 
                                                         presentationData.theme,
                                                         presentationData.strings,
                                                         presentationData.dateTimeFormat,
                                                         presentationData.nameDisplayOrder,
                                                         peer,
                                                         ItemListPeerItemEditing(editable: false, // true,
                                                                                 editing: false, //true,
                                                                                 revealed: false), // state.revealedRevokePeerId == peer.id),
                                                         state.revokingPeerId == nil))
                    index += 1
                }
            }
        } else {
            switch selectedType {
            case .publicChannel:
                if case .initialSetup = mode {
                    entries.append(.publicLinkHeader(presentationData.theme, isGroup ? presentationData.strings.Group_Setup_PublicLink.uppercased() : presentationData.strings.Channel_Setup_PublicLink.uppercased()))
                }
                entries.append(.editablePublicLink(
                        presentationData.theme,
                        presentationData.strings,
                        isGroup ? presentationData.strings.Group_PublicLink_Placeholder : presentationData.strings.Channel_PublicLink_Placeholder,
                        currentAddressName))
                if let status = state.addressNameValidationStatus {
                    let text: String
                    switch status {
                    case let .invalidFormat(error):
                        switch error {
                        case .startsWithDigit:
                            if isGroup {
                                text = presentationData.strings.Group_Username_InvalidStartsWithNumber
                            } else {
                                text = presentationData.strings.Channel_Username_InvalidStartsWithNumber
                            }
                        case .startsWithUnderscore:
                            if isGroup {
                                text = presentationData.strings.Group_Username_InvalidStartsWithUnderscore
                            } else {
                                text = presentationData.strings.Channel_Username_InvalidStartsWithUnderscore
                            }
                        case .endsWithUnderscore:
                            if isGroup {
                                text = presentationData.strings.Group_Username_InvalidEndsWithUnderscore
                            } else {
                                text = presentationData.strings.Channel_Username_InvalidEndsWithUnderscore
                            }
                        case .tooShort:
                            if isGroup {
                                text = presentationData.strings.Group_Username_InvalidTooShort
                            } else {
                                text = presentationData.strings.Channel_Username_InvalidTooShort
                            }
                        case .invalidCharacters:
                            text = presentationData.strings.Channel_Username_InvalidCharacters
                        }
                    case let .availability(availability):
                        switch availability {
                        case .available:
                            text = presentationData.strings.Channel_Username_UsernameIsFree
                        case .invalid:
                            text = presentationData.strings.Channel_Username_InvalidCharacters
                        case .taken:
                            text = presentationData.strings.Channel_Username_InvalidTaken
                        }
                    case .checking:
                        text = presentationData.strings.Channel_Username_CheckingUsername
                    }
                    
                    entries.append(.publicLinkStatus(presentationData.theme, text, status))
                }
                if isGroup {
                    if let cachedChannelData = view.cachedData as? CachedChannelData, cachedChannelData.peerGeoLocation != nil {
                        entries.append(.publicLinkInfo(presentationData.theme, presentationData.strings.Group_PublicLink_Info))
                    } else {
                        entries.append(.publicLinkInfo(presentationData.theme, presentationData.strings.Group_Username_CreatePublicLinkHelp))
                    }
                } else {
                    entries.append(.publicLinkInfo(presentationData.theme, presentationData.strings.Channel_Username_CreatePublicLinkHelp))
                }
                
                switch mode {
                case .initialSetup:
                    entries.append(.typeDescriptionAnimation("anim_public_channel"))
                    entries.append(.typeDescriptionTitle(presentationData.theme, presentationData.strings.PublicChannel_Setup_TypeDescriptionTitle))
                    entries.append(.typeDescriptionText(presentationData.theme, presentationData.strings.PublicChannel_Setup_TypeDescriptionText))
                case .revokeNames:
                    break
                case .generic, .privateLink:
                    if peer.isFree {
                        entries.append(.privateLinkManage(presentationData.theme, presentationData.strings.InviteLink_Manage))
                        entries.append(.privateLinkManageInfo(presentationData.theme, presentationData.strings.InviteLink_CreateInfo))
                    }
                case .initialSetupOnlineCourse:
                    break
                }
            case .subscriptionChannel:
                if case .initialSetup = mode {
                    entries.append(.publicLinkHeader(
                        presentationData.theme,
                        presentationData.strings.Channel_Setup_PublicLink.uppercased()))
                }
                entries.append(.editablePublicLink(
                    presentationData.theme,
                    presentationData.strings,
                    presentationData.strings.Channel_PublicLink_Placeholder,
                    currentAddressName))
                if let status = state.addressNameValidationStatus {
                    let text: String
                    switch status {
                    case let .invalidFormat(error):
                        switch error {
                        case .startsWithDigit:
                            text = presentationData.strings.Channel_Username_InvalidStartsWithNumber
                        case .startsWithUnderscore:
                            text = presentationData.strings.Channel_Username_InvalidStartsWithUnderscore
                        case .endsWithUnderscore:
                            
                            text = presentationData.strings.Channel_Username_InvalidEndsWithUnderscore
                        case .tooShort:
                            text = presentationData.strings.Channel_Username_InvalidTooShort
                        case .invalidCharacters:
                            text = presentationData.strings.Channel_Username_InvalidCharacters
                        }
                    case let .availability(availability):
                        switch availability {
                        case .available:
                            text = presentationData.strings.Channel_Username_UsernameIsFree
                        case .invalid:
                            text = presentationData.strings.Channel_Username_InvalidCharacters
                        case .taken:
                            text = presentationData.strings.Channel_Username_InvalidTaken
                        }
                    case .checking:
                        text = presentationData.strings.Channel_Username_CheckingUsername
                    }
                    
                    entries.append(.publicLinkStatus(presentationData.theme, text, status))
                }
                entries.append(.publicLinkInfo(presentationData.theme, presentationData.strings.Channel_Username_CreateSubscriptionLinkHelp))
                
                switch mode {
                case .initialSetup:
                    entries.append(.typeDescriptionAnimation("anim_subscription_channel"))
                    entries.append(.typeDescriptionTitle(presentationData.theme, presentationData.strings.SubscriptionChannel_Setup_TypeDescriptionTitle))
                    entries.append(.typeDescriptionText(presentationData.theme, presentationData.strings.SubscriptionChannel_Setup_TypeDescriptionText))
                case .revokeNames:
                    break
                case .generic, .privateLink:
                    if peer.isFree {
                        entries.append(.privateLinkManage(presentationData.theme, presentationData.strings.InviteLink_Manage))
                        entries.append(.privateLinkManageInfo(presentationData.theme, presentationData.strings.InviteLink_CreateInfo))
                    }
                case .initialSetupOnlineCourse:
                    break
                }
            case .privateChannel:
                switch mode {
                case .initialSetup:
                    entries.append(.typeDescriptionAnimation("anim_private_channel"))
                    entries.append(.typeDescriptionTitle(presentationData.theme, presentationData.strings.PrivateChannel_Setup_TypeDescriptionTitle))
                    entries.append(.typeDescriptionText(presentationData.theme, presentationData.strings.PrivateChannel_Setup_TypeDescriptionText))
                case .revokeNames:
                    break
                case .generic, .privateLink:
                    entries.append(.privateLinkHeader(presentationData.theme, presentationData.strings.InviteLink_InviteLink.uppercased()))
                    let invite = (view.cachedData as? CachedChannelData)?.exportedInvitation // state.selectedType
                    entries.append(.privateLink(presentationData.theme, invite, importers?.importers.prefix(3).compactMap { $0.peer.peer.flatMap(EnginePeer.init) } ?? [], importers?.count ?? 0, !isInitialSetup))
                    
                    if isGroup {
                        entries.append(.privateLinkInfo(presentationData.theme, presentationData.strings.Group_Username_CreatePrivateLinkHelp))
                    } else {
                        entries.append(.privateLinkInfo(presentationData.theme, presentationData.strings.Channel_Username_CreatePrivateLinkHelp))
                    }
                    
                    if peer.isFree {
                        entries.append(.privateLinkManage(presentationData.theme, presentationData.strings.InviteLink_Manage))
                        entries.append(.privateLinkManageInfo(presentationData.theme, presentationData.strings.InviteLink_CreateInfo))
                    }
                case .initialSetupOnlineCourse:
                    break
                }
            case .onlineCourse:
                switch mode {
                case .initialSetup, .initialSetupOnlineCourse:
                    entries.append(.publicLinkHeader(
                        presentationData.theme,
                        presentationData.strings.Channel_Setup_PublicLink.uppercased()))
                default:
                    break
                }
                entries.append(.editablePublicLink(presentationData.theme, presentationData.strings, presentationData.strings.Channel_CourseLink_Placeholder, currentAddressName))
                if let status = state.addressNameValidationStatus {
                    let text: String
                    switch status {
                    case let .invalidFormat(error):
                        switch error {
                        case .startsWithDigit:
                            text = presentationData.strings.Channel_Username_InvalidStartsWithNumber
                        case .startsWithUnderscore:
                            text = presentationData.strings.Channel_Username_InvalidStartsWithUnderscore
                        case .endsWithUnderscore:
                            text = presentationData.strings.Channel_Username_InvalidEndsWithUnderscore
                        case .tooShort:
                            text = presentationData.strings.Channel_Username_InvalidTooShort
                        case .invalidCharacters:
                            text = presentationData.strings.Channel_Username_InvalidCharacters
                        }
                    case let .availability(availability):
                        switch availability {
                        case .available:
                            text = presentationData.strings.Channel_Username_UsernameIsFree
                        case .invalid:
                            text = presentationData.strings.Channel_Username_InvalidCharacters
                        case .taken:
                            text = presentationData.strings.Channel_Username_InvalidTaken
                        }
                    case .checking:
                        text = presentationData.strings.Channel_Username_CheckingUsername
                    }
                    
                    entries.append(.publicLinkStatus(presentationData.theme, text, status))
                }
                entries.append(.publicLinkInfo(presentationData.theme, presentationData.strings.Channel_Username_CreateOnlineCourseLinkHelp))
                
                switch mode {
                case .initialSetup:
                    break
                case .revokeNames:
                    break
                case .generic, .privateLink:
                    if peer.isFree {
                        entries.append(.privateLinkManage(presentationData.theme, presentationData.strings.InviteLink_Manage))
                        entries.append(.privateLinkManageInfo(presentationData.theme, presentationData.strings.InviteLink_CreateInfo))
                    }
                case .initialSetupOnlineCourse:
                    entries.append(.typeDescriptionAnimation("anim_online_course"))
                    entries.append(.typeDescriptionTitle(presentationData.theme, presentationData.strings.OnlineCourse_Setup_TypeDescriptionTitle))
                    entries.append(.typeDescriptionText(presentationData.theme, presentationData.strings.OnlineCourse_Setup_TypeDescriptionText))
                }
            }
                        
            var isDiscussion = false
            if let cachedData = view.cachedData as? CachedChannelData, case let .known(peerId) = cachedData.linkedDiscussionPeerId, peerId != nil {
                isDiscussion = true
            }
            
            if isGroup && (selectedType == .publicChannel || isDiscussion) {
                if isDiscussion {
                    entries.append(.joinToSendHeader(presentationData.theme, presentationData.strings.Group_Setup_WhoCanSendMessages_Title.uppercased()))
                    entries.append(.joinToSendEveryone(presentationData.theme, presentationData.strings.Group_Setup_WhoCanSendMessages_Everyone, joinToSend == .everyone))
                    entries.append(.joinToSendMembers(presentationData.theme, presentationData.strings.Group_Setup_WhoCanSendMessages_OnlyMembers, joinToSend == .members))
                }
                    
//                if !isDiscussion || joinToSend == .members {
//                    entries.append(.approveMembers(presentationData.theme, presentationData.strings.Group_Setup_ApproveNewMembers, approveMembers))
//                    entries.append(.approveMembersInfo(presentationData.theme, presentationData.strings.Group_Setup_ApproveNewMembersInfo))
//                }
            }
            
            switch mode {
            case .initialSetup, .initialSetupOnlineCourse:
                break
            default:
                switch selectedType {
                case .publicChannel, .privateChannel:
                    entries.append(.forwardingHeader(presentationData.theme, isGroup ? presentationData.strings.Group_Setup_ForwardingGroupTitle.uppercased() : presentationData.strings.Group_Setup_ForwardingChannelTitle.uppercased()))
                    entries.append(.forwardingDisabled(presentationData.theme, presentationData.strings.Group_Setup_ForwardingDisabled, !forwardingEnabled))
                    entries.append(.forwardingInfo(presentationData.theme, forwardingEnabled ? (isGroup ? presentationData.strings.Group_Setup_ForwardingGroupInfo : presentationData.strings.Group_Setup_ForwardingChannelInfo) : (isGroup ? presentationData.strings.Group_Setup_ForwardingGroupInfoDisabled : presentationData.strings.Group_Setup_ForwardingChannelInfoDisabled)))
                case .subscriptionChannel, .onlineCourse:
                    break
                }
                
            }
        }
    } /* else if let peer = view.peers[view.peerId] as? ElloAppGroup {
        if case .revokeNames = mode {
            let count = Int32(publicChannelsToRevoke?.count ?? 0)
            
            let text: String
            if count >= premiumLimits.maxPublicLinksCount {
                text = presentationData.strings.Group_Username_RemoveExistingUsernamesFinalInfo
            } else {
                if isPremiumDisabled {
                    text = presentationData.strings.Group_Username_RemoveExistingUsernamesNoPremiumInfo
                } else {
                    text = presentationData.strings.Group_Username_RemoveExistingUsernamesOrExtendInfo("\(premiumLimits.maxPublicLinksCount)").string
                }
            }
            
            entries.append(.linksLimitInfo(presentationData.theme, text, count, limits.maxPublicLinksCount, premiumLimits.maxPublicLinksCount, isPremiumDisabled))
            
            if let publicChannelsToRevoke = publicChannelsToRevoke {
                var index: Int32 = 0
                for peer in publicChannelsToRevoke.sorted(by: { lhs, rhs in
                    var lhsDate: Int32 = 0
                    var rhsDate: Int32 = 0
                    if let lhs = lhs as? ElloAppChannel {
                        lhsDate = lhs.creationDate
                    }
                    if let rhs = rhs as? ElloAppChannel {
                        rhsDate = rhs.creationDate
                    }
                    return lhsDate > rhsDate
                }) {
                    entries.append(.existingLinkPeerItem(index, presentationData.theme, presentationData.strings, presentationData.dateTimeFormat, presentationData.nameDisplayOrder, peer, ItemListPeerItemEditing(editable: true, editing: true, revealed: state.revealedRevokePeerId == peer.id), state.revokingPeerId == nil))
                    index += 1
                }
            }
        } else {
            switch mode {
            case .revokeNames:
                break
            case .privateLink:
                let invite = (view.cachedData as? CachedGroupData)?.exportedInvitation
                entries.append(.privateLinkHeader(presentationData.theme, presentationData.strings.InviteLink_InviteLink.uppercased()))
                entries.append(.privateLink(presentationData.theme, invite, importers?.importers.prefix(3).compactMap { $0.peer.peer.flatMap(EnginePeer.init) } ?? [], importers?.count ?? 0, !isInitialSetup))
                entries.append(.privateLinkInfo(presentationData.theme, presentationData.strings.GroupInfo_InviteLink_Help))
                switch mode {
                case .initialSetup, .revokeNames:
                    break
                case .generic, .privateLink:
                    entries.append(.privateLinkManage(presentationData.theme, presentationData.strings.InviteLink_Manage))
                    entries.append(.privateLinkManageInfo(presentationData.theme, presentationData.strings.InviteLink_CreateInfo))
                case .initialSetupOnlineCourse:
                    break
                }
            case .generic, .initialSetup:
                let selectedType: CurrentChannelType
                if let current = state.selectedType {
                    selectedType = current
                } else {
                    selectedType = .privateChannel
                }
                
                let currentAddressName: String
                if let current = state.editingPublicLinkText {
                    currentAddressName = current
                } else {
                    currentAddressName = ""
                }
                
                entries.append(.typeHeader(presentationData.theme, presentationData.strings.Group_Setup_TypeHeader.uppercased()))
                entries.append(.typePublic(presentationData.theme, presentationData.strings.Channel_Setup_TypePublic, selectedType == .publicChannel))
                entries.append(.typePrivate(presentationData.theme, presentationData.strings.Channel_Setup_TypePrivate, selectedType == .privateChannel))
                entries.append(.typeSubscription(presentationData.theme, presentationData.strings.Channel_Setup_TypeSubscription, selectedType == .subscriptionChannel))
                
                switch selectedType {
                case .publicChannel:
                    entries.append(.typeInfo(presentationData.theme, presentationData.strings.Group_Setup_TypePublicHelp))
                case .privateChannel:
                    entries.append(.typeInfo(presentationData.theme, presentationData.strings.Group_Setup_TypePrivateHelp))
                case .subscriptionChannel:
                    entries.append(.typeInfo(presentationData.theme, presentationData.strings.Channel_Setup_TypeSubscriptionHelp))
                case .onlineCourse:
                    entries.append(.typeInfo(presentationData.theme, presentationData.strings.Channel_Setup_TypeOnlineCourseHelp))
                }
                
                switch selectedType {
                case .publicChannel, .subscriptionChannel:
                    entries.append(.editablePublicLink(presentationData.theme, presentationData.strings, "", currentAddressName))
                    if let status = state.addressNameValidationStatus {
                        let text: String
                        switch status {
                        case let .invalidFormat(error):
                            switch error {
                            case .startsWithDigit:
                                text = presentationData.strings.Group_Username_InvalidStartsWithNumber
                            case .startsWithUnderscore:
                                text = presentationData.strings.Channel_Username_InvalidStartsWithUnderscore
                            case .endsWithUnderscore:
                                text = presentationData.strings.Channel_Username_InvalidEndsWithUnderscore
                            case .tooShort:
                                text = presentationData.strings.Group_Username_InvalidTooShort
                            case .invalidCharacters:
                                text = presentationData.strings.Channel_Username_InvalidCharacters
                            }
                        case let .availability(availability):
                            switch availability {
                            case .available:
                                text = presentationData.strings.Channel_Username_UsernameIsFree(currentAddressName).string
                            case .invalid:
                                text = presentationData.strings.Channel_Username_InvalidCharacters
                            case .taken:
                                text = presentationData.strings.Channel_Username_InvalidTaken
                            }
                        case .checking:
                            text = presentationData.strings.Channel_Username_CheckingUsername
                        }
                        
                        entries.append(.publicLinkStatus(presentationData.theme, text, status))
                    }
                    
                    entries.append(.publicLinkInfo(presentationData.theme, presentationData.strings.Group_Username_CreatePublicLinkHelp))
                case .privateChannel:
                    let invite = (view.cachedData as? CachedGroupData)?.exportedInvitation
                    entries.append(.privateLinkHeader(presentationData.theme, presentationData.strings.InviteLink_InviteLink.uppercased()))
                    entries.append(.privateLink(presentationData.theme, invite, importers?.importers.prefix(3).compactMap { $0.peer.peer.flatMap(EnginePeer.init) } ?? [], importers?.count ?? 0, !isInitialSetup))
                    entries.append(.privateLinkInfo(presentationData.theme, presentationData.strings.Group_Username_CreatePrivateLinkHelp))
                    switch mode {
                    case .initialSetup, .revokeNames:
                        break
                    case .generic, .privateLink:
                        entries.append(.privateLinkManage(presentationData.theme, presentationData.strings.InviteLink_Manage))
                        entries.append(.privateLinkManageInfo(presentationData.theme, presentationData.strings.InviteLink_CreateInfo))
                    case .initialSetupOnlineCourse:
                        break
                    }
                case .onlineCourse:
                    break
                }
            case .initialSetupOnlineCourse:
                break
            }
            
            let forwardingEnabled: Bool
            if let enabled = state.forwardingEnabled {
                forwardingEnabled = enabled
            } else {
                if peer.flags.contains(.copyProtectionEnabled) {
                    forwardingEnabled = false
                } else {
                    forwardingEnabled = true
                }
            }
            
            entries.append(.forwardingHeader(presentationData.theme, presentationData.strings.Group_Setup_ForwardingGroupTitle.uppercased()))
            entries.append(.forwardingDisabled(presentationData.theme, presentationData.strings.Group_Setup_ForwardingDisabled, !forwardingEnabled))
            entries.append(.forwardingInfo(presentationData.theme, forwardingEnabled ? presentationData.strings.Group_Setup_ForwardingGroupInfo : presentationData.strings.Group_Setup_ForwardingGroupInfoDisabled))
        }
    } */
    
    return entries
}

private func effectiveChannelType(mode: ChannelVisibilityControllerMode, state: ChannelVisibilityControllerState, peer: ElloAppChannel, cachedData: CachedPeerData?) -> CurrentChannelType {
    let selectedType: CurrentChannelType
    if let current = state.selectedType {
        selectedType = current
    } else {
        if peer.isSubscription {
            selectedType = .subscriptionChannel
        } else if peer.isCourse {
            selectedType = .onlineCourse
        } else if let addressName = peer.addressName, !addressName.isEmpty {
            selectedType = .publicChannel
        } else if let cachedChannelData = cachedData as? CachedChannelData, cachedChannelData.peerGeoLocation != nil {
            selectedType = .publicChannel
        } else if case .initialSetup = mode {
            selectedType = .publicChannel
        } else {
            selectedType = .privateChannel
        }
    }
    return selectedType
}

private func updatedAddressName(mode: ChannelVisibilityControllerMode, state: ChannelVisibilityControllerState, peer: Peer, cachedData: CachedPeerData?) -> String? {
    if let peer = peer as? ElloAppChannel {
        let selectedType = effectiveChannelType(mode: mode, state: state, peer: peer, cachedData: cachedData)
        
        let currentAddressName: String
        
        switch selectedType {
        case .privateChannel:
            currentAddressName = ""
        case .publicChannel, .subscriptionChannel, .onlineCourse:
            if let current = state.editingPublicLinkText {
                currentAddressName = current
            } else {
                if let addressName = peer.addressName {
                    currentAddressName = addressName
                } else {
                    currentAddressName = ""
                }
            }
        }
        
        if !currentAddressName.isEmpty {
            if currentAddressName != peer.addressName {
                return currentAddressName
            } else {
                return nil
            }
        } else if peer.addressName != nil {
            return ""
        } else {
            return nil
        }
    } else if let _ = peer as? ElloAppGroup {
        let currentAddressName = state.editingPublicLinkText ?? ""
        if !currentAddressName.isEmpty {
            return currentAddressName
        } else {
            return nil
        }
    } else {
        return nil
    }
}

public enum ChannelVisibilityControllerMode {
    case initialSetup
    case generic
    case privateLink
    case revokeNames([Peer])
    case initialSetupOnlineCourse
}

public func channelVisibilityController(context: AccountContext, 
                                        updatedPresentationData: (initial: PresentationData,
                                                                  signal: Signal<PresentationData, NoError>)? = nil,
                                        peerId: PeerId,
                                        mode: ChannelVisibilityControllerMode,
                                        upgradedToSupergroup: @escaping (PeerId, @escaping () -> Void) -> Void,
                                        onDismissRemoveController: ViewController? = nil, 
                                        revokedPeerAddressName: ((PeerId) -> Void)? = nil,
                                        onSelectionContactsNextTappedHandler: ((_ navigationController: NavigationController, 
                                                                                _ updateAddressName: String,
                                                                                _ filteredPeerIds: [PeerId],
                                                                                _ payType: ElloAppChannelPayType) -> Void)? = nil,
                                        onSelectionPrivateOrPublicChannelNextTappedHandler: ((_ isPublicChannel: Bool, 
                                                                                              _ showContacts: (() -> Void)?) -> Void)? = nil) -> ViewController {
    context.account.updateAppConfig()
    
    let statePromise = ValuePromise(ChannelVisibilityControllerState(), ignoreRepeated: true)
    let stateValue = Atomic(value: ChannelVisibilityControllerState())
    let updateState: ((ChannelVisibilityControllerState) -> ChannelVisibilityControllerState) -> Void = { f in
        statePromise.set(stateValue.modify { f($0) })
    }
    
    let adminedPublicChannels = Promise<[Peer]?>()
    if case let .revokeNames(peers) = mode {
        adminedPublicChannels.set(.single(peers))
    } else {
        adminedPublicChannels.set(context.engine.peers.adminedPublicChannels(scope: .all)
        |> map(Optional.init))
    }
    
    let peersDisablingAddressNameAssignment = Promise<[Peer]?>()
    peersDisablingAddressNameAssignment.set(.single(nil) |> then(context.engine.peers.channelAddressNameAssignmentAvailability(peerId: peerId.namespace == Namespaces.Peer.CloudChannel ? peerId : nil) |> mapToSignal { result -> Signal<[Peer]?, NoError> in
        if case .addressNameLimitReached = result {
            return context.engine.peers.adminedPublicChannels(scope: .all)
            |> map(Optional.init)
        } else {
            return .single([])
        }
    }))
    
    var dismissImpl: (() -> Void)?
    var nextImpl: ((_ state: ChannelVisibilityControllerState) -> Void)?
    var nextImpPaidChannel: ((_ state: ChannelVisibilityControllerState) -> Void)?
    var scrollToPublicLinkTextImpl: (() -> Void)?
    var presentControllerImpl: ((ViewController, Any?) -> Void)?
    var pushControllerImpl: ((ViewController) -> Void)?
    var presentInGlobalOverlayImpl: ((ViewController) -> Void)?
    var getControllerImpl: (() -> ViewController?)?
    
    var dismissTooltipsImpl: (() -> Void)?
    
    let actionsDisposable = DisposableSet()
    
    let checkAddressNameDisposable = MetaDisposable()
    actionsDisposable.add(checkAddressNameDisposable)
    
    let updateAddressNameDisposable = MetaDisposable()
    actionsDisposable.add(updateAddressNameDisposable)
    
    let revokeAddressNameDisposable = MetaDisposable()
    actionsDisposable.add(revokeAddressNameDisposable)
    
    let revokeLinkDisposable = MetaDisposable()
    actionsDisposable.add(revokeLinkDisposable)
    
    let toggleCopyProtectionDisposable = MetaDisposable()
    actionsDisposable.add(toggleCopyProtectionDisposable)
    
    let toggleJoinToSendDisposable = MetaDisposable()
    actionsDisposable.add(toggleJoinToSendDisposable)
    
    let toggleRequestToJoinDisposable = MetaDisposable()
    actionsDisposable.add(toggleRequestToJoinDisposable)
    
    let arguments = ChannelVisibilityControllerArguments(context: context, updateCurrentType: { type, action in
        if type == .publicChannel || type == .subscriptionChannel {
            let _ = combineLatest(
                queue: Queue.mainQueue(),
                adminedPublicChannels.get() |> filter { $0 != nil } |> take(1),
                context.engine.data.get(ElloAppEngine.EngineData.Item.Peer.Peer(id: context.account.peerId)),
                context.engine.data.get(
                    ElloAppEngine.EngineData.Item.Configuration.UserLimits(isPremium: false),
                    ElloAppEngine.EngineData.Item.Configuration.UserLimits(isPremium: true)
                )
            ).start(next: { peers, accountPeer, data in
                let (limits, premiumLimits) = data
                let isPremium = accountPeer?.isPremium ?? false
                
                if let peers = peers {
                    let count = Int32(peers.count)
                    if count < limits.maxPublicLinksCount || (count < premiumLimits.maxPublicLinksCount && isPremium) {
                        updateState { state in
                            return state.withUpdatedSelectedType(type)
                        }
                        
                        action?()
                    } else {
                        let controller = channelVisibilityController(context: context, 
                                                                     updatedPresentationData: updatedPresentationData,
                                                                     peerId: peerId,
                                                                     mode: .revokeNames(peers),
                                                                     upgradedToSupergroup: { _, _ in },
                                                                     revokedPeerAddressName: { revokedPeerId in
                            let updatedPublicChannels = peers.filter { $0.id != revokedPeerId }
                            adminedPublicChannels.set(.single(updatedPublicChannels) |> then(
                                context.engine.peers.adminedPublicChannels(scope: .all) |> map(Optional.init))
                            )
                        })
                        controller.navigationPresentation = .modal
                        pushControllerImpl?(controller)
                    }
                } else {
                }
            })
        } else {
            updateState { state in
                return state.withUpdatedSelectedType(type)
            }
        }
    }, updatePublicLinkText: { currentText, text in
        if text.isEmpty {
            checkAddressNameDisposable.set(nil)
            updateState { state in
                return state.withUpdatedEditingPublicLinkText(text).withUpdatedAddressNameValidationStatus(nil)
            }
        } else if currentText == text {
            checkAddressNameDisposable.set(nil)
            updateState { state in
                return state.withUpdatedEditingPublicLinkText(text).withUpdatedAddressNameValidationStatus(nil).withUpdatedAddressNameValidationStatus(nil)
            }
        } else {
            updateState { state in
                return state.withUpdatedEditingPublicLinkText(text)
            }
            
            checkAddressNameDisposable.set((context.engine.peers.validateAddressNameInteractive(domain: .peer(peerId), name: text)
            |> deliverOnMainQueue).start(next: { result in
                updateState { state in
                    return state.withUpdatedAddressNameValidationStatus(result)
                }
            }))
        }
    }, scrollToPublicLinkText: {
        scrollToPublicLinkTextImpl?()
    }, setPeerIdWithRevealedOptions: { peerId, fromPeerId in
        updateState { state in
            if (peerId == nil && fromPeerId == state.revealedRevokePeerId) || (peerId != nil && fromPeerId == nil) {
                return state.withUpdatedRevealedRevokePeerId(peerId)
            } else {
                return state
            }
        }
    }, revokePeerId: { peerId in
        updateState { state in
            return state.withUpdatedRevokingPeerId(peerId)
        }
        
        revokeAddressNameDisposable.set((context.engine.peers.updateAddressName(domain: .peer(peerId), name: nil) |> deliverOnMainQueue).start(error: { _ in
            updateState { state in
                return state.withUpdatedRevokingPeerId(nil)
            }
        }, completed: {
            revokedPeerAddressName?(peerId)
            dismissImpl?()
        }))
    }, copyLink: { invite in
        UIPasteboard.general.string = invite.link
       
        dismissTooltipsImpl?()
        
        let presentationData = context.sharedContext.currentPresentationData.with { $0 }
        presentControllerImpl?(UndoOverlayController(presentationData: presentationData, content: .linkCopied(text: presentationData.strings.InviteLink_InviteLinkCopiedText), elevatedLayout: false, animateInAsReplacement: false, action: { _ in return false }), nil)
    }, shareLink: { invite in
        guard let inviteLink = invite.link else {
            return
        }
        let shareController = ShareController(context: context, subject: .url(inviteLink), updatedPresentationData: updatedPresentationData)
        shareController.actionCompleted = {
            let presentationData = context.sharedContext.currentPresentationData.with { $0 }
            presentControllerImpl?(UndoOverlayController(presentationData: presentationData, content: .linkCopied(text: presentationData.strings.InviteLink_InviteLinkCopiedText), elevatedLayout: false, animateInAsReplacement: false, action: { _ in return false }), nil)
        }
        presentControllerImpl?(shareController, nil)
    }, linkContextAction: { node, gesture in
        guard let node = node as? ContextReferenceContentNode, let controller = getControllerImpl?() else {
            return
        }
        let presentationData = context.sharedContext.currentPresentationData.with { $0 }
        var items: [ContextMenuItem] = []

        items.append(.action(ContextMenuActionItem(text: presentationData.strings.InviteLink_ContextCopy, icon: { theme in
            return generateTintedImage(image: UIImage(bundleImageName: "Chat/Context Menu/Copy"), color: theme.contextMenu.primaryColor)
        }, action: { _, f in
            f(.dismissWithoutContent)
            
            let _ = (context.engine.data.get(ElloAppEngine.EngineData.Item.Peer.ExportedInvitation(id: peerId))
            |> deliverOnMainQueue).start(next: { exportedInvitation in
                if let link = exportedInvitation?.link {
                    UIPasteboard.general.string = link
                    
                    dismissTooltipsImpl?()
                    
                    let presentationData = context.sharedContext.currentPresentationData.with { $0 }
                    presentControllerImpl?(UndoOverlayController(presentationData: presentationData, content: .linkCopied(text: presentationData.strings.InviteLink_InviteLinkCopiedText), elevatedLayout: false, animateInAsReplacement: false, action: { _ in return false }), nil)
                }
            })
        })))
        
//        items.append(.action(ContextMenuActionItem(text: presentationData.strings.InviteLink_ContextGetQRCode, icon: { theme in
//            return generateTintedImage(image: UIImage(bundleImageName: "Settings/QrIcon"), color: theme.contextMenu.primaryColor)
//        }, action: { _, f in
//            f(.dismissWithoutContent)
//
//            let _ = (context.engine.data.get(ElloAppEngine.EngineData.Item.Peer.ExportedInvitation(id: peerId))
//            |> deliverOnMainQueue).start(next: { invite in
//                if let invite = invite {
//                    let _ = (context.account.postbox.loadedPeerWithId(peerId)
//                    |> deliverOnMainQueue).start(next: { peer in
//                        let isGroup: Bool
//                        if let peer = peer as? ElloAppChannel, case .broadcast = peer.info {
//                            isGroup = false
//                        } else {
//                            isGroup = true
//                        }
//                        presentControllerImpl?(QrCodeScreen(context: context, updatedPresentationData: updatedPresentationData, subject: .invite(invite: invite, isGroup: isGroup)), nil)
//                    })
//                }
//            })
//        })))
        
        items.append(.action(ContextMenuActionItem(text: presentationData.strings.InviteLink_ContextRevoke, textColor: .primary, icon: { theme in
            return generateTintedImage(image: UIImage(bundleImageName: "Chat/Context Menu/Delete"), color: theme.actionSheet.destructiveActionTextColor)
        }, action: { _, f in
            f(.dismissWithoutContent)
        
            let _ = (context.account.postbox.loadedPeerWithId(peerId)
            |> deliverOnMainQueue).start(next: { peer in
                let isGroup: Bool
                if let peer = peer as? ElloAppChannel, case .broadcast = peer.info {
                    isGroup = false
                } else {
                    isGroup = true
                }
                
                let controller = ActionSheetController(presentationData: presentationData)
                let dismissAction: () -> Void = { [weak controller] in
                    controller?.dismissAnimated()
                }
                controller.setItemGroups([
                    ActionSheetItemGroup(items: [
                        ActionSheetTextItem(title: isGroup ? presentationData.strings.GroupInfo_InviteLink_RevokeAlert_Text : presentationData.strings.ChannelInfo_InviteLink_RevokeAlert_Text),
                        ActionSheetButtonItem(title: presentationData.strings.GroupInfo_InviteLink_RevokeLink, color: .destructive, action: {
                            dismissAction()
                            
                            let _ = (context.engine.data.get(ElloAppEngine.EngineData.Item.Peer.ExportedInvitation(id: peerId))
                            |> deliverOnMainQueue).start(next: { exportedInvitation in
                                if let link = exportedInvitation?.link {
                                    var revoke = false
                                    updateState { state in
                                        if !state.revokingPrivateLink {
                                            revoke = true
                                            return state.withUpdatedRevokingPrivateLink(true)
                                        } else {
                                            return state
                                        }
                                    }
                                    if revoke {
                                        revokeLinkDisposable.set((context.engine.peers.revokePeerExportedInvitation(peerId: peerId, link: link) |> deliverOnMainQueue).start(completed: {
                                            updateState {
                                                $0.withUpdatedRevokingPrivateLink(false)
                                            }
                                        }))
                                    }
                                }
                            })
                        })
                    ]),
                    ActionSheetItemGroup(items: [ActionSheetButtonItem(title: presentationData.strings.Common_Cancel, action: { dismissAction() })])
                ])
                presentControllerImpl?(controller, ViewControllerPresentationArguments(presentationAnimation: .modalSheet))
            })
        })))

        let contextController = ContextController(account: context.account, presentationData: presentationData, source: .reference(InviteLinkContextReferenceContentSource(controller: controller, sourceNode: node)), items: .single(ContextController.Items(content: .list(items))), gesture: gesture)
        presentInGlobalOverlayImpl?(contextController)
    }, manageInviteLinks: {
        let controller = inviteLinkListController(context: context, updatedPresentationData: updatedPresentationData, peerId: peerId, admin: nil)
        pushControllerImpl?(controller)
    }, openLink: { invite in
        let controller = InviteLinkViewController(context: context, updatedPresentationData: updatedPresentationData, peerId: peerId, invite: invite, invitationsContext: nil, revokedInvitationsContext: nil, importersContext: nil)
        pushControllerImpl?(controller)
    }, toggleForwarding: { value in
        updateState { state in
            return state.withUpdatedForwardingEnabled(value)
        }
    }, updateJoinToSend: { value in
        updateState { state in
            return state.withUpdatedJoinToSend(value)
        }
    }, toggleApproveMembers: { value in
        updateState { state in
            return state.withUpdatedApproveMembers(value)
        }
    })
    
    let peerView = context.account.viewTracker.peerView(peerId)
    |> deliverOnMainQueue
    
    let previousHadNamesToRevoke = Atomic<Bool?>(value: nil)
    let previousInvitation = Atomic<ExportedInvitation?>(value: nil)
    
    let mainLink = context.engine.data.subscribe(
        ElloAppEngine.EngineData.Item.Peer.ExportedInvitation(id: peerId)
    )
    
    let importersState = Promise<PeerInvitationImportersState?>(nil)
    let importersContext: Signal<PeerInvitationImportersContext?, NoError> = mainLink
    |> distinctUntilChanged
    |> deliverOnMainQueue
    |> map { invite -> PeerInvitationImportersContext? in
        return invite.flatMap { context.engine.peers.peerInvitationImporters(peerId: peerId, subject: .invite(invite: $0, requested: false)) }
    } |> afterNext { context in
        if let context = context {
            importersState.set(context.state |> map(Optional.init))
        } else {
            importersState.set(.single(nil))
        }
    }
    
    let premiumConfiguration = PremiumConfiguration.with(appConfiguration: context.currentAppConfiguration.with { $0 })
    
    let presentationData = updatedPresentationData?.signal ?? context.sharedContext.presentationData
    let signal = combineLatest(
        presentationData,
        statePromise.get() |> deliverOnMainQueue,
        peerView,
        adminedPublicChannels.get(),
        importersContext,
        importersState.get(),
        context.engine.data.get(
            ElloAppEngine.EngineData.Item.Configuration.UserLimits(isPremium: false),
            ElloAppEngine.EngineData.Item.Configuration.UserLimits(isPremium: true),
            ElloAppEngine.EngineData.Item.Peer.Peer(id: context.account.peerId)
        )
    )
    |> deliverOnMainQueue
    |> map { presentationData, state, view, publicChannelsToRevoke, importersContext, importers, data -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let peer = peerViewMainPeer(view) ?? peer(with: peerId, presentationData: presentationData)
        
        let (limits, premiumLimits, accountPeer) = data
        let isPremium = accountPeer?.isPremium ?? false
        
        var footerItem: ItemListControllerFooterItem?
        
        var rightNavigationButton: ItemListNavigationButton?
        if case .revokeNames = mode {
            let count = Int32(publicChannelsToRevoke?.count ?? 0)
            if !premiumConfiguration.isPremiumDisabled && count < premiumLimits.maxPublicLinksCount {
                footerItem = IncreaseLimitFooterItem(theme: presentationData.theme, title: presentationData.strings.Premium_IncreaseLimit, colorful: true, action: {
                    let controller = PremiumIntroScreen(context: context, source: .publicLinks)
                    pushControllerImpl?(controller)
                })
            }
        } else {
            if let peer = peer as? ElloAppChannel {
                var doneEnabled = true
                if let selectedType = state.selectedType {
                    switch selectedType {
                    case .privateChannel:
                        break
                    case .publicChannel, .subscriptionChannel, .onlineCourse:
                        var hasLocation = false
                        if let cachedChannelData = view.cachedData as? CachedChannelData, cachedChannelData.peerGeoLocation != nil {
                            hasLocation = true
                        }
                        
                        if let addressNameValidationStatus = state.addressNameValidationStatus {
                            switch addressNameValidationStatus {
                            case .availability(.available):
                                break
                            default:
                                doneEnabled = false
                            }
                        } else {
                            doneEnabled = !(peer.addressName?.isEmpty ?? true) || hasLocation
                        }
                    }
                } else if case .initialSetupOnlineCourse = mode {
                    if let addressNameValidationStatus = state.addressNameValidationStatus {
                        switch addressNameValidationStatus {
                        case .availability(.available):
                            break
                        default:
                            doneEnabled = false
                        }
                    } else {
                        doneEnabled = !(peer.addressName?.isEmpty ?? true)
                    }
                } else if case .initialSetup = mode {
                    if let addressNameValidationStatus = state.addressNameValidationStatus {
                        switch addressNameValidationStatus {
                        case .availability(.available):
                            break
                        default:
                            doneEnabled = false
                        }
                    } else {
                        doneEnabled = !(peer.addressName?.isEmpty ?? true)
                    }
                }
                
                let isInitialSetup: Bool
                if case .initialSetup = mode {
                    isInitialSetup = true
                } else if case .initialSetupOnlineCourse = mode {
                    isInitialSetup = true
                } else {
                    isInitialSetup = false
                }
                
                rightNavigationButton = ItemListNavigationButton(content: .text(isInitialSetup ? presentationData.strings.Common_Next : presentationData.strings.Common_Done), 
                                                                 style: state.updatingAddressName ? .activity : .bold,
                                                                 enabled: doneEnabled,
                                                                 action: {
                    
                    if nil == state.selectedType || state.selectedType == .publicChannel {
                        arguments.updateCurrentType(.publicChannel) {
                            executor()
                        }
                        return
                    }
                    else{
                        executor()
                    }
                    
                    func executor() {
                        var updatedAddressNameValue: String?
                        updateState { state in
                            updatedAddressNameValue = updatedAddressName(mode: mode, state: state, peer: peer, cachedData: view.cachedData)
                            return state
                        }
                        
                        if let updatedCopyProtection = state.forwardingEnabled {
                            toggleCopyProtectionDisposable.set(context.engine.peers.toggleMessageCopyProtection(peerId: peerId, enabled: !updatedCopyProtection).start())
                        }
                        
                        if let updatedJoinToSend = state.joinToSend {
                            toggleJoinToSendDisposable.set(context.engine.peers.toggleChannelJoinToSend(peerId: peerId, enabled: updatedJoinToSend == .members).start())
                        }
                        
                        if let updatedApproveMembers = state.approveMembers {
                            toggleRequestToJoinDisposable.set(context.engine.peers.toggleChannelJoinRequest(peerId: peerId, enabled: updatedApproveMembers).start())
                        }
                        
                        if let updatedAddressNameValue = updatedAddressNameValue {
                            let invokeAction: () -> Void = {
                                updateState { state in
                                    return state.withUpdatedUpdatingAddressName(false)
                                }
                                _ = ApplicationSpecificNotice.markAsSeenSetPublicChannelLink(accountManager: context.sharedContext.accountManager).start()
                                
                                switch mode {
                                case .initialSetup:
                                    if state.selectedType == .subscriptionChannel {
                                        nextImpPaidChannel?(state)
                                    } else {
                                        //                                    onSelectionPrivateOrPublicChannelNextTappedHandler?(state.selectedType == .publicChannel, nextImpl)
                                        nextImpl?(state)
                                    }
                                case .generic, .privateLink, .revokeNames:
                                    updateAddressNameDisposable.set((context.engine.peers.updateAddressName(domain: .peer(peerId), name: updatedAddressNameValue.isEmpty ? nil : updatedAddressNameValue) |> timeout(10, queue: Queue.mainQueue(), alternate: .fail(.generic))
                                                                     |> deliverOnMainQueue).start(error: { _ in
                                        updateState { state in
                                            return state.withUpdatedUpdatingAddressName(false)
                                        }
                                        
                                        presentControllerImpl?(textAlertController(context: context, 
                                                                                   updatedPresentationData: updatedPresentationData,
                                                                                   title: nil,
                                                                                   text: presentationData.strings.Login_UnknownError,
                                                                                   actions: [TextAlertAction(type: .defaultAction,
                                                                                                             title: presentationData.strings.Common_OK,
                                                                                                             action: {})]), nil)
                                    }, completed: {
                                        updateState { state in
                                            return state.withUpdatedUpdatingAddressName(false)
                                        }
                                        switch mode {
                                        case .initialSetup:
                                            nextImpl?(state)
                                        case .generic, .privateLink, .revokeNames:
                                            dismissImpl?()
                                        case .initialSetupOnlineCourse:
                                            break
                                        }
                                    }))
                                case .initialSetupOnlineCourse:
                                    nextImpPaidChannel?(state)
                                }
                            }
                            
                            _ = (ApplicationSpecificNotice.getSetPublicChannelLink(accountManager: context.sharedContext.accountManager) |> deliverOnMainQueue).start(next: { showAlert in
                                if showAlert {
                                    let text: String
                                    if case .broadcast = peer.info {
                                        text = presentationData.strings.Channel_Edit_PrivatePublicLinkAlert
                                    } else {
                                        text = presentationData.strings.Group_Edit_PrivatePublicLinkAlert
                                    }
                                    presentControllerImpl?(textAlertController(context: context, updatedPresentationData: updatedPresentationData, title: nil, text: text, actions: [TextAlertAction(type: .defaultAction, title: presentationData.strings.Common_Cancel, action: {}), TextAlertAction(type: .genericAction, title: presentationData.strings.Common_OK, action: invokeAction)]), nil)
                                } else {
                                    invokeAction()
                                }
                            })
                        } else {
                            switch mode {
                            case .initialSetup:
                                if state.selectedType == .subscriptionChannel {
                                    nextImpPaidChannel?(state)
                                } else {
                                    //                                onSelectionPrivateOrPublicChannelNextTappedHandler?(state.selectedType == .publicChannel, nextImpl)
                                    nextImpl?(state)
                                }
                            case .generic, .privateLink, .revokeNames:
                                dismissImpl?()
                            case .initialSetupOnlineCourse:
                                nextImpPaidChannel?(state)
                            }
                        }
                    }})
            } else if let peer = peer as? ElloAppGroup {
                var doneEnabled = true
                if let selectedType = state.selectedType {
                    switch selectedType {
                    case .privateChannel:
                        break
                    case .publicChannel, .subscriptionChannel, .onlineCourse:
                        if let addressNameValidationStatus = state.addressNameValidationStatus {
                            switch addressNameValidationStatus {
                            case .availability(.available):
                                break
                            default:
                                doneEnabled = false
                            }
                        } else {
                            doneEnabled = !(peer.addressName?.isEmpty ?? true)
                        }
                    }
                }
                
                rightNavigationButton = ItemListNavigationButton(content: .text(presentationData.strings.Common_Done), 
                                                                 style: state.updatingAddressName ? .activity : .bold,
                                                                 enabled: doneEnabled,
                                                                 action: {
                    
                    var updatedAddressNameValue: String?
                    updateState { state in
                        updatedAddressNameValue = updatedAddressName(mode: mode, state: state, peer: peer, cachedData: nil)
                        return state
                    }
                    
                    if let updatedCopyProtection = state.forwardingEnabled {
                        toggleCopyProtectionDisposable.set(context.engine.peers.toggleMessageCopyProtection(peerId: peerId, enabled: !updatedCopyProtection).start())
                    }
                    
                    if let updatedAddressNameValue = updatedAddressNameValue {
                        let invokeAction: () -> Void = {
                            updateState { state in
                                return state.withUpdatedUpdatingAddressName(true)
                            }
                            _ = ApplicationSpecificNotice.markAsSeenSetPublicChannelLink(accountManager: context.sharedContext.accountManager).start()
                            
                            let signal = context.engine.peers.convertGroupToSupergroup(peerId: peerId)
                            |> mapToSignal { upgradedPeerId -> Signal<PeerId?, ConvertGroupToSupergroupError> in
                                return context.engine.peers.updateAddressName(domain: .peer(upgradedPeerId), name: updatedAddressNameValue.isEmpty ? nil : updatedAddressNameValue)
                                |> `catch` { _ -> Signal<Void, NoError> in
                                    return .complete()
                                }
                                |> mapToSignal { _ -> Signal<PeerId?, NoError> in
                                    return .complete()
                                }
                                |> then(.single(upgradedPeerId))
                                |> castError(ConvertGroupToSupergroupError.self)
                            }
                            |> deliverOnMainQueue
                            
                            updateAddressNameDisposable.set((signal
                            |> deliverOnMainQueue).start(next: { updatedPeerId in
                                if let updatedPeerId = updatedPeerId {
                                    upgradedToSupergroup(updatedPeerId, {
                                        dismissImpl?()
                                    })
                                } else {
                                    dismissImpl?()
                                }
                            }, error: { error in
                                updateState { state in
                                    return state.withUpdatedUpdatingAddressName(false)
                                }
                                switch error {
                                case .tooManyChannels:
                                    pushControllerImpl?(oldChannelsController(context: context, updatedPresentationData: updatedPresentationData, intent: .upgrade))
                                default:
                                    presentControllerImpl?(textAlertController(context: context, updatedPresentationData: updatedPresentationData, title: nil, text: presentationData.strings.Login_UnknownError, actions: [TextAlertAction(type: .defaultAction, title: presentationData.strings.Common_OK, action: {})]), nil)
                                }
                            }))
                        }
                        
                        _ = (ApplicationSpecificNotice.getSetPublicChannelLink(accountManager: context.sharedContext.accountManager) |> deliverOnMainQueue).start(next: { showAlert in
                            if showAlert {
                                presentControllerImpl?(textAlertController(context: context, updatedPresentationData: updatedPresentationData, title: nil, text: presentationData.strings.Group_Edit_PrivatePublicLinkAlert, actions: [TextAlertAction(type: .defaultAction, title: presentationData.strings.Common_Cancel, action: {}), TextAlertAction(type: .genericAction, title: presentationData.strings.Common_OK, action: invokeAction)]), nil)
                            } else {
                                invokeAction()
                            }
                        })
                    } else {
                        switch mode {
                        case .initialSetup:
                            nextImpl?(state)
                        case .generic, .privateLink, .revokeNames:
                            dismissImpl?()
                        case .initialSetupOnlineCourse:
                            break
                        }
                    }
                })
            }
        }
        
        if state.revokingPeerId != nil {
            rightNavigationButton = ItemListNavigationButton(content: .none, style: .activity, enabled: true, action: {})
        }
        
        var isGroup = false
        if let peer = peer as? ElloAppChannel {
            if case .group = peer.info {
                isGroup = true
            }
        } else if let _ = peer as? ElloAppGroup {
            isGroup = true
        }
        
        let leftNavigationButton: ItemListNavigationButton?
        switch mode {
        case .initialSetup:
            leftNavigationButton = nil
        case .generic, .privateLink, .revokeNames:
            leftNavigationButton = ItemListNavigationButton(content: .text(presentationData.strings.Common_Cancel), style: .regular, enabled: true, action: {
                dismissImpl?()
            })
        case .initialSetupOnlineCourse:
            leftNavigationButton = nil
        }
        
        // Link
        var crossfade: Bool = false
        var animateChanges: Bool = false
        if let cachedData = view.cachedData as? CachedChannelData {
            let invitation = cachedData.exportedInvitation
            let previousInvitation = previousInvitation.swap(invitation)
            
            if invitation != previousInvitation {
                crossfade = true
            }
        }
        
        let hasNamesToRevoke = publicChannelsToRevoke != nil && !publicChannelsToRevoke!.isEmpty
        let hadNamesToRevoke = previousHadNamesToRevoke.swap(hasNamesToRevoke)
        if let peer = peer as? ElloAppChannel {
            let selectedType: CurrentChannelType
            if case .privateLink = mode {
                selectedType = .privateChannel
            } else {
                if let current = state.selectedType {
                    selectedType = current
                } else {
                    if peer.isSubscription {
                        selectedType = .subscriptionChannel
                    } else if peer.isCourse {
                        selectedType = .onlineCourse
                    } else if let addressName = peer.addressName, !addressName.isEmpty {
                        selectedType = .publicChannel
                    } else if let cachedChannelData = view.cachedData as? CachedChannelData, cachedChannelData.peerGeoLocation != nil {
                        selectedType = .publicChannel
                    } else {
                        selectedType = .privateChannel
                    }
                }
            }
            
            if selectedType == .publicChannel, let hadNamesToRevoke = hadNamesToRevoke, !crossfade {
                crossfade = hadNamesToRevoke != hasNamesToRevoke
            }
                        
            if let hadNamesToRevoke = hadNamesToRevoke {
                animateChanges = hadNamesToRevoke != hasNamesToRevoke
            }
        }
        
        let title: String
        switch mode {
            case .generic, .initialSetup:
                if let cachedChannelData = view.cachedData as? CachedChannelData, cachedChannelData.peerGeoLocation != nil {
                    title = presentationData.strings.Group_PublicLink_Title
                } else {
                    title = isGroup ? presentationData.strings.GroupInfo_GroupType : presentationData.strings.Channel_TypeSetup_Title
                }
            case .privateLink:
                title = presentationData.strings.GroupInfo_InviteLink_Title
            case .revokeNames:
                title = presentationData.strings.Premium_LimitReached
        case .initialSetupOnlineCourse:
            title = presentationData.strings.Channel_TypeSetup_Title
        }

        let entries = channelVisibilityControllerEntries(peerId: peerId, 
                                                         presentationData: presentationData,
                                                         mode: mode,
                                                         view: view,
                                                         publicChannelsToRevoke: publicChannelsToRevoke,
                                                         importers: importers,
                                                         state: state,
                                                         limits: limits,
                                                         premiumLimits: premiumLimits,
                                                         isPremium: isPremium,
                                                         isPremiumDisabled: premiumConfiguration.isPremiumDisabled)
        
        var focusItemTag: ItemListItemTag?
        if entries.count > 1, let cachedChannelData = view.cachedData as? CachedChannelData, cachedChannelData.peerGeoLocation != nil {
            focusItemTag = ChannelVisibilityEntryTag.publicLink
        }
        
        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), 
                                                      title: .text(title),
                                                      leftNavigationButton: leftNavigationButton,
                                                      rightNavigationButton: rightNavigationButton,
                                                      backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back),
                                                      animateChanges: false)
        
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), 
                                          entries: entries,
                                          style: .blocks,
                                          focusItemTag: focusItemTag,
                                          footerItem: footerItem,
                                          crossfadeState: crossfade,
                                          animateChanges: animateChanges)
        
        return (controllerState, (listState, arguments))
    } |> afterDisposed {
        actionsDisposable.dispose()
    }
    
    let controller = ItemListController(context: context, state: signal)
    controller.willDisappear = { _ in
        dismissTooltipsImpl?()
    }
    
    dismissImpl = { [weak controller, weak onDismissRemoveController] in
        guard let controller = controller else {
            return
        }
        
        controller.view.endEditing(true)
        if let onDismissRemoveController = onDismissRemoveController, let navigationController = controller.navigationController {
            navigationController.setViewControllers(navigationController.viewControllers.filter { c in
                if c === controller || c === onDismissRemoveController {
                    return false
                } else {
                    return true
                }
            }, animated: true)
        } else {
            controller.dismiss()
        }
    }
    
    nextImpPaidChannel = { [weak controller] state in
        guard let controller else { return }
        guard let navigationController = controller.navigationController as? NavigationController else {
            return
        }
        
        switch mode {
        case .initialSetup:
            onSelectionContactsNextTappedHandler?(
                navigationController, state.editingPublicLinkText ?? "", [], .subscription
            )
        case .initialSetupOnlineCourse:
            onSelectionContactsNextTappedHandler?(
                navigationController, state.editingPublicLinkText ?? "", [], .onlineCourse
            )
        default:
            return
        }
    }
    
    nextImpl = { [weak controller] state in
        guard let controller = controller else { return }
        
        switch mode {
        case .initialSetup, .initialSetupOnlineCourse:
            let mode: ContactMultiselectionControllerMode = switch state.selectedType {
            case .none, .publicChannel, .onlineCourse, .subscriptionChannel:
                if let text = state.editingPublicLinkText, !text.isEmpty {
                    .publicChannelCreation
                } else {
                    .channelCreation
                }
            case .privateChannel:
                .channelCreation
            }
            
            let selectionController = context.sharedContext.makeContactMultiselectionController(
                ContactMultiselectionControllerParams(
                    context: context,
                    updatedPresentationData: updatedPresentationData,
                    mode: mode,
                    options: []))
            (controller.navigationController as? NavigationController)?.pushViewController(selectionController)
            
            let _ = (selectionController.result
                     |> deliverOnMainQueue).start(next: { [weak selectionController] result in
                guard let selectionController = selectionController, let navigationController = selectionController.navigationController as? NavigationController else {
                    return
                }
                
                var peerIds: [ContactListPeerId] = []
                if case let .result(peerIdsValue, _) = result {
                    peerIds = peerIdsValue
                }
                
                let filteredPeerIds = peerIds.compactMap({ peerId -> PeerId? in
                    if case let .peer(id) = peerId {
                        return id
                    } else {
                        return nil
                    }
                })
                    
                let payType: ElloAppChannelPayType = switch state.selectedType {
                case .privateChannel, .publicChannel, .none:
                    .free
                case .subscriptionChannel:
                    .subscription
                case .onlineCourse:
                    .onlineCourse
                }
                
                onSelectionContactsNextTappedHandler?(
                    navigationController,
                    state.selectedType == .privateChannel ? "" : state.editingPublicLinkText ?? "",
                    filteredPeerIds, payType
                )
                
                
                //                    if filteredPeerIds.isEmpty {
                //                        context.sharedContext.navigateToChatController(NavigateToChatControllerParams(navigationController: navigationController, chatController: nil, context: context, chatLocation: .peer(id: peerId), keepStack: .never, animated: true))
                //                    } else {
                //                        selectionController.displayProgress = true
                //                        let _ = (context.engine.peers.addChannelMembers(peerId: peerId, memberIds: filteredPeerIds)
                //                        |> deliverOnMainQueue).start(error: { [weak selectionController] _ in
                //                            guard let selectionController = selectionController, let navigationController = selectionController.navigationController as? NavigationController else {
                //                                return
                //                            }
                //
                //                            context.sharedContext.navigateToChatController(NavigateToChatControllerParams(navigationController: navigationController, chatController: nil, context: context, chatLocation: .peer(id: peerId), keepStack: .never, animated: true))
                //                        }, completed: { [weak selectionController] in
                //                            guard let selectionController = selectionController, let navigationController = selectionController.navigationController as? NavigationController else {
                //                                return
                //                            }
                //
                //                            context.sharedContext.navigateToChatController(NavigateToChatControllerParams(navigationController: navigationController, chatController: nil, context: context, chatLocation: .peer(id: peerId), keepStack: .never, animated: true))
                //                        })
                //                    }
            })
        case .generic, .privateLink, .revokeNames:
            if let navigationController = controller.navigationController as? NavigationController {
                navigationController.replaceAllButRootController(context.sharedContext.makeChatController(context: context, chatLocation: .peer(id: peerId), subject: nil, botStart: nil, mode: .standard(previewing: false)), animated: true)
            }
        }
    }
    
    scrollToPublicLinkTextImpl = { [weak controller] in
        DispatchQueue.main.async {
            if let strongController = controller {
                var resultItemNode: ListViewItemNode?
                let _ = strongController.frameForItemNode({ itemNode in
                    if let itemNode = itemNode as? ItemListSingleLineInputItemNode {
                        if let tag = itemNode.tag as? ChannelVisibilityEntryTag {
                            if tag == .publicLink {
                                resultItemNode = itemNode
                                return true
                            }
                        }
                    }
                    return false
                })
                
                if let resultItemNode = resultItemNode {
                    strongController.ensureItemNodeVisible(resultItemNode)
                }
            }
        }
    }
    
    presentControllerImpl = { [weak controller] c, a in
        controller?.present(c, in: .window(.root), with: a)
    }
    
    pushControllerImpl = { [weak controller] c in
        controller?.push(c)
    }
    
    presentInGlobalOverlayImpl = { [weak controller] c in
        if let controller = controller {
            controller.presentInGlobalOverlay(c)
        }
    }
    
    getControllerImpl = { [weak controller] in
        return controller
    }
    
    dismissTooltipsImpl = { [weak controller] in
        controller?.window?.forEachController({ controller in
            if let controller = controller as? UndoOverlayController {
                controller.dismissWithCommitAction()
            }
        })
        
        controller?.forEachController({ controller in
            if let controller = controller as? UndoOverlayController {
                controller.dismissWithCommitAction()
            }
            return true
        })
    }
    return controller
}

func peer(with peerId: PeerId, presentationData: PresentationData) -> Peer? {
    ElloAppChannel(
        id: peerId,
        accessHash: nil,
        title: presentationData.strings.Appearance_ThemePreview_ChatList_3_Name,
        description: nil,
        username: nil,
        photo: [],
        creationDate: 0,
        version: 0,
        participationStatus: .left,
        info: .broadcast(.init(flags: [])),
        flags: [],
        restrictionInfo: nil,
        adminRights: nil,
        bannedRights: nil,
        defaultBannedRights: nil,
        payType: .free,
        cost: nil,
        isAdult: false,
        startDate: nil,
        endDate: nil
    )
}

final class InviteLinkContextReferenceContentSource: ContextReferenceContentSource {
    private let controller: ViewController
    private let sourceNode: ContextReferenceContentNode
    
    init(controller: ViewController, sourceNode: ContextReferenceContentNode) {
        self.controller = controller
        self.sourceNode = sourceNode
    }
    
    func transitionInfo() -> ContextControllerReferenceViewInfo? {
        return ContextControllerReferenceViewInfo(referenceView: self.sourceNode.view, contentAreaInScreenSpace: UIScreen.main.bounds)
    }
}
