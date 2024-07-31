//
//  LoyaltyEndpoint.swift
//  ElloAppApi
//
//  Created by Oleksii Zabrodin on 29.01.2024.
//

import Foundation

//  rpc CheckCode(Code) returns (mtproto.Bool);
//  rpc GenCode(GenCodeReq) returns (Code);
//  rpc AppendCode(Code) returns (mtproto.Bool);
//  rpc GetRefUsers(Code) returns (LoyaltyUser_Vector);
//  rpc CalcPercents(LoyaltyCalcReq) returns (LoyaltyCalc);
//  rpc GetCodes(GetList) returns (LoyaltyData_Vector);
//  rpc BindUser(Code) returns (Code);

public enum LoyaltyEndpoint {
    case checkCode(code: String, user_id: Int)
    case genCode(user_id: Int, is_business: Bool, loyalty_package_id: Int)
    case appendCode(code: String, user_id: Int)
    case getRefUsers(code: String, user_id: Int)
    case calcPercents(user_id: Int, ref_user_id: Int, percent: Double, summa: Double)
    case getPackages(is_business: Bool, is_default: Bool)
    case bindUser(code: String, user_id: Int)
}

extension LoyaltyEndpoint: Endpoint {
    public var service: MTProtoService {
        .loyalty
    }
    
    public var method: any MTProtoMethod {
        switch self {
        case .checkCode:
            return LoyaltyMethod.checkCode
        case .genCode:
            return LoyaltyMethod.genCode
        case .appendCode:
            return LoyaltyMethod.appendCode
        case .getRefUsers:
            return LoyaltyMethod.getRefUsers
        case .calcPercents:
            return LoyaltyMethod.calcPercents
        case .getPackages:
            return LoyaltyMethod.getPackages
        case .bindUser:
            return LoyaltyMethod.bindUser
        }
    }
    
    public var data: [String: Any] {
        switch self {
        case .checkCode(let code, let user_id):
            return [
                "code": code,
                "user_id": user_id
            ]
        case .genCode(let user_id, let is_business, let loyalty_package_id):
            return [
                "user_id": user_id,
                "is_business": is_business,
                "loyalty_package_id": loyalty_package_id
            ]
        case .appendCode(let code, let user_id):
            return [
                "code": code,
                "user_id": user_id
            ]
        case .getRefUsers(let code, let user_id):
            return [
                "code": code,
                "user_id": user_id
            ]
        case .calcPercents(let user_id, let ref_user_id, let percent, let summa):
            return [
                "user_id": user_id,
                "ref_user_id": ref_user_id,
                "percent": percent,
                "summa": summa
            ]
        case .getPackages(let is_business, let is_default):
            return [
                "is_business": is_business,
                "is_default": is_default
            ]
        case .bindUser(let code, let user_id):
            return [
                "code": code,
                "user_id": user_id
            ]
        }
    }
}
