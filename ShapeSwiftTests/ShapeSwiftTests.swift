//
//  ShapeSwiftTests.swift
//  ShapeSwiftTests
//
//  Created by Benjamin Asher on 3/30/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import XCTest
@testable import ShapeSwift

struct SFSweepRoutesProjection: Projection {
  let projInitArgs = "+proj=lcc +lat_1=37.06666666666667 +lat_2=38.43333333333333 +lat_0=36.5 +lon_0=-120.5 +x_0=2000000 +y_0=500000.0000000001 +datum=NAD83 +units=us-ft +no_defs"
}

struct WGS84Projection: Projection {
  let projInitArgs = "+proj=latlong +ellps=WGS84"
}

class ShapeSwiftTests: XCTestCase {
  func testParser() {
    let url = Bundle(for: self.dynamicType).url(forResource: "sfsweeproutes", withExtension: "shp")!
    let parser = try! SHPFileParser<SHPFilePolyLineShape>(fileURL: url)
    var numRecords = 0
    let start = CACurrentMediaTime()
    while let parseResult = parser.next() {
      switch parseResult {
      case .nullShapeRecord(_):
        break
      case let .shapeRecord(record):
        let _ = record.makeShape()
      }
      numRecords += 1
    }
    print("parsed \(numRecords) records in \(CACurrentMediaTime() - start)s")
  }
}
