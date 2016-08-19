//
//  PolyLineTest.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 6/2/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import XCTest
@testable import ShapeSwift

class PolyLineTest: XCTestCase {
  func testDecoding() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10)
    ]
    let polyline = SHPFilePolyLineRecord(
      recordNumber: 0,
      box: box,
      parts: [0],
      points: points
    )
    testParsingRecord(polyline, range: 4..<(4 + 32 + 4 + 4 + 4 + (2 * 16)))
  }

  func testMultipleParts() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10), Coordinate2D(x: 15, y: 9), Coordinate2D(x: 5, y: -5)
    ]
    let polyline = SHPFilePolyLineRecord(
      recordNumber: 0,
      box: box,
      parts: [0, 2],
      points: points
    )
    testParsingRecord(polyline, range: 4..<(4 + 32 + 4 + 4 + (4 * 2) + (4 * 16)))
  }
}

extension SHPFilePolyLineRecord: ByteEncodable {
  func encode() -> [Byte] {
    let byteEncodables = [[
      LittleEndianEncoded<ShapeType>(value: .polyLine),
      box,
      LittleEndianEncoded<Int32>(value: Int32(parts.count)),
      LittleEndianEncoded<Int32>(value: Int32(points.count))
      ], parts.map({ LittleEndianEncoded<Int32>(value: Int32($0)) as ByteEncodable }), points.map({$0 as ByteEncodable})]
    return makeByteArray(from: byteEncodables.joined())
  }
}
