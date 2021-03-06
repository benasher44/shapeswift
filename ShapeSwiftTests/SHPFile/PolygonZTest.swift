//
//  PolygonZTest.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 7/14/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

@testable import ShapeSwift
import XCTest

class PolygonZTest: XCTestCase {
  func testDecoding() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10)
    ]
    let measures: [Double] = [1.0, 2.0]
    let zValues: [Double] = [0.0, 10.0]
    let polygonZ = SHPFilePolygonZRecord(
      recordNumber: 0,
      box: box,
      parts: [0],
      points: points,
      zBounds: Coordinate2DBounds(min: 0.0, max: 10.0),
      zValues: zValues,
      mBounds: Coordinate2DBounds(min: 1.0, max: 2.0),
      measures: measures
    )
    testParsingRecord(polygonZ, range: 4..<144)
  }

  func testDecodingWithNoMeasures() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10)
    ]
    let zValues: [Double] = [0.0, 10.0]
    let polygonZ = SHPFilePolygonZRecord(
      recordNumber: 0,
      box: box,
      parts: [0],
      points: points,
      zBounds: Coordinate2DBounds(min: 0.0, max: 10.0),
      zValues: zValues,
      mBounds: nil,
      measures: []
    )
    testParsingRecord(polygonZ, range: 4..<112)
  }

  func testDecodingWithNoMeasuresNoDataValues() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10)
    ]
    let zValues: [Double] = [0.0, 10.0]
    let expectedPolygonZ = SHPFilePolygonZRecord(
      recordNumber: 0,
      box: box,
      parts: [0],
      points: points,
      zBounds: Coordinate2DBounds(min: 0.0, max: 10.0),
      zValues: zValues,
      mBounds: nil,
      measures: []
    )

    let polygonZData = SHPFilePolygonZRecord(
      recordNumber: 0,
      box: box,
      parts: [0],
      points: points,
      zBounds: Coordinate2DBounds(min: 0.0, max: 10.0),
      zValues: zValues,
      mBounds: Coordinate2DBounds(min: noDataValue, max: noDataValue),
      measures: [noDataValue, noDataValue]
    )
    testParsingRecord(expectedPolygonZ, range: 4..<144, dataRecord: polygonZData)
  }
}

extension SHPFilePolygonZRecord: ByteEncodable {
  func encode() -> [Byte] {
    var byteEncodables: [[ByteEncodable]] = [
      [
        LittleEndianEncoded<ShapeType>(value: .polygonZ),
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
