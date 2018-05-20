//
//  SHPFileRecordHeader.swift
//  ShapeSwift
//
//  Created by Ben Asher on 8/4/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

struct SHPFileRecordHeader {
  static let byteWidth = 8
  let recordNumber: Int
  let contentLength: Int
}

extension SHPFileRecordHeader {
  struct Parser {
    let recordNumber: ShapeDataParser<BigEndian<Int32>>
    let contentLength: ShapeDataParser<BigEndian<Int32>>
    init(start: Int) {
      recordNumber = ShapeDataParser<BigEndian<Int32>>(start: start)
      contentLength = ShapeDataParser<BigEndian<Int32>>(start: start + Int32.byteWidth)
    }
  }

  init(data: Data, start: Int) throws {
    let parser = Parser(start: start)
    recordNumber = try Int(parser.recordNumber.parse(data))
    contentLength = try Int(parser.contentLength.parse(data)) * 2 // This value is the length in words, so multiply * 2 to get bytes
  }
}
