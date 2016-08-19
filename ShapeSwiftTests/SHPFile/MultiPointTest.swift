//
//  MultiPointTest.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 6/2/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import XCTest
@testable import ShapeSwift

class MultiPointTest: XCTestCase {
  func testDecoding() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10)
    ]
    let multipoint = SHPFileMultiPointRecord(recordNumber: 0, box: box, points: points)
    testParsingRecord(multipoint, range: 4..<4 + 32 + 4 + (2 * 16))
  }
}

extension SHPFileMultiPointRecord: ByteEncodable {
  func encode() -> [Byte] {
    let byteEncodables: [[ByteEncodable]] = [[
      LittleEndianEncoded<ShapeType>(value: .multiPoint),
      box,
      LittleEndianEncoded<Int32>(value: Int32(points.count)),
      ], points.map({$0 as ByteEncodable})]
    return makeByteArray(from: byteEncodables.joined())
  }
}
