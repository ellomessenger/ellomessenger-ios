//
//  CustomFont.swift
//  _idx_Display_05A6B1F6_ios_min11.0
//
//

import UIKit

public extension UIFont {
    
    enum FontStyle: String {
        case Italic
    }
    
   enum Custom {
        
        private static var weights: [UIFont.Weight: String] { [
            .ultraLight: "Ultralight", //100
            .thin: "Thin", //200
            .light: "Light", //300
            .regular: "Regular", //400
            .medium: "Medium", //500
            .semibold: "Semibold", //600
            .bold: "Bold", //700
            .heavy: "Heavy", //800
            .black: "Black", //900
        ] }

        static private func getFont(name: String, ofSize: CGFloat, weight: UIFont.Weight) -> UIFont {
            if let font = UIFont(name: name, size: ofSize) {
                return font
            } else {
                print("Can't get font \(name) with weight \(weight)")
                return UIFont.systemFont(ofSize: ofSize, weight: weight)
            }
        }
       
       static private func getItalicFont(name: String, ofSize: CGFloat) -> UIFont {
           if let font = UIFont(name: name, size: ofSize) {
               return font
           } else {
               print("Can't get Italic font \(name)")
               return UIFont.italicSystemFont(ofSize: ofSize)
           }
       }
       
        // MARK: SF Pro Text

        public static func sfProText(ofSize: CGFloat, weight: UIFont.Weight) -> UIFont {
            let weightStr = weights[weight] ?? ""
            return getFont(name: "SFProText-\(weightStr)", ofSize: ofSize, weight: weight)
        }
        
        public static func sfProRounded(ofSize: CGFloat, weight: UIFont.Weight) -> UIFont {
            let weightStr = weights[weight] ?? ""
            return getFont(name: "SFProRounded-\(weightStr)", ofSize: ofSize, weight: weight)
        }
        
        public static func sfProDisplay(ofSize: CGFloat, weight: UIFont.Weight) -> UIFont {
            let weightStr = weights[weight] ?? ""
            return getFont(name: "SFProDisplay-\(weightStr)", ofSize: ofSize, weight: weight)
        }
       
       public static func AremacFS(ofSize: CGFloat, weight: UIFont.Weight) -> UIFont {
           let weightStr = weights[weight] ?? ""
           return getFont(name: "AremacFS-\(weightStr)", ofSize: ofSize, weight: weight)
       }
       
       public static func sfProDisplayItalic(weight: UIFont.Weight, fontStyle: FontStyle, ofSize: CGFloat) -> UIFont {
           let weightStr = (weights[weight] ?? "") + fontStyle.rawValue
           return getItalicFont(name: "SFProDisplay-\(weightStr)", ofSize: ofSize)
       }

    }
}
