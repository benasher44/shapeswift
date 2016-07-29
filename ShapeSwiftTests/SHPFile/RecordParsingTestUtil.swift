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
  func testParsingRecord<RecordT: SHPFileRecord where RecordT: ByteEncodable, RecordT: Equatable>(_ record: RecordT, range: Range<Int>) {
    let data = Data(byteEncodableArray: [record])
    let parsedRecord = try! RecordT(data: data, range: range)
    XCTAssertEqual(record, parsedRecord)
  }
}
