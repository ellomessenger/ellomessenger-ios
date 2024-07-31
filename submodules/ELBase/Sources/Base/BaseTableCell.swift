
import UIKit

//MARK: - Interactional protocols

public protocol BaseTableCellObjectDelegate:NSObjectProtocol {
    func shouldUpdateUIForObject(_ object:BaseTableCellObject)
}

public extension BaseTableCellObjectDelegate { // optionality
    func shouldUpdateUIForObject(_ object:BaseTableCellObject) { print("undefined \(#function)")}
}

public protocol SelectionDelegate : NSObjectProtocol {
    func didSelect(_ object:AnyObject, withValue value:AnyObject?)
}
public extension SelectionDelegate { // optionality
    func didSelect(_ object:AnyObject, withValue value:AnyObject?) { print("undefined \(#function)")}
}

//MARK: - UI and Object protocols

public protocol TableCellProtocol {
    var object:BaseTableCellObject? {get set}

    /// Here you should setup info to UI from BaseTableCellObject
    ///
    /// - Parameter object: An object that inherits BaseTableCellObject class
    func setup(fromObject object: BaseTableCellObject?)


    /// Here you should resign all possible keyboard interactors.
    func resignKeyboard()
}

public extension TableCellProtocol {
    func resignKeyboard() { print(" \(#function) optional") }
}

public protocol TableCellObjectProtocol {
    var index: IndexPath? {get set}
    /*weak*/ var cell: BaseTableCell? {get set}
    /*weak*/ var selectionDelegate:SelectionDelegate? {get set}
    /*weak*/ var uiUpdateDelegate:BaseTableCellObjectDelegate? {get set}

    var cellClass:UITableViewCell.Type! {get}
}


//MARK: - Implementation

public class BaseTableCell: UITableViewCell,TableCellProtocol {

    public var object: BaseTableCellObject?

    public func setup(fromObject object: BaseTableCellObject?) {
         fatalError(String(format:"internal func setInterface(fromObject object:BaseCollectionObject!) -> Should be overriden in %@", NSStringFromClass(self.classForCoder)));
    }
    public func resignKeyboard() {
    }
}


public class BaseTableCellObject:NSObject, TableCellObjectProtocol {

    public var index: IndexPath?
    public weak var cell: BaseTableCell?
    public weak var selectionDelegate:SelectionDelegate?
    public weak var uiUpdateDelegate:BaseTableCellObjectDelegate?

    public var cellClass:UITableViewCell.Type! {
        get{
            fatalError(String(format: "internal func getCellClass() -> Should be overriden in %@", NSStringFromClass(self.classForCoder)));
        }
    }
}


//MARK: - Private, Comparable

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l >= r
    default:
        return !(lhs < rhs)
    }
}
