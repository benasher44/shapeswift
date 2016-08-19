//
//  PolyLineZTest.swift
//  ShapeSwift
//
//  Created by Ben Asher on 6/16/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import XCTest
@testable import ShapeSwift

class PolyLineZTest: XCTestCase {
  func testDecoding() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10)
    ]
    let measures: [Double] = [1.0, 2.0]
    let zValues: [Double] = [0.0, 10.0]
    let polyLineZ = SHPFilePolyLineZRecord(
      recordNumber: 0,
      box: box,
      parts: [0],
      points: points,
      zBounds: Coordinate2DBounds(min: 0.0, max: 10.0),
      zValues: zValues,
      mBounds: Coordinate2DBounds(min: 1.0, max: 2.0),
      measures: measures
    )
    testParsingRecord(polyLineZ, range: 4..<144)
  }

  func testDecodingWithNoMeasures() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10)
    ]
    let zValues: [Double] = [0.0, 10.0]
    let polyLineZ = SHPFilePolyLineZRecord(
      recordNumber: 0,
      box: box,
      parts: [0],
      points: points,
      zBounds: Coordinate2DBounds(min: 0.0, max: 10.0),
      zValues: zValues,
      mBounds: nil,
      measures: []
    )
    testParsingRecord(polyLineZ, range: 4..<112)
  }

  func testDecodingWithNoMeasuresNoDataValues() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10)
    ]
    let zValues: [Double] = [0.0, 10.0]
    let expectedPolyLineZ = SHPFilePolyLineZRecord(
      recordNumber: 0,
      box: box,
      parts: [0],
      points: points,
      zBounds: Coordinate2DBounds(min: 0.0, max: 10.0),
      zValues: zValues,
      mBounds: nil,
      measures: []
    )
    let polyLineZData = SHPFilePolyLineZRecord(
      recordNumber: 0,
      box: box,
      parts: [0],
      points: points,
      zBounds: Coordinate2DBounds(min: 0.0, max: 10.0),
      zValues: zValues,
      mBounds: Coordinate2DBounds(min: noDataValue, max: noDataValue),
      measures: [noDataValue, noDataValue]
    )
    testParsingRecord(expectedPolyLineZ, range: 4..<144, dataRecord: polyLineZData)
  }
}

extension SHPFilePolyLineZRecord: ByteEncodable {
  func encode() -> [Byte] {
    var byteEncodables: [[ByteEncodable]] = [
      [
        // todo(noah): this should be polygonZ instead of polygonM, but let's write a test that catches it
        LittleEndianEncoded<ShapeType>(value: .polyLineM),
        box,
        LittleEndianEncoded<Int32>(value: Int32(parts.count)),
        LittleEndianEncoded<Int32>(value: Int32(points.count))
      ],
      parts.map({LittleEndianEncoded<Int32>(value: Int32($0))}),
      points.map({$0 as ByteEncodable}),
      [zBounds],
      zValues.map(LittleEndianEncoded<Double>.init),
      ]

    if let mBounds = mBounds {
      byteEncodables.append([mBounds])
      byteEncodables.append(
        measures.map({LittleEndianEncoded<Double>(value: $0) as ByteEncodable})
      )
    }

    return makeByteArray(from: byteEncodables.joined())
  }
}
