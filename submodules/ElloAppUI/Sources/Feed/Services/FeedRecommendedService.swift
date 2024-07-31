//
//  FeedRecommendedService.swift
//  ElloAppUI
//
//

import Foundation

protocol DataServiceDelegate: AnyObject {
    func dataServiceDidUpdateData(_ newData: DataModel)
}

enum DataField: Hashable {
    case all
    case isNew
    case isPaid
    case isCourse
    case isFree
    case country(String, String)
    case category(String)
    case genre(String)
    case q(String)
}

struct DataModel: Equatable {
    static func == (lhs: DataModel, rhs: DataModel) -> Bool {
        lhs.all == rhs.all &&
        lhs.isNew == rhs.isNew &&
        lhs.isPaid == rhs.isPaid &&
        lhs.isCourse == rhs.isCourse &&
        lhs.isFree == rhs.isFree &&
        lhs.country == rhs.country &&
        lhs.category == rhs.category &&
        lhs.genre == rhs.genre &&
        lhs.q == rhs.q
    }
    
    var all: Bool
    var isNew: Bool
    var isPaid: Bool
    var isCourse: Bool
    var isFree: Bool
    var country: (code: String, name: String)
    var category: String
    var genre: String
    var q: String
}

class DataService {
    private(set) var data: DataModel
    weak var delegate: DataServiceDelegate?
    
    init() {
        self.data = DataModel(
            all: true,
            isNew: false,
            isPaid: false,
            isCourse: false,
            isFree: false,
            country: (code: "", name: ""),
            category: "",
            genre: "",
            q: ""
        )
    }
    
    // Change the value of the field and send the data to the server
    func changeField(_ field: DataField) {
        let oldData = data
        
        switch field {
        case .all:
            resetFields()
            data.all = true
        case .isNew:
            resetFields()
            data.isNew = true
        case .isPaid:
            resetFields()
            data.isPaid = true
        case .isCourse:
            resetFields()
            data.isCourse = true
        case .isFree:
            resetFields()
            data.isFree = true
        case .country(let code, let name):
            data.country = (code, name)
        case .category(let stringValue):
            data.category = stringValue
        case .genre(let stringValue):
            data.genre = stringValue
        case .q(let stringValue):
            data.q = stringValue
        }
        
        if oldData != data {
            delegate?.dataServiceDidUpdateData(data)
        }
    }
    
    func isSelected(field: DataField) -> Bool {
        switch field {
        case .all:
            data.all
        case .isNew:
            data.isNew
        case .isPaid:
            data.isPaid
        case .isCourse:
            data.isCourse
        case .isFree:
            data.isFree
        case .country:
            false
        case .category:
            false
        case .genre:
            false
        case .q:
            false
        }
    }
    
    private func resetFields() {
        data.all = false
        data.isNew = false
        data.isPaid = false
        data.isCourse = false
        data.isFree = false
    }
}
