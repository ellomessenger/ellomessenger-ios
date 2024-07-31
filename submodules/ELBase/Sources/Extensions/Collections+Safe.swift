//
//  Collections+Safe.swift
//  _idx_ELBase_F411CA23_ios_min14.0
//
//

import Foundation

public extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
