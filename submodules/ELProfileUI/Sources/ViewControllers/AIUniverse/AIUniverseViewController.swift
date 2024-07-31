//
//  AIUniverseViewController.swift
//  _LocalDebugOptions
//
//  Created by Oleksii Zabrodin on 03.04.2024.
//

import UIKit
import ELBase
import ElloAppApi
import MessageUI
import Postbox

public enum SpaceItem {
    case chatMedia
    case poenix
    case aiBusinessForStudents
    case cancerPreventation
    
    var peerId:PeerId {
        switch self {
        case .chatMedia:
            PeerId.aiBotPeerID
        case .poenix:
            PeerId.aiPhoenixBotPeerID
        case .aiBusinessForStudents:
            PeerId.aiBusinessForStudentsBotPeerID
        case .cancerPreventation:
            PeerId.aiCancerPreventationBotPeerID
        }
    }
    
    var title:String {
        switch self {
        case .chatMedia:
            "AI Chat and Media"
        case .poenix:
            "Phoenix Suns"
        case .aiBusinessForStudents:
            "AI Business for students"
        case .cancerPreventation:
            "Cancer prevention"
        }
    }
    
    var subTitle:String {
        switch self {
        case .chatMedia:
            "General topics AI chat and image bot."
        case .poenix:
            "Sports AI chat and image bot."
        case .aiBusinessForStudents:
            "AI for business students chat bot."
        case .cancerPreventation:
            "AI tips for cancer prevention chat bot."
        }
    }
    
    var icon:UIImage {
        switch self {
        case .chatMedia:
            UIImage(named: "Wallet/transaction_history-ai", in: Bundle(for: AIUniverseViewController.self), with: nil)!
        case .poenix:
            UIImage(named: "Wallet/bot-phoenix-icon", in: Bundle(for: AIUniverseViewController.self), with: nil)!
        case .aiBusinessForStudents:
            UIImage(named: "Wallet/bot-businessForStudents-icon", in: Bundle(for: AIUniverseViewController.self), with: nil)!
        case .cancerPreventation:
            UIImage(named: "Wallet/bot-cancerPreventation-icon", in: Bundle(for: AIUniverseViewController.self), with: nil)!
        }
    }
}

public class AIUniverseViewController: BaseViewController {
    private struct SpaceViewModel {
        private var items:[SpaceItem]
        init(items: [SpaceItem]) {
            self.items = items
        }
        
    }

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contactUsButton: UIButton!
    @IBOutlet var tableView: UITableView!

    public var requestService:RequestService?
    public var onSelectedBot:((PeerId)->())?
    public var onBuyAiPack:(()->())?
    
    private var aiSubscriptionInfoItem:AISubscriptionInfoItem?
    private var ids:[Int]?
    private var viewModel:SpaceViewModel = SpaceViewModel(items: [.chatMedia, .poenix, .cancerPreventation, .aiBusinessForStudents])
    private var items:[SpaceItem] = [.chatMedia, .poenix, .cancerPreventation, .aiBusinessForStudents]
    
    public override func storyboardName() -> String {
        return "AIUniverse"
    }
    
    private var alert:UIAlertController?
    public override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }
    
    public func refresh() {
        requestService?.subscriptionInfo() {[weak self] result in // 776999
            guard let self else { return }
            switch result {
            case .success(let aiSubscriptionInfoItem):
                self.aiSubscriptionInfoItem = aiSubscriptionInfoItem
                tableView.reloadData()
                
            case .failure(let error):
                if case let .message(message) = error, message == "context deadline exceeded" {
                    DispatchQueue.main.async{[weak self]in
                        self?.refresh()
                    }
                }
                else {
                    if alert == nil {
                        self.alert = UIAlertController(title: "Common.Error".localized, message: nil, preferredStyle: .alert)
                        self.alert!.addAction(UIAlertAction(title: "Common.OK".localized, style: .cancel){[weak self] _ in self?.alert = nil})
                        self.present(alert!, animated: true)
                    }
                }
            }
        }
        
        requestService?.getAllBots() {[weak self] result in
            guard let self else { return }
            switch result {
            case .success(let ids):
                print(ids)
                tableView.reloadData()
                
            case .failure(_):
                if alert == nil {
                    self.alert = UIAlertController(title: "Common.Error".localized, message: nil, preferredStyle: .alert)
                    self.alert!.addAction(UIAlertAction(title: "Common.OK".localized, style: .cancel){[weak self] _ in self?.alert = nil})
                    self.present(alert!, animated: true)
                }
            }
        }
    }
    
    @IBAction func onContactUsTap(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let composeController = MFMailComposeViewController()
            composeController.setToRecipients(["info@ello.team"])
            composeController.mailComposeDelegate = self
            present(composeController, animated: true, completion: nil)
        } else {
            if alert == nil {
                self.alert = UIAlertController(title: "Can't send an email".localized, message: nil, preferredStyle: .alert)
                self.alert!.addAction(UIAlertAction(title: "Common.OK".localized, style: .cancel){[weak self] _ in self?.alert = nil})
                self.present(alert!, animated: true)
            }
        }
    }
}

extension AIUniverseViewController: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension AIUniverseViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count // ids?.count ?? 0
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AIUniverseTableViewCell") as! AIUniverseTableViewCell
        let item = items[indexPath.row]
        cell.icon.image = item.icon
        cell.title.text = item.title
        cell.subtitle.text = item.subTitle
        return cell
    }
}

extension AIUniverseViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "HeaderView") as! AIUniverseTotalTableViewCell
        header.textTotalLabel.text = String(aiSubscriptionInfoItem?.textTotal ?? 0)
        header.imageTotalLabel.text = String(aiSubscriptionInfoItem?.imgTotal ?? 0)
        header.onBuyAiPack = {[weak self]in
            guard let self else {return}
            self.onBuyAiPack?()
        }
        
        return header
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 416
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectedBot?(items[indexPath.row].peerId)
    }
}
