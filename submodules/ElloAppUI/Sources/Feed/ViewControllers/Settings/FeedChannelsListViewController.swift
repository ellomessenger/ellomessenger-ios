//
//  FeedChannelsList.swift
//  _idx_ELFeedUI_26FB37DA_ios_min11.0
//
//

import UIKit
import ELBase
import AccountContext
import ElloAppCore
import ElloAppPresentationData

class FeedChannelsListViewController: BaseViewController {
    typealias AllChannelsWithActiveChannels = FeedSettingsViewController.AllChannelsWithActiveChannels
    
    var accountContext: AccountContext!
    private var presentationData: PresentationData {
        accountContext.sharedContext.currentPresentationData.with { $0 }
    }
    private let requestManager = RequestsManager()
    var channelsTuple: AllChannelsWithActiveChannels = ([], [], { _ in })
    var type: TType = .hidden
    { didSet{ setupHeader() }}
    
    var onChannelChange: EventClosure<(TType, ElloAppChannel)>?
    private var channels: [FeedChannel] = [] {
        didSet {
            tableView?.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupHeader()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestManager.getChannels(with: accountContext, ids: channelsTuple.allChannels) { [weak self] channels in
            guard let self else {
                return
            }
            
            self.channels = channels.compactMap {
                let feedChannel = FeedChannel(channel: $0)
                feedChannel.isActive = self.channelsTuple.switchedOnChannels.contains(feedChannel.id)
                
                return feedChannel
            }
        }
    }
    
    override func storyboardName() -> String {
        return "ELFeedUI"
    }

    // MARK: - Private
    
    @IBOutlet private weak var titleL: UILabel?
    @IBOutlet private weak var tableView: UITableView?
    
    private func setupHeader() {
        titleL?.text = type.title
    }
    
    override func backBtnDidTap(_ sender: AnyObject?) {
        channelsTuple.switchedOnChanged(channelsTuple.switchedOnChannels)
        
        super.backBtnDidTap(sender)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension FeedChannelsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "channel") as? FeedChannelCell else {
            return UITableViewCell()
        }
        
        let channel = channels[indexPath.row]
        cell.channel = channel
        cell.avatarNode.setPeer(
            context: accountContext,
            theme: presentationData.theme,
            peer: EnginePeer(channel.channel)
        )
        
        cell.onChange = { [weak self] channelTuple in
            guard let self else {return}
            switch channelTuple.enabled {
            case true:
                self.channelsTuple.switchedOnChannels.append(channelTuple.channelId)
            case false:
                self.channelsTuple.switchedOnChannels.removeAll { $0 == channelTuple.channelId }
                
            }
        }
        
        return cell
    }
}

// MARK: - Data

extension FeedChannelsListViewController {
    
    enum TType {
        case hidden
        case pinned
        
        var title: String {
            switch self {
            case .hidden:
                return Localization.hiddenChannels.localized(Bundle(for: FeedChannelsListViewController.self))
            case .pinned:
                return Localization.pinnedChannels.localized(Bundle(for: FeedChannelsListViewController.self))
            }
        }
    }
}

// MARK: - Localization

private enum Localization: String {
    case hiddenChannels
    case pinnedChannels
}
