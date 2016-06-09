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
  func testDecodingMultipointM() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10)
    ]
    let measures: [Double] = [1.0, 2.0]
    let multipointM = ShapeFileMultiPointMRecord(box: box, points: points, mBounds: Coordinate2DBounds(min: 1.0, max: 2.0), measures: measures)
    testParsingRecord(multipointM, range: 4..<(40 + 2 * 8 + 16 + 2 * 8))
  }

  func testDecodingWithNoMeasures() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10)
    ]

    let multipointM = ShapeFileMultiPointMRecord(box: box, points: points, mBounds: nil, measures: [])
    testParsingRecord(multipointM, range: 4..<(40 + 2 * 8))
  }
}
