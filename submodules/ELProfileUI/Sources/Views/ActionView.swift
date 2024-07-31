//
//  ActionView.swift
//  _idx_ELProfileUI_E448F2B0_ios_min11.0
//
//

import UIKit
import ELBase

// MARK: - Action

public enum Action {
    case edit
    case camera
}

// MARK: - ActionView

public class ActionView: BaseView {
    
    // MARK: - Public
    
    var onTap: VoidClosure?
    
    // MARK: - Lifecycle
    
    convenience init(type: Action, onTap: VoidClosure? = nil) {
        self.init()
        self.type = type
        self.onTap = onTap
        
        setupUI()
    }
    
    // MARK: - Private
    
    @IBOutlet private weak var icon: UIImageView?
    
    private var type: Action = .edit
    
    private func setupUI() {
        icon?.image = type.icon
    }
}

// MARK: - Actions

extension ActionView {
    
    @IBAction private func actionBtnDidTap(_ sender: AnyObject?) {
        onTap?()
    }
}

private extension Action {
    
    var icon: UIImage? {
        switch self {
            case .edit: return UIImage(named: "Action/edit", in: Bundle(for: ActionView.self), compatibleWith: nil)
            case .camera: return UIImage(named: "Action/change_photo", in: Bundle(for: ActionView.self), compatibleWith: nil)
        }
    }
}
