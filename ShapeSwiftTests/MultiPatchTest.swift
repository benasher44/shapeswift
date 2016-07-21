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
    let multipatch = ShapeFileMultiPatchRecord(
      box: box,
      parts: [0],
      partTypes: [.triangleStrip],
      points: points,
      zBounds: Coordinate2DBounds(min: 0.0, max: 10.0),
      zValues: zValues,
      mBounds: Coordinate2DBounds(min: 1.0, max: 2.0),
      measures: measures
    )
    testParsingRecord(multipatch, range: 4..<(4 + 32 + 4 + 4 + 4 + 4 + (3 * 16) + 16 + (3 * 8) + 16 + (3 * 16)))
  }

  func testDecodingWithNoMeasures() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0),
      Coordinate2D(x: 0, y: 10),
      Coordinate2D(x: 10, y: 10),
      ]
    let zValues: [Double] = [4.0, 5.0, 6.0]
    let multipatch = ShapeFileMultiPatchRecord(
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
}
