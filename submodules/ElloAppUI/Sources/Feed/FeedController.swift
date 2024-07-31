import Foundation
import UIKit
import Display
import ELBase
import AccountContext
import ElloAppApi
import AppBundle

public final class ELFeedController {
    
    public static func root(context: AccountContext, onStartHandler: @escaping () -> Void) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = FeedRootViewController.controller(with: getAppBundle()) {
            vc.context = context
            vc.containerViewLayout = adopt.containerViewLayout
            vc.onSettings = { accountContext, filterItem, onUpdateFiltersHandler in
                adopt.navigationController?.pushViewController(
                    settings(with: accountContext, filterItem: filterItem, onUpdateFiltersHandler: onUpdateFiltersHandler),
                    animated: true
                )
            }
            vc.onSearch = {
                print("search:"+$0)
            }
            vc.onStart = {
                onStartHandler()
            }
            vc.getAdoptViewController = { adopt }
            vc.effectiveNavigationController = {
                adopt.navigationController
            }
            
            adopt.altController = vc
            adopt.onContainerViewLayoutHandler = { layout in
                vc.containerViewLayout = layout
            }
            
            adopt.tabBarItem.title = "feed".localized(Bundle(for: Self.self))
            adopt.tabBarItem.image = UIImage(named: "feed_tab")
            adopt.tabBarItem.selectedImage = UIImage(named: "feed_tab")
        }
        return adopt
    }
    
    static func settings(with accountContext: AccountContext, filterItem: FeedFilterItem, onUpdateFiltersHandler: @escaping EventClosure<FeedFilterItem>) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = FeedSettingsViewController.controller(with: getAppBundle()) {
            vc.accountContext = accountContext
            vc.filterItem = filterItem
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            vc.onTapPinnedChannels = { channelsTuple in
                adopt.navigationController?.pushViewController(
                    channelsList(with: accountContext, type: .pinned, channelsTyple: channelsTuple), animated: true
                )
            }
            vc.onTapHiddenChannels = { channelsTuple in
                adopt.navigationController?.pushViewController(
                    channelsList(with: accountContext, type: .hidden, channelsTyple: channelsTuple), animated: true
                )
            }
            vc.onUpdateFiltersHandler = onUpdateFiltersHandler
            adopt.altController = vc
        }
        return adopt
    }
    
    static func channelsList(with accountContext: AccountContext, type: FeedChannelsListViewController.TType, channelsTyple: FeedSettingsViewController.AllChannelsWithActiveChannels) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = FeedChannelsListViewController.controller(with: getAppBundle()) {
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            vc.type = type
            vc.channelsTuple = channelsTyple
            vc.accountContext = accountContext
            vc.onChannelChange = {
                print($0.0, ":", $0.1)
            }
            
            adopt.altController = vc
        }
        return adopt
    }
}
