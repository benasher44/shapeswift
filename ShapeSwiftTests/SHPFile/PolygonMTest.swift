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
    let polygon = SHPFilePolygonMRecord(
      box: box,
      parts: [0],
      points: points,
      mBounds: Coordinate2DBounds(min: 1.0, max: 2.0),
      measures: measures
    )
    testParsingRecord(polygon, range: 4..<(4 + 32 + 4 + 4 + 4 + (3 * 16) + 16 + (3 * 8)))
  }

  func testMultipleParts() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10), Coordinate2D(x: 15, y: 9), Coordinate2D(x: 5, y: -5)
    ]
    let measures = [1.0, 2.0, 1.0, 3.0]
    let polygon = SHPFilePolygonMRecord(
      box: box,
      parts: [0, 2],
      points: points,
      mBounds: Coordinate2DBounds(min: 1.0, max: 3.0),
      measures: measures
    )
    testParsingRecord(polygon, range: 4..<(4 + 32 + 4 + 4 + (2 * 4) + (4 * 16) + 16 + (4 * 8)))
  }

  func testNoMeasures() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10), Coordinate2D(x: 15, y: 9), Coordinate2D(x: 5, y: -5)
    ]
    let polygon = SHPFilePolygonMRecord(
      box: box,
      parts: [0, 2],
      points: points,
      mBounds: nil,
      measures: []
    )
    testParsingRecord(polygon, range: 4..<(4 + 32 + 4 + 4 + (2 * 4) + (4 * 16)))
  }

  func testNoMeasuresNoDataValues() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10), Coordinate2D(x: 15, y: 9), Coordinate2D(x: 5, y: -5)
    ]
    let expectedPolygon = SHPFilePolygonMRecord(
      box: box,
      parts: [0, 2],
      points: points,
      mBounds: nil,
      measures: []
    )
    let polygonData = SHPFilePolygonMRecord(
      box: box,
      parts: [0, 2],
      points: points,
      mBounds: Coordinate2DBounds(min: noDataValue, max: noDataValue),
      measures: [noDataValue, noDataValue, noDataValue, noDataValue]
    )
    testParsingRecord(expectedPolygon, range: 4..<(4 + 32 + 4 + 4 + (2 * 4) + (4 * 16) + 16 + (4 * 8)), dataRecord: polygonData)
  }
}
