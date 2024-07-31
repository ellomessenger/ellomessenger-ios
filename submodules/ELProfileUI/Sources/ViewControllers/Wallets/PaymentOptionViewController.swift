//
//  PaymentOptionViewController.swift
//  _idx_ELProfileUI_BBFAEC0E_ios_min11.0
//
//  Created by Damir Aushenov on 18/2/23.
//

import Foundation

import UIKit
import ELBase


class PaymentOptionViewController: BaseViewController{
    @IBOutlet var tableView: UITableView!
    
    @IBAction func nextTap(_ sender: Any) {
        onTapOption?()
    }
    public var onTapOption: VoidClosure?
    
    var values = [PaymentModel(icon: "Apple", title: "Apple pay"), PaymentModel(icon: "PayPal", title: "PayPal")]
    
    override func storyboardName() -> String {
        return "ELProfileUI"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
       
    }
}

struct PaymentModel {
    var icon: String
    var title: String
}


extension PaymentOptionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return values.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
       
        if let c = tableView.dequeueReusableCell(withIdentifier: "paymentСell") as? PamentOptionCell {
            c.payment = values[indexPath.row]
            cell = c
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let index = values[indexPath.row]
       
    }
}

// MARK: - UITextViewDelegate

