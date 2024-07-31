//
//  UIView+Rounded.swift
//
//
//

import UIKit

public extension UIView {
        
    func roundCorners(_ corners:UIRectCorner, radius:CGFloat) {

        let maskPath = UIBezierPath(roundedRect: self.bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
        let shape = CAShapeLayer.init()
        shape.path = maskPath.cgPath
        self.layer.mask = shape
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
        get { return layer.cornerRadius }
    }
    
    @IBInspectable var smoothCorners: Bool {
        set {
            layer.cornerCurve = newValue ? .continuous : .circular
        }
        get {
            layer.cornerCurve == .continuous
        }
    }
    
    @IBInspectable var roundTopLeft: Bool {
        set{ if newValue { self.layer.maskedCorners.insert(.layerMinXMinYCorner)
        } else { self.layer.maskedCorners.remove(.layerMinXMinYCorner)
        }}
        get{ return self.layer.maskedCorners.contains(.layerMinXMinYCorner)}
    }
    
    @IBInspectable var roundTopRight: Bool {
        set{ if newValue { self.layer.maskedCorners.insert(.layerMaxXMinYCorner)
        } else { self.layer.maskedCorners.remove(.layerMaxXMinYCorner)
        }}
        get{ return self.layer.maskedCorners.contains(.layerMaxXMinYCorner)}
    }
    
    @IBInspectable var roundBottomLeft: Bool {
        set{ if newValue { self.layer.maskedCorners.insert(.layerMinXMaxYCorner)
        } else { self.layer.maskedCorners.remove(.layerMinXMaxYCorner)
        }}
        get{ return self.layer.maskedCorners.contains(.layerMinXMaxYCorner)}
    }
    
    @IBInspectable var roundBottomRight: Bool {
        set{ if newValue { self.layer.maskedCorners.insert(.layerMaxXMaxYCorner)
        } else { self.layer.maskedCorners.remove(.layerMaxXMaxYCorner)
        }}
        get{ return self.layer.maskedCorners.contains(.layerMaxXMaxYCorner)}
    }

    @IBInspectable var borderWidth: CGFloat{
        set { layer.borderWidth = newValue }
        get { return layer.borderWidth }
    }

    @IBInspectable var borderColor: UIColor? {
        set { layer.borderColor = newValue?.cgColor }
        get { return UIColor(cgColor: layer.borderColor ?? UIColor.clear.cgColor) }
    }
    
    
    @IBInspectable var roundCorners: UIRectCorner {
        set{
        let maskPath = UIBezierPath(roundedRect: self.bounds,
                                    byRoundingCorners: newValue,
                                    cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let shape = CAShapeLayer.init()
        shape.path = maskPath.cgPath
        self.layer.mask = shape
        }
        get{.allCorners}
    }
    
    @discardableResult
    func addBorders(edges: UIRectEdge,
                    color: UIColor,
                    inset: CGFloat = 0.0,
                    thickness: CGFloat = 1.0) -> [UIView] {

        var borders = [UIView]()

        @discardableResult
        func addBorder(formats: String...) -> UIView {
            let border = UIView(frame: .zero)
            border.backgroundColor = color
            border.translatesAutoresizingMaskIntoConstraints = false
            addSubview(border)
            addConstraints(formats.flatMap {
                NSLayoutConstraint.constraints(withVisualFormat: $0,
                                               options: [],
                                               metrics: ["inset": inset, "thickness": thickness],
                                               views: ["border": border]) })
            borders.append(border)
            return border
        }


        if edges.contains(.top) || edges.contains(.all) {
            addBorder(formats: "V:|-0-[border(==thickness)]", "H:|-inset-[border]-inset-|")
        }

        if edges.contains(.bottom) || edges.contains(.all) {
            addBorder(formats: "V:[border(==thickness)]-0-|", "H:|-inset-[border]-inset-|")
        }

        if edges.contains(.left) || edges.contains(.all) {
            addBorder(formats: "V:|-inset-[border]-inset-|", "H:|-0-[border(==thickness)]")
        }

        if edges.contains(.right) || edges.contains(.all) {
            addBorder(formats: "V:|-inset-[border]-inset-|", "H:[border(==thickness)]-0-|")
        }

        return borders
    }
}
