//
//  SHPFilePointZRecord.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 6/9/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

// MARK: Parser

struct SHPFilePointZRecordParser {
  let x: ByteParseableDataParser<Double, LittleEndian>
  let y: ByteParseableDataParser<Double, LittleEndian>
  let z: ByteParseableDataParser<Double, LittleEndian>
  let m: ByteParseableDataParser<Double, LittleEndian>
  init(start: Int) {
    x = ByteParseableDataParser<Double, LittleEndian>(start: start)
    y = ByteParseableDataParser<Double, LittleEndian>(start: x.end)
    z = ByteParseableDataParser<Double, LittleEndian>(start: y.end)
    m = ByteParseableDataParser<Double, LittleEndian>(start: z.end)
  }
}

// MARK: Record

struct SHPFilePointZRecord: Equatable {
  let recordNumber: Int
  let x: Double
  let y: Double
  let z: Double
  let m: Double?
}

extension SHPFilePointZRecord: SHPFileRecord {
  static let shapeType = ShapeType.pointZ

  init(recordNumber: Int, data: Data, range: Range<Int>, endByte: inout Int) throws {
    self.recordNumber = recordNumber
    let parser = SHPFilePointZRecordParser(start: range.lowerBound)
    x = try parser.x.parse(data)
    y = try parser.y.parse(data)
    z = try parser.z.parse(data)
    if range.contains(parser.m.start) {
      m = valueOrNilIfNoDataValue(try parser.m.parse(data))
      endByte = parser.m.end - 1
    } else {
      m = nil
      endByte = parser.z.end - 1
    }
  }
}
