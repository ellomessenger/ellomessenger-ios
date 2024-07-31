//
//  ReusableViews+Identifiers.swift
//  _idx_ELBase_BCF77863_ios_min14.0
//
//

import UIKit

public extension UICollectionReusableView {
    static var reuseIdentifier: String {
        String(describing: Self.self)
    }
}

public extension UITableViewCell {
    static var reuseIdentifier: String {
        String(describing: Self.self)
    }
}
