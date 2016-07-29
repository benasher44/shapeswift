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
      box: box,
      points: points,
      zBounds: Coordinate2DBounds(min: 0.0, max: 10.0),
      zValues: zValues,
      mBounds: Coordinate2DBounds(min: 1.0, max: 2.0),
      measures: measures
    )
    testParsingRecord(multipointZ, range: 4..<(40 + 2 * 8 + 2 * 8 + 16 + 2 * 8 + 16 + 2 * 8))
  }

  func testDecodingWithNoMeasures() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10)
    ]
    let zValues: [Double] = [0.0, 10.0]
    let multipointZ = SHPFileMultiPointZRecord(
      box: box,
      points: points,
      zBounds: Coordinate2DBounds(min: 0.0, max: 10.0),
      zValues: zValues,
      mBounds: nil,
      measures: []
    )
    testParsingRecord(multipointZ, range: 4..<(40 + 2 * 8 + 16 + 2 * 8))
  }
}
