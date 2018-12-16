//
//  Parser.swift
//  SwiftDemangler
//
//  Created by Kazuya Ueoka on 2018/12/16.
//

import Foundation

public class Parser: RawRepresentable {
    public typealias RawValue = String
    
    public static let prefix: String = "$S"
    public static let suffix: String = "F"
    
    public let rawValue: String
    var buffer: String = ""
    required public init(rawValue mangled: String) {
        self.rawValue = mangled
    }
    
    public func parse() -> String {
        buffer = rawValue
        
        // remove: $S
        buffer = removePrefix(of: buffer, and: type(of: self).prefix)
        
        let moduleName = parseModule()
        let declName = parseDecl()
        let labels = parseLabels()
        let returnType = parseReturnType()
        let argumentTypes = parseArgumentTypes()
        
        // remote: F
        buffer = removeSuffix(of: buffer, and: type(of: self).suffix)
        
        return combintComponents(module: moduleName, decl: declName, labels: labels, arguments: argumentTypes, returnType: returnType)
    }
    
    /// valueから先頭のprefixを削除して返す
    ///
    /// - Parameters:
    ///   - value: 検索する文字列
    ///   - prefix: 削除する先頭の文字列
    /// - Returns: 削除済みの文字列が返る、prefixが無ければそのまま返る
    public func removePrefix(of value: String, and prefix: String) -> String {
        guard value.hasPrefix(prefix) else { return value }
        var result = value
        let length = prefix.count
        result.removeSubrange(result.startIndex..<result.index(result.startIndex, offsetBy: length))
        return result
    }
    
    /// valueから末尾のsuffixを削除して返す
    ///
    /// - Parameters:
    ///   - value: 検索する文字列
    ///   - suffix: 削除する末尾の文字列
    /// - Returns: 削除済みの文字列が返る、suffixが無ければそのまま返る
    public func removeSuffix(of value: String, and suffix: String) -> String {
        guard value.hasSuffix(suffix) else { return value }
        var result = value
        let length = suffix.count
        let start = result.index(result.endIndex, offsetBy: -length)
        result.removeSubrange(start..<result.endIndex)
        return result
    }
    
    /// {digit}{componentName} を探して見つかった部分を返す
    ///
    /// - Parameter value: 検索する文字列
    /// - Returns: 見つかった {digit}{componentName} を返す、無ければvalueをそのまま返す
    public func findComponent(from value: String) -> String {
        let length = findFirstDigits(from: value)
        guard 0 < length else { return value }
        let digits = String(length)
        
        let start = value.startIndex
        let end = value.index(start, offsetBy: length + digits.count)
        return String(value[start..<end])
    }
    
    /// 最初の数値の塊を探す
    ///
    /// - Parameter value: 検索する文字列
    /// - Returns: 見つけた数値、無ければ0が返る
    public func findFirstDigits(from value: String) -> Int {
        let digits = "0123456789"
        var isFindChar: Bool = false
        var firstDigits: String = ""
        for i in 0..<value.count {
            let start = value.index(value.startIndex, offsetBy: i)
            let end = value.index(value.startIndex, offsetBy: i + 1)
            let char = value[start..<end]
            if digits.contains(char) {
                defer { isFindChar = true }
                firstDigits += char
            } else if isFindChar {
                break
            }
        }
        
        guard !firstDigits.isEmpty else { return 0 }
        return Int(firstDigits)!
    }
    
    /// {digits}{componentName} の {componentName}の部分を返す
    ///
    /// - Parameter value: 検索する文字列
    /// - Returns: {componentName}を返す、無ければvalueをそのまま返す
    public func parseComponent(from value: String) -> String {
        let length = findFirstDigits(from: value)
        guard 0 < length else { return value }
        let digits = String(length)
        
        let start = value.index(value.startIndex, offsetBy: digits.count)
        let end = value.index(start, offsetBy: length)
        return String(value[start..<end])
    }
    
