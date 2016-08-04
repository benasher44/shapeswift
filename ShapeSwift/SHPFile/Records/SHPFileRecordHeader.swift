//
//  SHPFileRecordHeader.swift
//  ShapeSwift
//
//  Created by Ben Asher on 8/4/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

struct SHPFileRecordHeader {
  let recordNumber: Int
  let contentLength: Int
}

extension SHPFileRecordHeader {
  struct Parser {
    let recordNumber: ShapeDataParser<BigEndian<Int32>>
    let contentLength: ShapeDataParser<BigEndian<Int32>>
    init(start: Int) {
      recordNumber = ShapeDataParser<BigEndian<Int32>>(start: start)
      contentLength = ShapeDataParser<BigEndian<Int32>>(start: start + Int32.sizeBytes)
    }
  }

  init(data: Data, start: Int) throws {
    let parser = Parser(start: start)
    recordNumber = try Int(parser.recordNumber.parse(data))
    contentLength = try Int(parser.contentLength.parse(data))
  }
}

