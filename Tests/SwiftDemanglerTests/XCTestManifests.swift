import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SwiftDemanglerTests.allTests),
        testCase(ParserTests.allTests)
    ]
}
#endif
