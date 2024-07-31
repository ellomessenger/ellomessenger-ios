//
//  ContactCell.swift
//  _idx_AccountContext_F228BDC1_ios_min11.0
//
//

import UIKit
import ELBase

class ContactCell: UITableViewCell {
    
    // MARK: - Public
    
    var contact: Contact?
    { didSet{ setupData() }}
    
    // MARK: - Private
    
    @IBOutlet private weak var selectionMark: UIImageView?
    
    @IBOutlet private weak var avatarIV: UIImageView?
    @IBOutlet private weak var nameL: UILabel?
    @IBOutlet private weak var stateL: UILabel?
    @IBOutlet private weak var initialsL: UILabel?
    
    private func setupData() {
        
        if let avatar = contact?.avatar {
            initialsL?.text = nil
            avatarIV?.image = avatar
        } else {
            avatarIV?.image = nil
            initialsL?.text = contact?.name.acronym.uppercased()
        }
        nameL?.text = contact?.name
        stateL?.text = contact?.state.described
        stateL?.textColor = contact?.state.color
    }
    
}

extension ContactState {
    
    var described: String {
        switch self {
            case .none: return " "
            case .online: return Localization.online.localized(Bundle(for: ContactCell.self)).capitalized
            case let .lastSeeen(date): return "\(Localization.lastSeen) \(date.stringWithFormat(.MMMddyyyy))"
        }
    }
    
    var color: UIColor {
        switch self {
            case .online: return UIColor(rgb: 0x0a49a5)
            default: return UIColor(rgb: 0x74747b)
        }
    }
}

private enum Localization: String {
    case online
    case lastSeen
}
