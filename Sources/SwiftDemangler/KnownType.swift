//
//  KnownType.swift
//  SwiftDemangler
//
//  Created by Kazuya Ueoka on 2018/12/16.
//

import Foundation

public enum KnownType {
    case bool
    case int
    case string
    case float
    
    var toString: String {
        switch self {
        case .bool:
            return "Swift.Bool"
        case .int:
            return "Swift.Int"
        case .string:
            return "Swift.String"
        case .float:
            return "Swift.Float"
        }
    }
}
