//
//  ByteEncodableTest.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 5/7/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import XCTest
@testable import ShapeSwift

class ByteEncodableTest: XCTestCase {
  func testByteEncodableDouble() {
    let value: Double = 32.0
    let data = NSData(
      byteEncodableArray: [
        LittleEndian<Double>(value: value)
        // other data here also, e.g. LittleEndian<BoundingBoxXY>(...)
      ]
    )
    let parsedValue = Double(littleEndianData: data, start: 0)
    XCTAssertEqual(value, parsedValue)
  }
}
