//
//  CallCell.swift
//  _idx_ELProfileUI_1EB5A3E4_ios_min11.0
//
//

import UIKit
import ELBase

struct Call {
    var avatar: UIImage?
    var name: String
    var date: Date
    var state: [State]
    
    init(avatar: UIImage? = nil, name: String, date: Date, state: [State]) {
        self.avatar = avatar
        self.name = name
        self.date = date
        self.state = state
    }
}

enum State: String {
    case incoming
    case outgoing
    case missedCalls
}

class CallCell: UITableViewCell {
    
    var call: Call?
    { didSet{ setupData() }}
    
    // MARK: - Private
    
    @IBOutlet private weak var callStateIV: UIImageView?
    @IBOutlet private weak var avatarIV: UIImageView?
    @IBOutlet private weak var nameL: UILabel?
    @IBOutlet private weak var stateL: UILabel?
    @IBOutlet private weak var dateL: UILabel?
    
    private func setupData() {
        if let icon = call?.avatar {
            avatarIV?.image = icon
        }
        callStateIV?.isHidden = !(call?.state.contains(.incoming) ?? true)
        nameL?.text = call?.name
        if (Date().timeIntervalSince1970 - (call?.date ?? Date()).timeIntervalSince1970) > 24*60*60 {
            dateL?.text = call?.date.stringWithFormat(.MMMddyyyy)
        } else {
            dateL?.text = call?.date.stringWithFormat(.hma)
        }
        stateL?.text = call?.state.compactMap{$0.localized(Bundle(for: Self.self))}.joined(separator: ", ").capitalizeFirst()
    }
}

//extension
