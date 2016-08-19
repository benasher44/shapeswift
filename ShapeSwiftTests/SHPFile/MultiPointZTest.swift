//
//  MultiPointZTest.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 6/16/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import XCTest
@testable import ShapeSwift

class MultiPointZTest: XCTestCase {
  func testDecoding() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10)
    ]
    let measures: [Double] = [1.0, 2.0]
    let zValues: [Double] = [0.0, 10.0]
    let multipointZ = SHPFileMultiPointZRecord(
      recordNumber: 0,
      box: box,
      points: points,
      zBounds: Coordinate2DBounds(min: 0.0, max: 10.0),
      zValues: zValues,
      mBounds: Coordinate2DBounds(min: 1.0, max: 2.0),
      measures: measures
    )
    testParsingRecord(multipointZ, range: 4..<(4 + 32 + 4 + (2 * 16) + 16 + (2 * 8) + 16 + (2 * 8)))
  }

  func testDecodingWithNoMeasures() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10)
    ]
    let zValues: [Double] = [0.0, 10.0]
    let multipointZ = SHPFileMultiPointZRecord(
      recordNumber: 0,
      box: box,
      points: points,
      zBounds: Coordinate2DBounds(min: 0.0, max: 10.0),
      zValues: zValues,
      mBounds: nil,
      measures: []
    )
    testParsingRecord(multipointZ, range: 4..<(4 + 32 + 4 + (2 * 16) + 16 + (2 * 8)))
  }

  func testDecodingWithNoMeasuresNoDataValues() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10)
    ]
    let zValues: [Double] = [0.0, 10.0]
    let expectedMultipointZ = SHPFileMultiPointZRecord(
      recordNumber: 0,
      box: box,
      points: points,
      zBounds: Coordinate2DBounds(min: 0.0, max: 10.0),
      zValues: zValues,
      mBounds: nil,
      measures: []
    )
    let multipointZData = SHPFileMultiPointZRecord(
      recordNumber: 0,
      box: box,
      points: points,
      zBounds: Coordinate2DBounds(min: 0.0, max: 10.0),
      zValues: zValues,
      mBounds: Coordinate2DBounds(min: noDataValue, max: noDataValue),
      measures: [noDataValue, noDataValue]
    )

    testParsingRecord(expectedMultipointZ, range: 4..<(4 + 32 + 4 + (2 * 16) + 16 + (2 * 8) + 16 + (2 * 8)), dataRecord: multipointZData)
  }
}

extension SHPFileMultiPointZRecord: ByteEncodable {
  func encode() -> [Byte] {
    var byteEncodables = [
      [
        LittleEndianEncoded<ShapeType>(value: .multiPointZ),
        box,
        LittleEndianEncoded<Int32>(value: Int32(points.count))
      ],
      points.map({$0 as ByteEncodable}),
      [
        LittleEndianEncoded<Double>(value: zBounds.min),
        LittleEndianEncoded<Double>(value: zBounds.max),
        ],
      zValues.map({LittleEndianEncoded<Double>(value: $0) as ByteEncodable})
    ]

    if let mBounds = mBounds {
      byteEncodables.append([
        LittleEndianEncoded<Double>(value: mBounds.min),
        LittleEndianEncoded<Double>(value: mBounds.max),
        ])
      byteEncodables.append(
        measures.map({LittleEndianEncoded<Double>(value: $0) as ByteEncodable})
      )
    }

    return makeByteArray(from: byteEncodables.joined())
  }
}
