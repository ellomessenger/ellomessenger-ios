//
//  ChatListQuickLinksViewController.swift
//  ChatListUI
//
//

import UIKit
import ELBase
import Display

enum ChatListQuickLinksItem {
    case tips
    case earnInstant
    case contacts
    case broadcast
    case elloPay
    case aiSpace
}

class ChatListQuickLinksViewController: BaseViewController {

    struct ChatListQuickLinksViewModel {
        let item:ChatListQuickLinksItem
        
        var icon:UIImage {
            switch item {
            case .tips:
                UIImage(bundleImageName: "Chat List/QLTipsIcon")!
            case .earnInstant:
                UIImage(bundleImageName: "Chat List/QLEarnInstantlyIcon")!
            case .contacts:
                UIImage(bundleImageName: "Chat List/QLContactsIcon")!
            case .broadcast:
                UIImage(bundleImageName: "Chat List/QLBroadcastIcon")!
            case .elloPay:
                UIImage(bundleImageName: "Chat List/QLElloPayIcon")!
            case .aiSpace:
                UIImage(bundleImageName: "Chat List/QLAISpaceIcon")!
            }
        }
        
        var title:String {
            switch item {
            case .tips:
                "QLTipsTitle".localized
            case .earnInstant:
                "QLEarnInstantlyTitle".localized
            case .contacts:
                "QLContactsTitle".localized
            case .broadcast:
                "QLBroadcastTitle".localized
            case .elloPay:
                "QLElloPayTitle".localized
            case .aiSpace:
                "QLAISpaceTitle".localized
            }
        }
        
        var descript:String {
            switch item {
            case .tips:
                "QLTipsDescription".localized
            case .earnInstant:
                "QLEarnInstantlyDescription".localized
            case .contacts:
                "QLContactsDescription".localized
            case .broadcast:
                "QLBroadcastDescription".localized
            case .elloPay:
                "QLElloPayDescription".localized
            case .aiSpace:
                "QLAISpaceDescription".localized
            }
        }
        
        static let models:[ChatListQuickLinksViewModel] = [
            ChatListQuickLinksViewModel(item: .tips),
            ChatListQuickLinksViewModel(item: .earnInstant),
            ChatListQuickLinksViewModel(item: .contacts),
            ChatListQuickLinksViewModel(item: .broadcast),
            ChatListQuickLinksViewModel(item: .elloPay),
            ChatListQuickLinksViewModel(item: .aiSpace),
        ]
    }
    
    @IBOutlet var titelL: UILabel!
    @IBOutlet var tableView: UITableView!
    
    public var onItemTap: EventClosure<ChatListQuickLinksItem>?
    
    private let items:[ChatListQuickLinksViewModel] = ChatListQuickLinksViewModel.models
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    public override func storyboardName() -> String {
        return "ChatListUI"
    }

    override func backBtnDidTap(_ sender: AnyObject?) {
        super.backBtnDidTap(sender)
    }
}

extension ChatListQuickLinksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListQuickLinksTableViewCell", for: indexPath) as! ChatListQuickLinksTableViewCell
        cell.iconImageView.image = item.icon
        cell.titleLabel.text = item.title
        cell.descriptionLabel.text = item.descript
        return cell
    }
}

extension ChatListQuickLinksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        onItemTap?(item.item)
    }
}
