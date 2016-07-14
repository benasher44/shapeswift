//
//  ByteEncodableTest.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 5/7/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import XCTest
@testable import ShapeSwift
import proj4

class ByteEncodableTest: XCTestCase {
  func testByteEncodableDouble() {
    let value: Double = 32.0
    let data = Data(
      byteEncodableArray: [
        LittleEndianEncoded<Double>(value: value),
        BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
      ]
    )
    let parsedValue = Double(littleEndianData: data, start: 0)
    XCTAssertEqual(value, parsedValue)
  }
}
