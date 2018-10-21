//
//  SHPFilePointMRecord.swift
//  ShapeSwift
//
//  Created by Ben Asher on 8/25/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

// MARK: Parser

struct SHPFilePointMRecordParser {
  let x: ByteParser<Double, LittleEndian>
  let y: ByteParser<Double, LittleEndian>
  let m: ByteParser<Double, LittleEndian>
  init(start: Int) {
    x = ByteParser<Double, LittleEndian>(start: start)
    y = ByteParser<Double, LittleEndian>(start: x.end)
    m = ByteParser<Double, LittleEndian>(start: y.end)
  }
}

// MARK: Record

struct SHPFilePointMRecord: Equatable {
  let recordNumber: Int
  let x: Double
  let y: Double
  let m: Double?
}

extension SHPFilePointMRecord: SHPFileRecord {
  static let shapeType = ShapeType.pointM

  init(recordNumber: Int, data: Data, range: Range<Int>, endByte: inout Int) throws {
    self.recordNumber = recordNumber
    let parser = SHPFilePointMRecordParser(start: range.lowerBound)
    x = try parser.x.parse(data)
    y = try parser.y.parse(data)
    if range.contains(parser.m.start) {
      m = valueOrNilIfNoDataValue(try parser.m.parse(data))
      endByte = parser.m.end - 1
    } else {
      m = nil
      endByte = parser.y.end - 1
    }
  }
}
