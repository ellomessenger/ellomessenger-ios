//
//  BankWithdrawalInfoObject.swift
//  ElloApp
//

import Foundation

public struct BankWithdrawalInfoObject {
    public var templateId: Int?
    public var isTemplate: Bool?
    public var recipientType: String?
    public var bankRoutingNumber: String?
    public var businessIdNumber: String?
    public var personalFirstName: String?
    public var personalLastName: String?
    public var personalPhone: String?
    public var personalEmail: String?
    public var message: String?
    public var currency: String?
    public var bankCountry: String?
    public var bankName: String?
    public var bankStreet: String?
    public var bankCity: String?
    public var bankState: String?
    public var bankSwift: String?
    public var bankAddress: String?
    public var bankPostalCode: String?
    public var bankZipCode: String?
    public var bankRecipientAccountNumber: String?
    public var userAddressAddres: String?
    public var userAddressStreet: String?
    public var userAddressCity: String?
    public var userAddressState: String?
    public var userAddressRegion: String?
    public var userAddressZipCode: String?
    public var userAddressPostalCode: String?
    
    public init(
        templateId: Int? = nil,
        isTemplate: Bool = false,
        recipientType: String = "",
        bankRoutingNumber: String = "",
        businessIdNumber: String = "",
        personalFirstName: String = "",
        personalLastName: String = "",
        personalPhone: String = "",
        personalEmail: String = "",
        message: String = "",
        currency: String = "usd",
        bankCountry: String = "Country",
        bankName: String = "",
        bankStreet: String = "",
        bankCity: String = "",
        bankState: String = "",
        bankSwift: String = "",
        bankAddress: String = "",
        bankPostalCode: String = "",
        bankZipCode: String = "",
        bankRecipientAccountNumber: String = "",
        userAddressAddres: String = "",
        userAddressStreet: String = "",
        userAddressCity: String = "",
        userAddressState: String = "",
        userAddressRegion: String = "",
        userAddressZipCode: String = "",
        userAddressPostalCode: String = ""
    ) {
        self.templateId = templateId
        self.isTemplate = isTemplate
        self.recipientType = recipientType
        self.bankRoutingNumber = bankRoutingNumber
        self.businessIdNumber = businessIdNumber
        self.personalFirstName = personalFirstName
        self.personalLastName = personalLastName
        self.personalPhone = personalPhone
        self.personalEmail = personalEmail
        self.message = message
        self.currency = currency
        self.bankCountry = bankCountry
        self.bankName = bankName
        self.bankStreet = bankStreet
        self.bankCity = bankCity
        self.bankState = bankState
        self.bankSwift = bankSwift
        self.bankAddress = bankAddress
        self.bankPostalCode = bankPostalCode
        self.bankZipCode = bankZipCode
        self.bankRecipientAccountNumber = bankRecipientAccountNumber
        self.userAddressAddres = userAddressAddres
        self.userAddressStreet = userAddressStreet
        self.userAddressCity = userAddressCity
        self.userAddressState = userAddressState
        self.userAddressRegion = userAddressRegion
        self.userAddressZipCode = userAddressZipCode
        self.userAddressPostalCode = userAddressPostalCode
    }
}
