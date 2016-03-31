//
//  ShapeSwiftTests.swift
//  ShapeSwiftTests
//
//  Created by Benjamin Asher on 3/30/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import XCTest
@testable import ShapeSwift

class ShapeSwiftTests: XCTestCase {
    func testParser() {
      let url = NSBundle(forClass: self.dynamicType).URLForResource("sfsweeproutes", withExtension: "shp")!
      try! parseFromURL(url)
    }
}
