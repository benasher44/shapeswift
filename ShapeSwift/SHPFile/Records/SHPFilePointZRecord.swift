//
//  SHPFilePointZRecord.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 6/9/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

// MARK: Parser

struct SHPFilePointZRecordParser {
  let x: ByteParser<Double, LittleEndian>
  let y: ByteParser<Double, LittleEndian>
  let z: ByteParser<Double, LittleEndian>
  let m: ByteParser<Double, LittleEndian>
  init(start: Int) {
    self.x = ByteParser<Double, LittleEndian>(start: start)
    self.y = ByteParser<Double, LittleEndian>(start: x.end)
    self.z = ByteParser<Double, LittleEndian>(start: y.end)
    m = ByteParser<Double, LittleEndian>(start: z.end)
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
    self.x = try parser.x.parse(data)
    self.y = try parser.y.parse(data)
    self.z = try parser.z.parse(data)
    if range.contains(parser.m.start) {
      m = valueOrNilIfNoDataValue(try parser.m.parse(data))
      endByte = parser.m.end - 1
    } else {
      m = nil
      endByte = parser.z.end - 1
    }
  }
}
