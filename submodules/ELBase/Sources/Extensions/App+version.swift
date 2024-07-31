//
//  App+version.swift
//  _idx_ELWelcomeUI_DF76EB68_ios_min11.0
//

import Foundation

public enum App {
    
    public static var description: String {
        let infoDictionary = Bundle.main.infoDictionary!
        let bundleName = infoDictionary["CFBundleName"] ?? ""
        let version = infoDictionary["CFBundleShortVersionString"] ?? ""
        let build = infoDictionary["CFBundleVersion"] ?? ""
        
        return "\(bundleName) v\(version) (\(build))"
    }
    
    
    public static var version: String {
        let infoDictionary = Bundle.main.infoDictionary!
        let version = infoDictionary["CFBundleShortVersionString"] ?? ""
        
        return "\(version)"
    }
    
    public static var build: String {
        let infoDictionary = Bundle.main.infoDictionary!
        let build = infoDictionary["CFBundleVersion"] ?? ""
        
        return "\(build)"
    }
    
}
