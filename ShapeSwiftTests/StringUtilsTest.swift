//
//  StringUtilsTest.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 11/17/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import XCTest
@testable import ShapeSwift

class StringUtilsTest: XCTestCase {
  func testNullStripped() {
    XCTAssertEqual("some name", "some name\0\0".nullStripped())
    XCTAssertEqual("some name", "some name\0\0some other name".nullStripped())
    XCTAssertEqual("", "\0".nullStripped())
  }
}
