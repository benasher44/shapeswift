//
//  MultiPointTest.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 6/2/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import XCTest
@testable import ShapeSwift

class MultiPointTest: XCTestCase {
  func testEncodingMultipoint() {
    let box = BoundingBoxXY(x: Coordinate2DBounds(min: 0, max: 10), y: Coordinate2DBounds(min: 0, max: 10))
    let points = [
      Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 10)
    ]
    let multipoint = ShapeFileMultiPointRecord(box: box, points: points)

    let data = NSData(byteEncodableArray: [multipoint])
    let parsedMultipoint = try! ShapeFileMultiPointRecord(data: data, range: 4..<68)
    XCTAssertEqual(parsedMultipoint, multipoint)
  }
}
