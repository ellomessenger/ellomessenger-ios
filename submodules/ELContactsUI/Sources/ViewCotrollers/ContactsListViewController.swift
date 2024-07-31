//
//  ContactsListViewController.swift
//  _idx_AccountContext_C31630D9_ios_min11.0
//
//

import UIKit
import ELBase
import Postbox
import AnimationUI

public struct Contact {
    public var id: String = ""
    public var avatar: UIImage?
    public var name: String
    public var state: ContactState
    public var peerId: PeerId
    
    init(id: String, avatar: UIImage? = nil, name: String, state: ContactState = .none, peerId: PeerId) {
        self.id = id
        self.avatar = avatar
        self.name = name
        self.state = state
        self.peerId = peerId
    }
}

public enum ContactState {
    case none
    case online
    case lastSeeen(Date)
}

class ContactsListViewController: BaseViewController {
    
    typealias ReloadClosure = EventClosure<[Contact]>
    
    // MARK: - Public
    
    var contacts = [Contact]()
    { didSet{ updateList() }}
    
    var onTapShare: VoidClosure?
    var onSearch: EventClosure<String>?
    var onTapContact: EventClosure<Contact>?
    var onDeleteContact: EventClosure<Contact>?
    var needReload: EventClosure<ReloadClosure>?
    
    public func deactivateSearch() {
        searchBar?.resignFirstResponder()
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateList()
        needReload?({ [weak self] contacts in
            self?.contacts = contacts
        })
    }
    
    override func localize() {
        titleL?.text = Localization.contacts.localized(Bundle(for: Self.self))
        shareTitleL?.text = Localization.share.localized(Bundle(for: Self.self))
        emptyTitleL?.text = Localization.noContactsYet.localized(Bundle(for: Self.self))
        searchBar?.placeholder = Localization.search.localized(Bundle(for: Self.self))
        
        if let animationView = emptyAnimationView {
            animationNode.frame = animationView.frame
            animationView.addSubnode(animationNode)
        }
        
        animationNode.setAnimation(name: "NoContacts")
        animationNode.loop()
    }
    
    override func storyboardName() -> String {
        return "ELContactsUI"
    }
    
    // MARK: - Private
    
    @IBOutlet private weak var titleL: UILabel?
    
    @IBOutlet private weak var searchBar: UISearchBar?
    
    @IBOutlet private weak var shareContent: UIView?
    @IBOutlet private weak var shareTitleL: UILabel?
    
    @IBOutlet private weak var emptyAnimationView: UIView?
    @IBOutlet private weak var emptyView: UIView?
    @IBOutlet private weak var emptyTitleL: UILabel?
    
    @IBOutlet private weak var tableView: UITableView?
    private let animationNode = AnimationNode()
    
    private func updateList() {
        emptyView?.isHidden = contacts.count != 0
        tableView?.reloadData()
    }
}

// MARK: - Actions

extension ContactsListViewController {
    
    @IBAction private func shareBtnDidTap(_ sender: AnyObject?) {
        onTapShare?()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ContactsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if let c = tableView.dequeueReusableCell(withIdentifier: "contact") as? ContactCell {
            c.contact = contacts[indexPath.row]
            cell = c
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        onTapContact?(contacts[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: Localization.delete.localized(Bundle(for: Self.self))) { [weak self] (_, _, completionHandler) in
            guard let self else {
                return
            }
            self.onDeleteContact?(self.contacts[indexPath.row])
        }
        deleteAction.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}

// MARK: - UISearchBarDelegate

extension ContactsListViewController: UISearchBarDelegate {
    
    private static var searchTimer: Timer?
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        shareContent?.isHidden = !searchText.isEmpty
        
        ContactsListViewController.searchTimer?.invalidate()
        ContactsListViewController.searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
            self?.onSearch?(searchText)
        })
    }
}

// MARK: - Localization

private enum Localization: String {
    case contacts
    case share
    case search
    case noContactsYet
    case delete = "Common.Delete"
}
