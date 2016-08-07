//
//  RecordParsingTestUtil.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 6/2/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import XCTest
@testable import ShapeSwift

extension XCTestCase {
  func testParsingRecord<RecordT: SHPFileRecord where RecordT: ByteEncodable, RecordT: Equatable>(_ record: RecordT, range: Range<Int>, dataRecord: RecordT? = nil) {
    let data = Data(byteEncodableArray: [dataRecord ?? record])
    var endByte = 0
    let parsedRecord = try! RecordT(data: data, range: range, endByte: &endByte)
    let byteRange: Range = 4..<endByte + 1 // Start at 4 to account for the shape type
    XCTAssertEqual(byteRange, range)
    XCTAssertEqual(record, parsedRecord)
  }
}
