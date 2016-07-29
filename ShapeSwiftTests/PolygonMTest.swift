//
//  PolygonMTest.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 6/9/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import XCTest
@testable import ShapeSwift

class PolygonMTest: XCTestCase {
  func testDecoding() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10), Coordinate2D(x: 5, y: 5)
    ]
    let measures = [1.0, 2.0, 1.0]
    let polygon = ShapeFilePolygonMRecord(
      box: box,
      parts: [0],
      points: points,
      mBounds: Coordinate2DBounds(min: 1.0, max: 2.0),
      measures: measures
    )
    testParsingRecord(polygon, range: 4..<(116))
  }

  func testMultipleParts() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10), Coordinate2D(x: 15, y: 9), Coordinate2D(x: 5, y: -5)
    ]
    let measures = [1.0, 2.0, 1.0, 3.0]
    let polygon = ShapeFilePolygonMRecord(
      box: box,
      parts: [0, 2],
      points: points,
      mBounds: Coordinate2DBounds(min: 1.0, max: 3.0),
      measures: measures
    )
    testParsingRecord(polygon, range: 4..<(44 + 4 * 2 + 16 * 4 + 16 + 8 * 2))
  }

  func testNoMeasures() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10), Coordinate2D(x: 15, y: 9), Coordinate2D(x: 5, y: -5)
    ]
    let polygon = ShapeFilePolygonMRecord(
      box: box,
      parts: [0, 2],
      points: points,
      mBounds: nil,
      measures: []
    )
    testParsingRecord(polygon, range: 4..<(44 + 4 * 2))
  }
}
