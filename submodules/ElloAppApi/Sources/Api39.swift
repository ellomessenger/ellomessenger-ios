//
//  Api39.swift
//  ElloAppApi
//
//  Created by Oleksii Zabrodin on 29.01.2024.
//

import Foundation

public extension Api.loyalty {
    typealias LoyaltyResponse<T> = (FunctionDescription, Buffer, DeserializeFunctionResponse<T>)
    
    struct User: MTProtoResponse {
        public var id: Int
        
        public init(id: Int) {
            self.id = id
        }
    }
    
    struct Pagination: MTProtoResponse {
        public var page: Int
        public var per_page: Int
        
        public init(page: Int, per_page: Int) {
            self.page = page
            self.per_page = per_page
        }
    }

    struct UserWithPagination: MTProtoResponse {
        public var id: Int
        public var pagination: Pagination
        
        public init(id: Int, pagination: Pagination) {
            self.id = id
            self.pagination = pagination
        }
    }
    
    struct Code: MTProtoResponse {
        public var code: String
        public var user_id: Int
        
        public init(code: String, user_id: Int) {
            self.code = code
            self.user_id = user_id
        }
        
        public static func parse(_ reader: BufferReader) -> Code? {
            reader.reset()
            let _1 = reader.readInt32()
            print(_1 as Any)
            
            var _2: String?
            _2 = parseString(reader)
            if let _2 {
                print(_2)
            }
            
            struct CodeKeyValue:Decodable {
                let code:String?
            }
            
            if let jsonData = _2?.data(using: .utf8),
               let object = try? JSONDecoder().decode(CodeKeyValue.self, from: jsonData),
                let objectCode = object.code,
               let userId = _1 {
                print(object)
                return Code(code: objectCode, user_id: Int(userId))
            }
            
            return nil
        }
    }
    
    struct CodeWithPackage: MTProtoResponse {
        public var code: String
        public var user_id: Int
        public var package_data: LoyaltyData
        
        public init(code: String, user_id: Int, package_data:LoyaltyData) {
            self.code = code
            self.user_id = user_id
            self.package_data = package_data
        }
        
        public static func parse(_ reader: BufferReader) -> CodeWithPackage? {
            reader.reset()
            let _1 = reader.readInt32()
            print(_1 as Any)
            
            var _2: String?
            _2 = parseString(reader)
            if let _2 {
                print(_2)
            }
            
            if let jsonData = _2?.data(using: .utf8),
               let object = try? JSONDecoder().decode(CodeWithPackage.self, from: jsonData)
            {
                print(object)
                return object
            }
            
            return nil
        }
    }

    struct Loyalty: MTProtoResponse {
        public var id: Int
        public var created_at: Int
        public var user_id: Int
        public var loyalty_code_id: Int
        
        public static func parse(_ reader: BufferReader) -> Loyalty? {
            reader.reset()
            let _1 = reader.readInt32()
            print(_1 as Any)
            let _2 = reader.readInt32()
            print(_2 as Any)
            let _3 = reader.readInt32()
            print(_3 as Any)
            let _4 = reader.readInt32()
            print(_4 as Any)
            
            if let _1, let _2, let _3, let _4  {
                return Loyalty(id: Int(_1), created_at: Int(_2), user_id: Int(_3), loyalty_code_id: Int(_4))
            }
            
            return nil
        }
    }
    
    struct LoyaltyUserData: MTProtoResponse {
        public var id: Int
        public var username: String?
        public var first_name: String?
        public var last_name: String?
        public var photo_access_hash: String?
    }

    struct LoyaltyUser: MTProtoResponse {
        public var loyalty: Loyalty?
        public var user: LoyaltyUserData
        public var sum: Double?
        public var commission: Double?
        
        public static func parse(_ reader: BufferReader) -> Loyalty? {
            reader.reset()
            let _1 = reader.readInt32()
            print(_1 as Any)
            let _2 = reader.readInt32()
            print(_2 as Any)
            let _3 = reader.readDouble()
            print(_3 as Any)
            let _4 = reader.readDouble()
            print(_4 as Any)
            
            if let _1, let _2, let _3, let _4  {
                return Loyalty(id: Int(_1), created_at: Int(_2), user_id: Int(_3), loyalty_code_id: Int(_4))
            }
            
            return nil
        }

    }

