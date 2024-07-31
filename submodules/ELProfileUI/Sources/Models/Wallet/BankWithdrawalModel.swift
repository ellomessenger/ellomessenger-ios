//
//  BankWithdrawalModel.swift
//  _idx_ELProfileUI_8F51C9CF_ios_min14.0
//
//  Created by MacBookAir on 17.07.2023.
//

import Foundation
import ElloAppApi
import ELBase

public struct UserInfoObject {
    public var bankRoutingNumber: String
    public var firstName: String
    public var lastName: String
    public var country: String = "Country"
    public var phone: String
    public var email: String
    
    public init(bankRoutingNumber: String, firstName: String, lastName: String, country: String? = nil, phone: String, email: String) {
        self.bankRoutingNumber = bankRoutingNumber
        self.firstName = firstName
        self.lastName = lastName
        self.country = country ?? "Country"
        self.phone = phone
        self.email = email
    }
}

public struct UserAddressObject {
    public var address: String
    public var street: String
    public var city: String
    public var state: String
    public var zipCode: String
    public var receipientType: String
    public var idNumber: String
    public var currency: String
    
    public init(address: String, street: String, city: String, state: String, zipCode: String, receipientType: String, idNumber: String, currency: String = "USD") {
        self.address = address
        self.street = street
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.receipientType = receipientType
        self.idNumber = idNumber
        self.currency = currency
    }
}

public struct BankInfoObject {
    public var bankCountry: String
    public var bankName: String
    public var swift: String
    public var street: String
    public var city: String
    public var address: String
    public var zipCode: String
    public var recipientNumber: String
    public var messageRecipientBank: String
    
    public init(bankCountry: String, bankName: String, swift: String, street: String, city: String, address: String, zipCode: String, recipientNumber: String, messageRecipientBank: String) {
        self.bankCountry = bankCountry
        self.bankName = bankName
        self.swift = swift
        self.street = street
        self.address = address
        self.city = city
        self.zipCode = zipCode
        self.recipientNumber = recipientNumber
        self.messageRecipientBank = messageRecipientBank
    }
}

