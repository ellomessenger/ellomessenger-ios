//
//  ItemsListViewController.swift
//  _idx_ELProfileUI_1EB5A3E4_ios_min11.0
//
//

import UIKit
import ELBase

public struct Item {
    var icon: UIImage?
    var title: String
    
    public init(icon: UIImage? = nil, title: String) {
        self.icon = icon
        self.title = title
    }
}

class ItemsListViewController: BaseViewController {
    
    // MARK: - Public
    
    var items: [Item] = [] {
        didSet { tableView?.reloadData() }
    }
    
    var onTapItem: EventClosure<Item>?
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .clear
        setupShadow(tableView?.superview)
        tableView?.reloadData()
    }
    
    
    override func storyboardName() -> String {
        return "ELProfileUI"
    }
    
    // MARK: - Private
    
    @IBOutlet private weak var tableView: UITableView?
    
    private func setupShadow(_ view: UIView?) {
        view?.layer.cornerRadius = 13.0
        view?.layer.shadowColor = UIColor.gray.cgColor
        view?.layer.shadowOpacity = 0.5
        view?.layer.shadowRadius = 10.0
        view?.layer.shadowOffset = .zero
        view?.layer.shadowPath = UIBezierPath(rect: view?.bounds ?? .zero).cgPath
        view?.layer.shouldRasterize = true
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ItemsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "option") as? ELOptionCell {
            let item = items[indexPath.row]
            cell.title = item.title
            cell.icon = item.icon
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let item = items[indexPath.row]
        onTapItem?(item)
    }
}
