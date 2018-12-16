import Foundation

public func demangle(name: String) -> String {
    return Parser(rawValue: name).parse()
}

