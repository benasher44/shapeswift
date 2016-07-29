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
    let polylineM = ShapeFilePolyLineMRecord(box: box,
                                             parts: [0],
                                             points: points,
                                             mBounds: Coordinate2DBounds(min: 1.0, max: 2.0),
                                             measures: [1.0, 2.0])
    testParsingRecord(polylineM, range: 4..<112)
  }

  func testDecodingNoMeasure() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10)
    ]
    let polylineM = ShapeFilePolyLineMRecord(box: box,
                                             parts: [0],
                                             points: points,
                                             mBounds: nil,
                                             measures: [])
    testParsingRecord(polylineM, range: 4..<80)
  }

  func testMultipleParts() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10), Coordinate2D(x: 15, y: 9), Coordinate2D(x: 5, y: -5)
    ]
    let polylineM = ShapeFilePolyLineMRecord(box: box,
                                             parts: [0, 2],
                                             points: points,
                                             mBounds: Coordinate2DBounds(min: 1.0, max: 2.0),
                                             measures: [1.0, 2.0, 3.0, 4.0])
    testParsingRecord(polylineM, range: 4..<148)
  }

}
