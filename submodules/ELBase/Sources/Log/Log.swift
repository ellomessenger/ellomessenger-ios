//
//  Log.swift
//  _idx_ELBase_B0968433_ios_min11.0
//
//

import Foundation

public func debugLog(_ values:Any...) {
    #if DEBUG
    print(values)
    #endif
}
