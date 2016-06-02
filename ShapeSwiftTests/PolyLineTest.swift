//
//  PolyLineTest.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 6/2/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import XCTest
@testable import ShapeSwift

class PolyLineTest: XCTestCase {
  func testDecodingPolyLine() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10)
    ]
    let polyline = ShapeFilePolyLineRecord(
      box: box,
      points: points,
      parts: [0]
    )
    testParsingRecord(polyline, range: 4..<76)
  }

  func testMultipleParts() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10), Coordinate2D(x: 15, y: 9), Coordinate2D(x: 5, y: -5)
    ]
    let polyline = ShapeFilePolyLineRecord(
      box: box,
      points: points,
      parts: [0, 2]
    )
    testParsingRecord(polyline, range: 4..<96)
  }
}
