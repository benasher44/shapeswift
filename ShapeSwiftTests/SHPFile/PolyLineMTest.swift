//
//  PolyLineMTest.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 6/9/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import XCTest
@testable import ShapeSwift

class PolyLineMTest: XCTestCase {
  func testDecoding() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10)
    ]
    let polylineM = SHPFilePolyLineMRecord(recordNumber: 0,
                                           box: box,
                                           parts: [0],
                                           points: points,
                                           mBounds: Coordinate2DBounds(min: 1.0, max: 2.0),
                                           measures: [1.0, 2.0])
    testParsingRecord(polylineM, range: 4..<(4 + 32 + 4 + 4 + 4 + (2 * 16) + 16 + (2 * 8)))
  }

  func testDecodingNoMeasures() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10)
    ]
    let polylineM = SHPFilePolyLineMRecord(recordNumber: 0,
                                           box: box,
                                           parts: [0],
                                           points: points,
                                           mBounds: nil,
                                           measures: [])
    testParsingRecord(polylineM, range: 4..<(4 + 32 + 4 + 4 + 4 + (2 * 16)))
  }

  func testDecodingNoMeasuresNoDataValues() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10)
    ]
    let expectedPolylineM = SHPFilePolyLineMRecord(recordNumber: 0,
                                                   box: box,
                                                   parts: [0],
                                                   points: points,
                                                   mBounds: nil,
                                                   measures: [])
    let polylineMData = SHPFilePolyLineMRecord(recordNumber: 0,
                                               box: box,
                                               parts: [0],
                                               points: points,
                                               mBounds: Coordinate2DBounds(min: noDataValue, max: noDataValue),
                                               measures: [noDataValue, noDataValue])
    testParsingRecord(expectedPolylineM, range: 4..<(4 + 32 + 4 + 4 + 4 + (2 * 16) + 16 + (2 * 8)), dataRecord: polylineMData)
  }

  func testMultipleParts() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10), Coordinate2D(x: 15, y: 9), Coordinate2D(x: 5, y: -5)
    ]
    let polylineM = SHPFilePolyLineMRecord(recordNumber: 0,
                                           box: box,
                                           parts: [0, 2],
                                           points: points,
                                           mBounds: Coordinate2DBounds(min: 1.0, max: 2.0),
                                           measures: [1.0, 2.0, 3.0, 4.0])
    testParsingRecord(polylineM, range: 4..<(4 + 32 + 4 + 4 + (4 * 2) + (4 * 16) + 16 + (4 * 8)))
  }
}

extension SHPFilePolyLineMRecord: ByteEncodable {
  func encode() -> [Byte] {
    var byteEncodables: [[ByteEncodable]] = [
      [
        LittleEndianEncoded<ShapeType>(value: .polyLineM),
        box,
        LittleEndianEncoded<Int32>(value: Int32(parts.count)),
        LittleEndianEncoded<Int32>(value: Int32(points.count))
      ],
      parts.map({LittleEndianEncoded<Int32>(value: Int32($0))}),
      points.map({$0 as ByteEncodable})
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
