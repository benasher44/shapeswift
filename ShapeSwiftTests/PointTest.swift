//
//  PointTest.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 6/2/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import Foundation
@testable import ShapeSwift
import XCTest

class PointTest: XCTestCase {

  func testDecodingPoint() {
    let point = ShapeFilePointRecord(point: Coordinate2D(x: 10.0, y: 10.0))
    let data = NSData(byteEncodableArray: [point])
    let parsedPoint = try! ShapeFilePointRecord(data: data, range: 4..<16)
    XCTAssertEqual(point, parsedPoint)
  }
}