    struct LoyaltyUser_Vector: MTProtoResponse {
        public var users: [LoyaltyUser]?
        public var total: Int?
        
        public static func parse(_ reader: BufferReader) -> LoyaltyUser_Vector? {
            reader.reset()
            let _1 = reader.readInt32()
            print(_1 as Any)
            
            var _2: String?
            _2 = parseString(reader)
            if let _2 {
                print(_2)
            }
            
            if let jsonData = _2?.data(using: .utf8),
               let object = try? JSONDecoder().decode(LoyaltyUser_Vector.self, from: jsonData)
            {
                print(object)
                return object
            }
            
            return nil
        }
    }

    struct LoyaltyCalc: MTProtoResponse {
        public var summa_user: Double
        public var summa_system: Double
        public var summa_ref: Double
        public var percent_ref: Double
        public var percent_user: Double
        public var percent_system: Double
        
        public static func parse(_ reader: BufferReader) -> LoyaltyCalc? {
            reader.reset()
            let _1 = reader.readDouble()
            print(_1 as Any)
            let _2 = reader.readDouble()
            print(_2 as Any)
            let _3 = reader.readDouble()
            print(_3 as Any)
            let _4 = reader.readDouble()
            print(_4 as Any)
            let _5 = reader.readDouble()
            print(_5 as Any)
            let _6 = reader.readDouble()
            print(_6 as Any)
            
            if let _1, let _2, let _3, let _4, let _5, let _6  {
                return LoyaltyCalc(summa_user: _1, summa_system: _2, summa_ref: _3, percent_ref: _4, percent_user: _5, percent_system: _6)
            }
            
            return nil
        }
    }

    struct LoyaltyData: MTProtoResponse {
        public var id: Int
        public var percent: Double?
        public var percent_owner: Double?
        public var bonus: Double?
        public var is_business: Bool?
        public var is_default: Bool?
        public var name: String?
        public var desc: String?
        
        public static func parse(_ reader: BufferReader) -> LoyaltyData? {
            reader.reset()
            let _1 = reader.readInt32()
            let _2 = reader.readDouble()
            let _3 = reader.readDouble()
            let _4 = reader.readDouble()
            let _5:Bool = 0 != reader.readInt32()
            let _6:Bool = 0 != reader.readInt32()
            let _7: String? = parseString(reader)
            let _8: String? = parseString(reader)

            struct NameKeyValue:Decodable { let name:String? }
            struct DescKeyValue:Decodable { let desc:String? }

            if let jsonData7 = _7?.data(using: .utf8),
               let object7 = try? JSONDecoder().decode(NameKeyValue.self, from: jsonData7),
               let objectCode7 = object7.name,
               let jsonData8 = _8?.data(using: .utf8),
               let object8 = try? JSONDecoder().decode(DescKeyValue.self, from: jsonData8),
               let objectCode8 = object8.desc,
               let _1, let _2, let _3, let _4 {
                return LoyaltyData(id: Int(_1), percent: _2, percent_owner: _3, bonus: _4,
                                   is_business: _5, is_default: _6, name: objectCode7, desc: objectCode8)
            }
            
            return nil
        }
    }
    
    struct LoyaltyDataWithSum: MTProtoResponse {
        public var loyalty_data: LoyaltyData
        public var count_users: Int?
        public var sum: Double?
        
        public static func parse(_ reader: BufferReader) -> LoyaltyDataWithSum? {
            reader.reset()
            let _1 = reader.readInt32()
            print(_1 as Any)
            
            var _2: String?
            _2 = parseString(reader)
            if let _2 {
                print(_2)
            }
            
            if let jsonData = _2?.data(using: .utf8),
               let object = try? JSONDecoder().decode(LoyaltyDataWithSum.self, from: jsonData)
            {
                print(object)
                return object
            }
            
            return nil

        }
    }

