//
//  BankTransferViewController.swift
//  ELProfileUI
//
//  Created by Oleksii Zabrodin on 18.03.2024.
//

import UIKit
import ELBase
import ElloAppApi

class BankTransferViewController: BaseViewController {

    enum BankTransferViewControllerCellType {
        case transfer(BankWithdrawsItem)
        case add
    }
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var confirmButton: UIButton!
    
    public var service: RequestService?
    public var onConfirm: EventClosure<BankWithdrawsItem>?
    public var onAdd: VoidClosure?
    public var onEdit: EventClosure<BankWithdrawsItem>?

    private var bankWithdrawsItems: [BankWithdrawsItem]?
    private var items:[BankTransferViewControllerCellType] {
        guard let bankWithdrawsItems else { return [.add] }
        return bankWithdrawsItems.map({.transfer($0)}) + [.add]
    }
    
    override func storyboardName() -> String {
        return "Wallet"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateItems()
    }
    
    @IBAction func onConfirmButtonTap(_ sender: Any) {
        if let indexPath = tableView?.indexPathForSelectedRow,
           case let .transfer(bankWithdrawsItem) = items[indexPath.row] {
                onConfirm?(bankWithdrawsItem)
        }
    }
    
    private func updateItems() {
        guard let service else { return }
        service.getBankWithdrawsRequisites(limit: 100, offset: 0, isTemplate: true) {[weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let bankWithdrawsItems):
                self.bankWithdrawsItems = bankWithdrawsItems.data
                confirmButton.isEnabled = !(bankWithdrawsItems.data?.isEmpty ?? true)
                tableView.reloadData()
                if !(bankWithdrawsItems.data?.isEmpty ?? true) {
                    tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UITableView.ScrollPosition.none)
                }
                
            case let .failure(error):
                print(error)
            }
        }
    }
}

extension BankTransferViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch items[indexPath.row] {
        case .transfer(let bankWithdrawsItem):
            let cell = tableView.dequeueReusableCell(withIdentifier: BankTransferTableViewCell.reuseIdentifier, for: indexPath) as! BankTransferTableViewCell
            cell.titleLabel.text = "\(bankWithdrawsItem.personInfo?.firstName ?? "") \(bankWithdrawsItem.personInfo?.lastName ?? "")"
            cell.addressLabel.text = bankWithdrawsItem.addressInfo?.text
            cell.descriptionLabel.text = bankWithdrawsItem.bankInfo?.name
            cell.onEdit = {[weak self] in
                if indexPath == tableView.indexPathForSelectedRow {
                    self?.onEdit?(bankWithdrawsItem)
                }
            }
            
            return cell
        case .add:
            let cell = tableView.dequeueReusableCell(withIdentifier: BankTransferAddTableViewCell.reuseIdentifier, for: indexPath) as! BankTransferAddTableViewCell
            cell.onAdd = {[weak self]in
                self?.onAdd?()
            }
            
            return cell
        }
    }
    
    
}

extension BankTransferViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch items[indexPath.row] {
        case .transfer:
            return 116
        case .add:
            return 51
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Bank transfer".localized
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch items[indexPath.row] {
        case .transfer:
            return indexPath
        case .add:
            return nil
        }
    }
}
