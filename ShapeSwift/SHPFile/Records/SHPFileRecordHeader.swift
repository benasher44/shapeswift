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
  private struct Parser {
    let recordNumber: ByteParser<Int32, BigEndian>
    let contentLength: ByteParser<Int32, BigEndian>
    init(start: Int) {
      recordNumber = ByteParser<Int32, BigEndian>(start: start)
      contentLength = ByteParser<Int32, BigEndian>(start: start + Int32.byteWidth)
    }
  }

  init(data: Data, start: Int) throws {
    let parser = Parser(start: start)
    recordNumber = try Int(parser.recordNumber.parse(data))
    contentLength = try Int(parser.contentLength.parse(data)) * 2 // This value is the length in words, so multiply * 2 to get bytes
  }
}
