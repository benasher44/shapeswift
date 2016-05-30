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
    let data = NSData(
      byteEncodableArray: [
        LittleEndianEncoded<Double>(value: value),
        BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
      ]
    )
    let parsedValue = Double(littleEndianData: data, start: 0)
    XCTAssertEqual(value, parsedValue)
  }

  func testEncodingMultipoint() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10)
    ]
    let multipoint = ShapeFileMultiPointRecord(box: box, points: points)

    let data = NSData(byteEncodableArray: [multipoint])
    let parsedMultipoint = try! ShapeFileMultiPointRecord(data: data, range: 4..<68) // todo(noah): should not be using 4 here
    XCTAssertEqual(parsedMultipoint, multipoint)
  }
}
