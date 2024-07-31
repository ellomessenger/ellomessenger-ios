//
//  LoyaltyMethod.swift
//  ElloAppApi
//
//  Created by Oleksii Zabrodin on 29.01.2024.
//

import Foundation

enum LoyaltyMethod: Int, MTProtoMethod {
    case appendCode = 100100
    case checkCode = 100200
    case genCode = 100300
    case getRefUsers = 100400
    case calcPercents = 100500
    case getPackages = 100600
    case bindUser = 100700
    case saveBonusCode = 100800
    case activateBonusCode = 100900
    case getCurrentUserCodeProgram = 101000
    case getLoyaltyBonusDataWithSum = 101100
}
