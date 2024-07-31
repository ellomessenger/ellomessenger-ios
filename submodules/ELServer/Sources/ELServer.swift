//
//  ServerType.swift
//  ELServer
//
//

import Foundation

public enum ServerType: String {
    case qa = "qa_server.example.com"
    case stage = "stage_server.example.com"
    case prod = "prod_server.example.com"
    
    public static var currentServerType: ServerType {
        .prod
    }
}
