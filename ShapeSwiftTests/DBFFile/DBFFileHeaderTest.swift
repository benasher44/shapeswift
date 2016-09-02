//
//  DBFFileHeaderTest.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 8/25/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import XCTest
@testable import ShapeSwift

class DBFFileHeaderTest: XCTestCase {
  func testParser() {
    let url = Bundle(for: type(of: self)).url(forResource: "sfsweeproutes", withExtension: "dbf")!
    let data = try! Data(contentsOf: url, options: .mappedIfSafe)
    let header = try? DBFFileHeader(data: data, start: 0)
    XCTAssertNotNil(header)
  }
}
