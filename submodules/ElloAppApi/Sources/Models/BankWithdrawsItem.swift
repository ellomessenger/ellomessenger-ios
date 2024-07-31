//
//  BankWithdrawsItem.swift
//  ElloAppApi
//
//  Created by Ello on 20.03.2024.
//

import Foundation

//@DecodableDefault.ZeroDouble
//@DecodableDefault.EmptyString

public struct PersonInfoItem: MTProtoResponse {
    public var firstName: String?
    public var lastName: String?
    public var phoneNumber: String?
    public var email: String?
    
    public init(firstName: String? = nil, lastName: String? = nil, phoneNumber: String? = nil, email: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.email = email
    }
}

public struct BankInfoItem: MTProtoResponse {
    public var country: String?
//    public var currency: String?
    public var routingNumber: String?
    public var name: String?
    public var street: String?
    public var city: String?
    public var state: String?
    public var swift: String?
    public var address: String?
    public var postalCode: String?
    public var zipCode: String?
    public var recipientAccountNumber: String?
    
    public init(country: String? = nil, 
                routingNumber: String? = nil,
                name: String? = nil,
                street: String? = nil,
                city: String? = nil,
                state: String? = nil,
                swift: String? = nil,
                address: String? = nil,
                postalCode: String? = nil,
                zipCode: String? = nil,
                recipientAccountNumber: String? = nil) {
        self.country = country
        self.routingNumber = routingNumber
        self.name = name
        self.street = street
        self.city = city
        self.state = state
        self.swift = swift
        self.address = address
        self.postalCode = postalCode
        self.zipCode = zipCode
        self.recipientAccountNumber = recipientAccountNumber
    }
}

public struct AddressInfoItem: MTProtoResponse {
    public var address: String?
    public var street: String?
    public var city: String?
    public var state: String?
    public var region: String?
    public var zipCode: String?
    public var postalCode: String?
    
    public init(address: String? = nil, street: String? = nil, city: String? = nil, state: String? = nil, region: String? = nil, zipCode: String? = nil, postalCode: String? = nil) {
        self.address = address
        self.street = street
        self.city = city
        self.state = state
        self.region = region
        self.zipCode = zipCode
        self.postalCode = postalCode
    }
    
    public var text:String {
        [zipCode, postalCode, state, region, city, street, address].compactMap({$0}).joined(separator: ", ")
    }
}

public enum BankWithdrawsRecipientType: String {
    case business
    case individual
}

public struct BankWithdrawsItem: MTProtoResponse {
    public var userId: Int?
    public var requisitesId: Int?
    public var requisitesUuid: String?
    public var recipientType: String?
    public var businessIdNumber: String?
    public var personInfo: PersonInfoItem?
    public var bankInfo: BankInfoItem?
    public var addressInfo: AddressInfoItem?
    public var isTemplate: Bool?
    public var templateId: Int?
    public var status: String?
    public var currency: String?

    public var isUSA: Bool? {
        guard let country = bankInfo?.country else { return nil }
        return "usa" == country.lowercased()
    }
    
    public var isBusiness: Bool? {
        guard let recipientType else { return nil }
        return recipientType.lowercased() == BankWithdrawsRecipientType.business.rawValue.lowercased()
    }
    
    public init(userId: Int? = nil,
                requisitesId: Int? = nil,
                requisitesUuid: String? = nil,
                status: String? = nil,
                recipientType: String? = nil,
                businessIdNumber: String? = nil,
                personInfo: PersonInfoItem? = nil,
                bankInfo: BankInfoItem? = nil,
                addressInfo: AddressInfoItem? = nil,
                isTemplate: Bool? = nil,
                templateId: Int? = nil,
                currency: String? = nil
    ){
        self.userId = userId
        self.requisitesId = requisitesId
        self.requisitesUuid = requisitesUuid
        self.status = status
        self.recipientType = recipientType
        self.businessIdNumber = businessIdNumber
        self.personInfo = personInfo
        self.bankInfo = bankInfo
        self.addressInfo = addressInfo
        self.isTemplate = isTemplate
        self.templateId = templateId
        self.currency = currency
    }
}

public struct BankWithdrawsItems: MTProtoResponse {
    public var data: [BankWithdrawsItem]?
}

public class BankWithdrawsItemWrapper {
    public var bankWithdrawsItem: BankWithdrawsItem
    
    public init(_ bankWithdrawsItem: BankWithdrawsItem) {
        self.bankWithdrawsItem = bankWithdrawsItem
    }
}