    /// 型情報の文字列を返す
    ///
    /// - Parameter value: 検索する文字列
    /// - Returns: 見つかった型情報、無ければnilを返す
    public func findSignature(from value: String) -> String? {
        guard 2 <= value.count else { return nil }
        guard value.hasPrefix("S") else { return nil }
        return String(value[value.startIndex..<value.index(value.startIndex, offsetBy: 2)])
    }
    
    /// Swiftで定義されている型に変換する
    ///
    /// - Parameter value: 検索する文字列
    /// - Returns: 変換済みの型を返す、変換出来なければnilを返す
    public func parseKnownType(from value: String) -> KnownType? {
        guard let signature = findSignature(from: value) else { return nil }
        let type = String(signature[signature.index(signature.startIndex, offsetBy: 1)..<signature.endIndex])
        switch type {
        case "S":
            return .string
        case "b":
            return .bool
        case "i":
            return .int
        case "f":
            return .float
        default:
            return nil
        }
    }
    
    /// 最終的に文字列にして返す
    ///
    /// - Parameters:
    ///   - module: module
    ///   - decl: decl-name
    ///   - labels: label-list
    ///   - arguments: [KnownType]
    ///   - returnType: KnownType?
    /// - Returns: 渡された引数を結合して文字列にして返す
    public func combintComponents(module: String, decl: String, labels: [String], arguments: [KnownType], returnType: KnownType?) -> String {
        var result = String(format: "%@.%@", module, decl)
        
        let labelStrings = zip(labels, arguments).map { (item) -> String in
            return String(format: "%@: %@", item.0, item.1.toString)
        }
        
        if 0 < labelStrings.count {
            result += "(\(labelStrings.joined(separator: ", ")))"
        }
        
        if let returnType = returnType {
            result += " -> \(returnType.toString)"
        }
        
        return result
    }
    
    /// モジュール名をパースして返す、バッファーを更新する
    ///
    /// - Returns: String
    public func parseModule() -> String {
        let module = findComponent(from: buffer)
        let moduleName = parseComponent(from: module)
        buffer = removePrefix(of: buffer, and: module)
        return moduleName
    }
    /// declをパースして返す、バッファーを更新する
    ///
    /// - Returns: String
    public func parseDecl() -> String {
        let decl = findComponent(from: buffer)
        let declName = parseComponent(from: decl)
        buffer = removePrefix(of: buffer, and: decl)
        return declName
    }
    
    /// label-listをパースして返す、バッファーを更新する
    ///
    /// - Returns: [String]
    public func parseLabels() -> [String] {
        var labels: [String] = []
        while 0 < findFirstDigits(from: buffer) {
            let label = findComponent(from: buffer)
            let labelName = parseComponent(from: buffer)
            buffer = removePrefix(of: buffer, and: label)
            labels.append(labelName)
        }
        return labels
    }
    
    /// 返り値をパースして返す、バッファーを更新する
    ///
    /// - Returns: KnownType?
    public func parseReturnType() -> KnownType? {
        let returnTypeString: String? = findSignature(from: buffer)
        let returnType: KnownType?
        if let returnTypeString = returnTypeString {
            buffer = removePrefix(of: buffer, and: returnTypeString)
            returnType = parseKnownType(from: returnTypeString)
        } else {
            returnType = nil
        }
        return returnType
    }
    
    /// 引数の一覧をパースして返す、バッファーを更新する
    ///
    /// - Returns: [KnownType]
    public func parseArgumentTypes() -> [KnownType] {
        var argumentTypes: [KnownType] = []
        while 1 < buffer.count {
            if let signature = findSignature(from: buffer), let knownType = parseKnownType(from: signature) {
                argumentTypes.append(knownType)
                buffer = removePrefix(of: buffer, and: signature)
            } else if 0 < buffer.count {
                let firstChar = String(buffer[buffer.startIndex..<buffer.index(buffer.startIndex, offsetBy: 1)])
                if firstChar == "_" {
                    buffer = removePrefix(of: buffer, and: "_")
                } else if firstChar == "t" {
                    buffer = removePrefix(of: buffer, and: "t")
                } else {
                    break
                }
            } else {
                break
            }
        }
        return argumentTypes
    }
}