    struct LoyaltyData_Vector: MTProtoResponse {
        public var Loyalties: [LoyaltyData]
        
        public static func parse(_ reader: BufferReader) -> LoyaltyData_Vector? {
            reader.reset()
            let _1 = reader.readInt32()
            print(_1 as Any)
            
            let _2 = parseString(reader)
            print(_2 ?? "empty")
            
//            let object = try? JSONDecoder().decode([LoyaltyData.self], from: jsonData)
            
            struct CodeKeyValue:Decodable {
                let Loyalties:String?
            }
            
//            if let jsonData = _2?.data(using: .utf8),
//               let object = try? JSONDecoder().decode(CodeKeyValue.self, from: jsonData),
//                let objectCode = object.code,
//                print(object)
//                return nil
//            }
            
            return nil
        }

    }

    struct LoyaltyCalcReq: MTProtoResponse {
        public var user_id: Int
        public var ref_user_id: Int
        public var percent: Double
        public var summa: Double
    }

}


public extension Api.loyalty {
    static func checkCode(with code: Code) -> LoyaltyResponse<Api.Bool> {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
        
        let dict: [String: Any] = [
            "service": MTProtoService.loyalty.rawValue,
            "method": LoyaltyMethod.checkCode.rawValue,
            "data": [
                "code": code.code,
                "user_id": code.user_id
            ] as [String : Any]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "loyalty.checkCode",
            parameters: [("data", String(describing: dict))]
        )
        
        return (functionDescription, buffer, DeserializeFunctionResponse { (buffer: Buffer) -> Api.Bool? in
            
            struct PredicateNameKeyValue:Decodable {
                let predicate_name:String?
            }
            
            let reader = BufferReader(buffer)
            var result: Api.Bool?
            if let _ = reader.readInt32(),
               let jsonData = parseString(reader)?.data(using: .utf8),
               let object = try? JSONDecoder().decode(PredicateNameKeyValue.self, from: jsonData),
               let objectCode = object.predicate_name {
                result = Api.Bool.apiBool(with: objectCode) //Api.parse(reader, signature: signature) as? Api.Bool
            }
            
            return result
        })
    }
        
    static func genCode(user_id: Int, is_business: Bool, loyalty_package_id: Int) -> LoyaltyResponse<Code> {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
            
        let dict: [String: Any] = [
            "service": MTProtoService.loyalty.rawValue,
            "method": LoyaltyMethod.genCode.rawValue,
            "data": [
                "user_id": user_id,
                "is_business": is_business,
                "loyalty_package_id": loyalty_package_id
            ] as [String : Any]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "loyalty.genCode",
            parameters: [("data", String(describing: dict))]
        )
        
        return (functionDescription, buffer, DeserializeFunctionResponse { (buffer: Buffer) -> Code? in
            let reader = BufferReader(buffer)
            guard let _ = reader.readInt32() else {
                return nil
            }
            
            return Code.parse(reader)
        })
    }

    static func genBonusCode(user: Api.loyalty.User) -> LoyaltyResponse<CodeWithPackage> {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
            
        let dict: [String: Any] = [
            "service": MTProtoService.loyalty.rawValue,
            "method": LoyaltyMethod.genCode.rawValue,
            "data": [
                "user": "{ \"id\" : \(user.id) }"
            ] as [String : Any]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "loyalty.genBonusCode",
            parameters: [("data", String(describing: dict))]
        )
        
        return (functionDescription, buffer, DeserializeFunctionResponse { (buffer: Buffer) -> CodeWithPackage? in
            let reader = BufferReader(buffer)
            guard let _ = reader.readInt32() else {
                return nil
            }
            
            return CodeWithPackage.parse(reader)
        })
    }

