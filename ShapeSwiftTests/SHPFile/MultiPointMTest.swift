//
//  MultiPointMTest.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 6/9/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import XCTest
@testable import ShapeSwift

class MultiPointMTest: XCTestCase {
  func testDecoding() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10)
    ]
    let measures: [Double] = [1.0, 2.0]
    let multipointM = SHPFileMultiPointMRecord(recordNumber: 0,
                                               box: box,
                                               points: points,
                                               mBounds: Coordinate2DBounds(min: 1.0, max: 2.0),
                                               measures: measures)
    testParsingRecord(multipointM, range: 4..<(4 + 32 + 4 + (2 * 16) + (2 * 8) + (2 * 8)))
  }

  func testDecodingWithNoMeasures() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10)
    ]

    let multipointM = SHPFileMultiPointMRecord(recordNumber: 0, box: box, points: points, mBounds: nil, measures: [])
    testParsingRecord(multipointM, range: 4..<(4 + 32 + 4 + (2 * 16)))
  }

  func testDecodingWithNoMeasuresNoDataValues() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10)
    ]

    let expectedMultipointM = SHPFileMultiPointMRecord(recordNumber: 0,
                                                       box: box,
                                                       points: points,
                                                       mBounds: nil,
                                                       measures: [])
    let multipointMData = SHPFileMultiPointMRecord(recordNumber: 0,
                                                   box: box,
                                                   points: points,
                                                   mBounds: Coordinate2DBounds(min: noDataValue, max: noDataValue),
                                                   measures: [noDataValue, noDataValue])
    testParsingRecord(expectedMultipointM, range: 4..<(4 + 32 + 4 + (2 * 16) + 16 + (2 * 8)), dataRecord: multipointMData)
  }
}

extension SHPFileMultiPointMRecord: ByteEncodable {
  func encode() -> [Byte] {
    var byteEncodables = [[
      LittleEndianEncoded<ShapeType>(value: .multiPointM),
      box,
      LittleEndianEncoded<Int32>(value: Int32(points.count))
      ],
                          points.map({$0 as ByteEncodable})
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
