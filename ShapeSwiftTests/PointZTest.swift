//
//  PointZTest.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 6/9/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import XCTest
@testable import ShapeSwift

class PointZTest: XCTestCase {
  func testDecoding() {
    let pointZ = SHPFilePointZRecord(x: 1.0, y: 1.0, z: 3.0, m: 4.0)
    testParsingRecord(pointZ, range: 4..<(8 * 4))
  }

  func testDecodingWithoutM() {
    let pointZ = SHPFilePointZRecord(x: 1.0, y: 1.0, z: 3.0, m: nil)
    testParsingRecord(pointZ, range: 4..<(8 * 4))
  }
}
