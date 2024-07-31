//
//  BankWithdrawRequisitesItem.swift
//  _idx_ElloAppApi_E33B064A_ios_min14.0
//

import Foundation

public struct BankWithdrawRequisitesItem: MTProtoResponse {
    
    public var userId: Int
    public var requisitesId: Int
    public var requisitesUuid: String
    @DecodableDefault.EmptyString
    public var status: String
    public var personInfo: PersonInfo
    public var bankInfo: BankInfo
    public var addressInfo: AddressInfo
    @DecodableDefault.EmptyString
    public var recipientType: String
    @DecodableDefault.EmptyString
    public var businessIdNumber: String
}

public struct PersonInfo: MTProtoResponse {
    public var firstName: String
    public var lastName: String
    public var phoneNumber: String
    public var email: String
}

public struct BankInfo: MTProtoResponse {
    public var country: String
    public var name: String
    @DecodableDefault.EmptyString
    public var routingNumber: String
    @DecodableDefault.EmptyString
    public var street: String
    @DecodableDefault.EmptyString
    public var city: String
    @DecodableDefault.EmptyString
    public var state: String
    @DecodableDefault.EmptyString
    public var swift: String
    @DecodableDefault.EmptyString
    public var address: String
    @DecodableDefault.EmptyString
    public var postalCode: String
    @DecodableDefault.EmptyString
    public var zipCode: String
    @DecodableDefault.EmptyString
    public var recipientAccountNumber: String
}

public struct AddressInfo: MTProtoResponse {
    @DecodableDefault.EmptyString
    public var address: String
    @DecodableDefault.EmptyString
    public var street: String
    @DecodableDefault.EmptyString
    public var city: String
    @DecodableDefault.EmptyString
    public var state: String
    @DecodableDefault.EmptyString
    public var region: String
    @DecodableDefault.EmptyString
    public var zipCode: String
    @DecodableDefault.EmptyString
    public var postalCode: String
}