    static func appendPartnerCode(with code: Code) -> LoyaltyResponse<Api.Bool> {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
        
        let dict: [String: Any] = [
            "service": MTProtoService.loyalty.rawValue,
            "method": LoyaltyMethod.appendCode.rawValue,
            "data": [
                "code": code.code,
                "user_id": code.user_id
            ] as [String : Any]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "loyalty.appendPartnerCode",
            parameters: [("data", String(describing: dict))]
        )
        
        return (functionDescription, buffer, DeserializeFunctionResponse { (buffer: Buffer) -> Api.Bool? in
            
            struct PredicateNameKeyValue:Decodable {
                let predicate_name:String?
            }
            
            let reader = BufferReader(buffer)
            var result: Api.Bool?
            if let _ = reader.readInt32(),
               let jsonData = parseString(reader)?.data(using: .utf8),
               let object = try? JSONDecoder().decode(PredicateNameKeyValue.self, from: jsonData),
               let objectCode = object.predicate_name {
                result = Api.Bool.apiBool(with: objectCode)
            }
            
            return result
        })
    }

    //TODO UserWithPagination
    static func getRefUsers(with userWithPagination: UserWithPagination) -> LoyaltyResponse<LoyaltyUser_Vector> {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
            
        let dict: [String: Any] = [
            "service": MTProtoService.loyalty.rawValue,
            "method": LoyaltyMethod.getRefUsers.rawValue,
            "data": [
                "id": userWithPagination.id,
                "pagination": [ "page": userWithPagination.pagination.page, "per_page": userWithPagination.pagination.per_page ]
            ] as [String : Any]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "loyalty.getRefUsers",
            parameters: [("data", String(describing: dict))]
        )
        
        return (functionDescription, buffer, DeserializeFunctionResponse { (buffer: Buffer) -> LoyaltyUser_Vector? in
            let reader = BufferReader(buffer)
            guard let _ = reader.readInt32() else {
                return nil
            }
            
            return LoyaltyUser_Vector.parse(reader)
        })
    }

    static func calcPercents(loyaltyCalcReq: LoyaltyCalcReq) -> LoyaltyResponse<LoyaltyCalc> {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
            
        let dict: [String: Any] = [
            "service": MTProtoService.loyalty.rawValue,
            "method": LoyaltyMethod.calcPercents.rawValue,
            "data": [
                "user_id": loyaltyCalcReq.user_id,
                "ref_user_id": loyaltyCalcReq.ref_user_id,
                "percent": loyaltyCalcReq.percent,
                "summa": loyaltyCalcReq.summa
            ] as [String : Any]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "loyalty.calcPercents",
            parameters: [("data", String(describing: dict))]
        )
        
        return (functionDescription, buffer, DeserializeFunctionResponse { (buffer: Buffer) -> LoyaltyCalc? in
            let reader = BufferReader(buffer)
            guard let _ = reader.readInt32() else {
                return nil
            }
            
            return LoyaltyCalc.parse(reader)
        })
    }

    static func getPackages(is_business: Bool, is_default: Bool) -> LoyaltyResponse<LoyaltyData_Vector> {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
            
        let dict: [String: Any] = [
            "service": MTProtoService.loyalty.rawValue,
            "method": LoyaltyMethod.getPackages.rawValue,
            "data": [
                "is_business": is_business,
                "is_default": is_default
            ] as [String : Any]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "loyalty.getPackages",
            parameters: [("data", String(describing: dict))]
        )
        
        return (functionDescription, buffer, DeserializeFunctionResponse { (buffer: Buffer) -> LoyaltyData_Vector? in
            let reader = BufferReader(buffer)
            guard let _ = reader.readInt32() else {
                return nil
            }
            
            return LoyaltyData_Vector.parse(reader)
        })
    }

    static func bindUserPartner(with code: Code) -> LoyaltyResponse<Code> {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
            
        let dict: [String: Any] = [
            "service": MTProtoService.loyalty.rawValue,
            "method": LoyaltyMethod.bindUser.rawValue,
            "data": [
                "code": code.code,
                "user_id": code.user_id
            ] as [String : Any]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "loyalty.bindUserPartner",
            parameters: [("data", String(describing: dict))]
        )
        
        return (functionDescription, buffer, DeserializeFunctionResponse { (buffer: Buffer) -> Code? in
            let reader = BufferReader(buffer)
            guard let _ = reader.readInt32() else {
                return nil
            }
            
            return Code.parse(reader)
        })
    }
    
