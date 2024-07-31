//
//  CallsListViewController.swift
//  _idx_ELProfileUI_1EB5A3E4_ios_min11.0
//
//

import UIKit
import ELBase
import Lottie
import AppBundle

class CallsListViewController: BaseViewController {
    
    // MARK: - Public
    
    var items = [Call]()
    { didSet{ updateList() }}
    
    var onTapDeleteAll: VoidClosure?
    var onSelectItem: EventClosure<Call>?
    var onTapDeleteItem: EventClosure<Call>?
    var onTapSegment: EventClosure<CallsType>?
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateList()
    }
    
    override func localize() {
        emptyTitleL?.text = Localization.noRecentCalls.localized(Bundle(for: Self.self))
        emptyDescriptionTitleL?.text = "noRecentCallsDescription".localized
        headerSegmentControl?.removeAllSegments()
        CallsType.allCases.reversed().forEach{ [weak self] in
            self?.headerSegmentControl?.insertSegment(withTitle: $0.title, at: 0, animated: false)
        }
        headerSegmentControl?.selectedSegmentIndex = 0
    }
    
    override func storyboardName() -> String {
        return "ELCallsUI"
    }
    
    // MARK: - Private
    
    @IBOutlet private weak var headerSegmentControl: UISegmentedControl?
    
    @IBOutlet private weak var emptyView: UIStackView?
    @IBOutlet private weak var emptyTitleL: UILabel?
    @IBOutlet private weak var emptyDescriptionTitleL: UILabel?
    
    private lazy var animationView: AnimationView = {
        let animationView = AnimationView(name: "CallsPlaceholder")
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalToConstant: 160),
            animationView.heightAnchor.constraint(equalToConstant: 160)
        ])
        animationView.loopMode = .loop
        animationView.play()
        return animationView
    }()
    
    @IBOutlet private weak var tablleView: UITableView?
    
    private func updateList() {
        if let emptyView, items.isEmpty {
            animationView.play()
            if !emptyView.arrangedSubviews.contains(animationView) {
                emptyView.insertArrangedSubview(animationView, at: 0)
            }
        }
        emptyView?.isHidden = !items.isEmpty
        tablleView?.reloadData()
    }
}

// MARK: - Actions

extension CallsListViewController {
    
    @IBAction private func segmentDidTap(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: onTapSegment?(.allCalls)
        default: onTapSegment?(.missedCalls)
        }
    }
    
    @IBAction private func trashBtnDidTap(_ sender: AnyObject?) {
        onTapDeleteAll?()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension CallsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "call") as? CallCell {
            let call = items[indexPath.row]
            cell.call = call
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        onSelectItem?(items[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
}

// MARK: - Data

extension CallsListViewController {
    
    enum CallsType: String, CaseIterable {
        case allCalls
        case missedCalls
        
        var title: String {
            return self.localized(Bundle(for: CallsListViewController.self))
        }
    }
}

// MARK: - Localization

private enum Localization: String {
    case noRecentCalls
}
