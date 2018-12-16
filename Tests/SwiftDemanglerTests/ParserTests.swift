//
//  ParserTests.swift
//  SwiftDemangler
//
//  Created by Kazuya Ueoka on 2018/12/16.
//

import Foundation
import XCTest
@testable import SwiftDemangler

final class ParserTests: XCTestCase {
    
    func testRemovePrefixTest() {
        let parser = Parser(rawValue: "$S13ExampleNumber6isEven6numberSbSi_tF")
        XCTAssertEqual(parser.removePrefix(of: parser.rawValue, and: "$S"), "13ExampleNumber6isEven6numberSbSi_tF")
    }
    
    func testRemoveSuffixTest() {
        let parser = Parser(rawValue: "$S13ExampleNumber6isEven6numberSbSi_tF")
        XCTAssertEqual(parser.removeSuffix(of: parser.rawValue, and: "F"), "$S13ExampleNumber6isEven6numberSbSi_t")
    }
    
    func testFindFirstDigits() {
        let parser = Parser(rawValue: "")
        XCTAssertEqual(parser.findFirstDigits(from: "$S13ExampleNumber"), 13)
        XCTAssertEqual(parser.findFirstDigits(from: "6isEven6"), 6)
        XCTAssertEqual(parser.findFirstDigits(from: "isEven6number"), 6)
    }
    
    func testFindComponent() {
        let parser = Parser(rawValue: "")
        XCTAssertEqual(parser.findComponent(from: "13ExampleNumber"), "13ExampleNumber")
        XCTAssertEqual(parser.findComponent(from: "6isEven"), "6isEven")
        XCTAssertEqual(parser.findComponent(from: "6number"), "6number")
    }
    
    func testParseComponent() {
        let parser = Parser(rawValue: "")
        XCTAssertEqual(parser.parseComponent(from: "13ExampleNumber"), "ExampleNumber")
        XCTAssertEqual(parser.parseComponent(from: "6isEven"), "isEven")
        XCTAssertEqual(parser.parseComponent(from: "6number"), "number")
    }
    
    func testParseSignature() {
        let parser = Parser(rawValue: "")
        
        XCTAssertNil(parser.findSignature(from: "hoge"))
        XCTAssertEqual(parser.findSignature(from: "Si"), "Si")
        XCTAssertEqual(parser.findSignature(from: "SS"), "SS")
        XCTAssertEqual(parser.findSignature(from: "Sb"), "Sb")
        XCTAssertEqual(parser.findSignature(from: "Sf"), "Sf")
    }
    
    static var allTests = [
        ("testRemovePrefixTest", testRemovePrefixTest),
    ]
}
