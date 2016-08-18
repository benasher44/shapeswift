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
  func testParsingRecord<Record: SHPFileRecord>(_ record: Record, range: Range<Int>, dataRecord: Record? = nil) where Record: ByteEncodable, Record: Equatable {
    let data = Data(byteEncodableArray: [dataRecord ?? record])
    var endByte = 0
    let parsedRecord = try! Record(recordNumber: record.recordNumber, data: data, range: range, endByte: &endByte)
    let byteRange: Range = 4..<endByte + 1 // Start at 4 to account for the shape type
    XCTAssertEqual(byteRange, range)
    XCTAssertEqual(record, parsedRecord)
  }
}
