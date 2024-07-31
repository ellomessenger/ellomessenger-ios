//
//  UIView+constraint.swift
//  Cleaning
//
//  Created by Anna Dudina on 22.02.2021
//

import UIKit


public extension UIView {
    
    func addSubviewWithSameSize(_ view: UIView) {
        addSubviewWithOffsets(view)
    }
    
    func insertSubviewWithSameSize(_ view: UIView, belowSubview:UIView) {
        insertSubview(view, belowSubview: belowSubview)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.leftAnchor.constraint(equalTo: self.leftAnchor),
            view.rightAnchor.constraint(equalTo: self.rightAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func insertSubviewWithSameSize(_ view: UIView, aboveSubview:UIView) {
        insertSubview(view, aboveSubview: aboveSubview)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.leftAnchor.constraint(equalTo: self.leftAnchor),
            view.rightAnchor.constraint(equalTo: self.rightAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    
    func addSubviewWithOffsets(_ view: UIView, top:CGFloat = 0.0, left:CGFloat = 0.0, right:CGFloat = 0.0, bottom:CGFloat = 0.0) {
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor, constant: top),
            view.leftAnchor.constraint(equalTo: self.leftAnchor, constant: left),
            view.rightAnchor.constraint(equalTo: self.rightAnchor, constant: right),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bottom)
        ])
    }
}
