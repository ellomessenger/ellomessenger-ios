//
//  Endpoint.swift
//  _idx_ElloAppApi_8DB5AC7C_ios_min14.0
//
//

import Foundation

public protocol Endpoint {
    var service: MTProtoService { get }
    var method: any MTProtoMethod { get }
    var data: [String: Any] { get }
}