    static func saveBonusCode(with code: Code) -> LoyaltyResponse<Api.Bool> {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
        
        let dict: [String: Any] = [
            "service": MTProtoService.loyalty.rawValue,
            "method": LoyaltyMethod.saveBonusCode.rawValue,
            "data": [
                "code": code.code,
                "user_id": code.user_id
            ] as [String : Any]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "loyalty.saveBonusCode",
            parameters: [("data", String(describing: dict))]
        )
        
        return (functionDescription, buffer, DeserializeFunctionResponse { (buffer: Buffer) -> Api.Bool? in
            
            struct PredicateNameKeyValue:Decodable {
                let predicate_name:String?
            }
            
            let reader = BufferReader(buffer)
            var result: Api.Bool?
            if let _ = reader.readInt32(),
               let jsonData = parseString(reader)?.data(using: .utf8),
               let object = try? JSONDecoder().decode(PredicateNameKeyValue.self, from: jsonData),
               let objectCode = object.predicate_name {
                result = Api.Bool.apiBool(with: objectCode)
            }
            
            return result
        })
    }

    static func activateBonusCode(_ user: Api.loyalty.User) -> LoyaltyResponse<Api.Bool> {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
            
        let dict: [String: Any] = [
            "service": MTProtoService.loyalty.rawValue,
            "method": LoyaltyMethod.activateBonusCode.rawValue,
            "data": [
                "user": "{ \"id\" : \(user.id) }"
            ] as [String : Any]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "loyalty.activateBonusCode",
            parameters: [("data", String(describing: dict))]
        )
        
        return (functionDescription, buffer, DeserializeFunctionResponse { (buffer: Buffer) -> Api.Bool? in
            struct PredicateNameKeyValue:Decodable {
                let predicate_name:String?
            }
            
            let reader = BufferReader(buffer)
            var result: Api.Bool?
            if let _ = reader.readInt32(),
               let jsonData = parseString(reader)?.data(using: .utf8),
               let object = try? JSONDecoder().decode(PredicateNameKeyValue.self, from: jsonData),
               let objectCode = object.predicate_name {
                result = Api.Bool.apiBool(with: objectCode)
            }
            
            return result
        })
    }

    static func getCurrentUserCodeProgram(user: Api.loyalty.User) -> LoyaltyResponse<LoyaltyData> {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
            
        let dict: [String: Any] = [
            "service": MTProtoService.loyalty.rawValue,
            "method": LoyaltyMethod.getCurrentUserCodeProgram.rawValue,
            "data": [
                "user": "{ \"id\" : \(user.id) }"
            ] as [String : Any]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "loyalty.getCurrentUserCodeProgram",
            parameters: [("data", String(describing: dict))]
        )
        
        return (functionDescription, buffer, DeserializeFunctionResponse { (buffer: Buffer) -> LoyaltyData? in
            let reader = BufferReader(buffer)
            guard let _ = reader.readInt32() else {
                return nil
            }
            
            return LoyaltyData.parse(reader)
        })
    }

    static func getLoyaltyBonusDataWithSum(user: Api.loyalty.User) -> LoyaltyResponse<LoyaltyDataWithSum> {
        let buffer = Buffer()
        buffer.appendInt32(1511592262)
        buffer.appendInt32(1840491641)
            
        let dict: [String: Any] = [
            "service": MTProtoService.loyalty.rawValue,
            "method": LoyaltyMethod.getLoyaltyBonusDataWithSum.rawValue,
            "data": [
                "user": "{ \"id\" : \(user.id) }"
            ] as [String : Any]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            serializeString(jsonStr, buffer: buffer, boxed: false)
        }
        
        let functionDescription = FunctionDescription(
            name: "loyalty.getLoyaltyBonusDataWithSum",
            parameters: [("data", String(describing: dict))]
        )
        
        return (functionDescription, buffer, DeserializeFunctionResponse { (buffer: Buffer) -> LoyaltyDataWithSum? in
            let reader = BufferReader(buffer)
            guard let _ = reader.readInt32() else {
                return nil
            }
            
            return LoyaltyDataWithSum.parse(reader)
        })
    }

}
