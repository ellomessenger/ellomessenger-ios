//
//  ToUpCell.swift
//  _idx_ELProfileUI_BBFAEC0E_ios_min11.0
//
//  Created by Damir Aushenov on 18/2/23.
//


import UIKit
import ELLanguageUI
import ElloAppApi

class ToUpCell: UITableViewCell {
    
    @IBOutlet private weak var circle: UIImageView?
    @IBOutlet private weak var icon: UIImageView?
    @IBOutlet private weak var name: UILabel?
   
    private let radioBtnOnImg = UIImage(named: "radio-on", in: Bundle(for: LanguagesViewController.self), compatibleWith: nil)
    private let radioBtnOffImg = UIImage(named: "radio-off", in: Bundle(for: LanguagesViewController.self), compatibleWith: nil)
    var toUp: TopUpMethodModel?
    { didSet{ updateData() }}
    
    
    func updateData() {
        name?.text = toUp?.title
        icon?.isHidden = toUp?.icon == nil ? true : false
        icon?.image =  UIImage(named: toUp?.icon ?? "", in: Bundle(for: Self.self), compatibleWith: nil)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            circle?.image = radioBtnOnImg
        } else {
            circle?.image = radioBtnOffImg
        }
    }
}
    

