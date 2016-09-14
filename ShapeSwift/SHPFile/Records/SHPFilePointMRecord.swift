//
//  SHPFilePointMRecord.swift
//  ShapeSwift
//
//  Created by Ben Asher on 8/25/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

// MARK: Parser

struct SHPFilePointMRecordParser {
  let x: ShapeDataParser<LittleEndian<Double>>
  let y: ShapeDataParser<LittleEndian<Double>>
  let m: ShapeDataParser<LittleEndian<Double>>
  init(start: Int) {
    x = ShapeDataParser<LittleEndian<Double>>(start: start)
    y = ShapeDataParser<LittleEndian<Double>>(start: x.end)
    m = ShapeDataParser<LittleEndian<Double>>(start: y.end)
  }
}

// MARK: Record

struct SHPFilePointMRecord {
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

// MARK: Equatable

func == (lhs: SHPFilePointMRecord, rhs: SHPFilePointMRecord) -> Bool {
  return (
    lhs.recordNumber == rhs.recordNumber &&
      lhs.x == rhs.x &&
      lhs.y == rhs.y &&
      lhs.m == rhs.m
  )
}

extension SHPFilePointMRecord: Equatable {}