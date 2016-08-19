//
//  MultiPatchTest.swift
//  ShapeSwift
//
//  Created by Ben Asher on 6/16/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import XCTest
@testable import ShapeSwift

class MultiPatchTest: XCTestCase {
  func testDecoding() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0),
      Coordinate2D(x: 0, y: 10),
      Coordinate2D(x: 10, y: 10),
    ]
    let measures: [Double] = [1.0, 2.0, 3.0]
    let zValues: [Double] = [4.0, 5.0, 6.0]
    let multipatch = SHPFileMultiPatchRecord(
      recordNumber: 0,
      box: box,
      parts: [0],
      partTypes: [.triangleStrip],
      points: points,
      zBounds: Coordinate2DBounds(min: 0.0, max: 10.0),
      zValues: zValues,
      mBounds: Coordinate2DBounds(min: 1.0, max: 2.0),
      measures: measures
    )
    testParsingRecord(multipatch, range: 4..<(4 + 32 + 4 + 4 + 4 + 4 + (3 * 16) + 16 + (3 * 8) + 16 + (3 * 8)))
  }

  func testDecodingWithNoMeasures() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0),
      Coordinate2D(x: 0, y: 10),
      Coordinate2D(x: 10, y: 10),
      ]
    let zValues: [Double] = [4.0, 5.0, 6.0]
    let multipatch = SHPFileMultiPatchRecord(
      recordNumber: 0,
      box: box,
      parts: [0],
      partTypes: [.triangleStrip],
      points: points,
      zBounds: Coordinate2DBounds(min: 0.0, max: 10.0),
      zValues: zValues,
      mBounds: nil,
      measures: []
    )
    testParsingRecord(multipatch, range: 4..<(4 + 32 + 4 + 4 + 4 + 4 + (3 * 16) + 16 + (3 * 8)))
  }

  func testDecodingWithNoMeasuresNoDataValues() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0),
      Coordinate2D(x: 0, y: 10),
      Coordinate2D(x: 10, y: 10),
      ]
    let zValues: [Double] = [4.0, 5.0, 6.0]
    let expectedMultipatch = SHPFileMultiPatchRecord(
      recordNumber: 0,
      box: box,
      parts: [0],
      partTypes: [.triangleStrip],
      points: points,
      zBounds: Coordinate2DBounds(min: 0.0, max: 10.0),
      zValues: zValues,
      mBounds: nil,
      measures: []
    )
    let multipatchData = SHPFileMultiPatchRecord(
      recordNumber: 0,
      box: box,
      parts: [0],
      partTypes: [.triangleStrip],
      points: points,
      zBounds: Coordinate2DBounds(min: 0.0, max: 10.0),
      zValues: zValues,
      mBounds: Coordinate2DBounds(min: noDataValue, max: noDataValue),
      measures: [noDataValue, noDataValue, noDataValue]
    )
    testParsingRecord(expectedMultipatch, range: 4..<(4 + 32 + 4 + 4 + 4 + 4 + (3 * 16) + 16 + (3 * 8) + 16 + (3 * 8)), dataRecord: multipatchData)
  }
}

extension SHPFileMultiPatchRecord: ByteEncodable {
  func encode() -> [Byte] {
    var byteEncodables: [[ByteEncodable]] = [
      [
        LittleEndianEncoded<ShapeType>(value: .polyLineM),
        box,
        LittleEndianEncoded<Int32>(value: Int32(parts.count)),
        LittleEndianEncoded<Int32>(value: Int32(points.count))
      ],
      parts.map({LittleEndianEncoded<Int32>(value: Int32($0))}),
      partTypes.map(LittleEndianEncoded<MultiPatchPartType>.init),
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
