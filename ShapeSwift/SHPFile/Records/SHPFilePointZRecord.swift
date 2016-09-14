//
//  SHPFilePointZRecord.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 6/9/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

// MARK: Parser

struct SHPFilePointZRecordParser {
  let x: ShapeDataParser<LittleEndian<Double>>
  let y: ShapeDataParser<LittleEndian<Double>>
  let z: ShapeDataParser<LittleEndian<Double>>
  let m: ShapeDataParser<LittleEndian<Double>>
  init(start: Int) {
    x = ShapeDataParser<LittleEndian<Double>>(start: start)
    y = ShapeDataParser<LittleEndian<Double>>(start: x.end)
    z = ShapeDataParser<LittleEndian<Double>>(start: y.end)
    m = ShapeDataParser<LittleEndian<Double>>(start: z.end)
  }
}

// MARK: Record

struct SHPFilePointZRecord {
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

// MARK: Equatable

func == (lhs: SHPFilePointZRecord, rhs: SHPFilePointZRecord) -> Bool {
  return (
    lhs.recordNumber == rhs.recordNumber &&
      lhs.x == rhs.x &&
      lhs.y == rhs.y &&
      lhs.z == rhs.z &&
      lhs.m == rhs.m
  )
}

extension SHPFilePointZRecord: Equatable {}