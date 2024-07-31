//
//  ELCallsController.swift
//  _idx_ELProfileUI_1EB5A3E4_ios_min11.0
//
//

import Foundation
import UIKit
import Display
import ELBase

public final class ELCallsController {
    
    public static func root() -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = CallsListViewController.controller {
            vc.onSelectItem = {
                print("selected item: \($0)")
            }
            vc.onTapDeleteAll = {
                print("should delete all")
            }
            vc.onTapDeleteItem = {
                print("should delete item: \($0)")
            }
            vc.onTapSegment = {
                print("should filter by: \($0)")
            }
            adopt.altController = vc
            
            adopt.tabBarItem.title = "calls".localized(Bundle(for: Self.self))
            adopt.tabBarItem.image = UIImage(named: "calls-tab", in: Bundle(for: Self.self), compatibleWith: nil)
            adopt.tabBarItem.selectedImage = UIImage(named: "calls-tab", in: Bundle(for: Self.self), compatibleWith: nil)
        }
        return adopt
    }
}
