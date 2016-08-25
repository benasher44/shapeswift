//
//  PointMTest.swift
//  ShapeSwift
//
//  Created by Ben Asher on 8/25/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import XCTest
@testable import ShapeSwift

class PointMTest: XCTestCase {
  func testDecoding() {
    let pointZ = SHPFilePointMRecord(recordNumber: 0, x: 1.0, y: 1.0, m: 4.0)
    testParsingRecord(pointZ, range: 4..<4 + (8 * 3))
  }

  func testDecodingWithoutM() {
    let pointZ = SHPFilePointMRecord(recordNumber: 0, x: 1.0, y: 1.0, m: nil)
    testParsingRecord(pointZ, range: 4..<4 + (8 * 2))
  }

  func testDecodingWithMNoDataValues() {
    let pointZData = SHPFilePointMRecord(recordNumber: 0, x: 1.0, y: 1.0, m: noDataValue)
    let expectedPointZ = SHPFilePointMRecord(recordNumber: 0, x: 1.0, y: 1.0, m: nil)
    testParsingRecord(expectedPointZ, range: 4..<4 + (8 * 2), dataRecord: pointZData)
  }
}

extension SHPFilePointMRecord: ByteEncodable {
  func encode() -> [Byte] {
    var byteEncodables: [ByteEncodable] = [
      LittleEndianEncoded<ShapeType>(value: .pointM),
      LittleEndianEncoded<Double>(value: x),
      LittleEndianEncoded<Double>(value: y),
      ]
    if let m = m {
      byteEncodables.append(LittleEndianEncoded<Double>(value: m))
    }
    return makeByteArray(from: byteEncodables)
  }
}

