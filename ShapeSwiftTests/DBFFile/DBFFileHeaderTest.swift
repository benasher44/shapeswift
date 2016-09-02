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
    assertCanParse(filename: "sfsweeproutes")
  }

  func testCP1251() {
    assertCanParse(filename: "cp1251")
  }

  func testDBASE03() {
    assertCanParse(filename: "dbase_03")
  }

  func testDBASE30() {
    assertCanParse(filename: "dbase_30")
  }

  func testDBASE31() {
    assertCanParse(filename: "dbase_31")
  }

  func testDBASE83() {
    assertCanParse(filename: "dbase_83")
  }

  func testDBASE83NoMemo() {
    assertCanParse(filename: "dbase_83_missing_memo")
  }

  func testDBASE8B() {
    assertCanParse(filename: "dbase_8b")
  }

  func testDBASEF5() {
    assertCanParse(filename: "dbase_f5")
  }

  private func assertCanParse(filename: String) {
    let url = Bundle(for: type(of: self)).url(forResource: filename, withExtension: "dbf")!
    let data = try! Data(contentsOf: url, options: .mappedIfSafe)
    if let header = try? DBFFileHeader(data: data, start: 0) {
      print(header)
    } else {
      XCTFail("Could not parse header \(filename).")
    }
  }
}
