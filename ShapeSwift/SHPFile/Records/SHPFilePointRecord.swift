//
//  SHPFilePointRecord.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 6/2/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

// MARK: Parser

extension SHPFilePointRecord {
  struct Parser {
    let point: ShapeDataParser<LittleEndian<Coordinate2D>>

    init(start: Int) {
      point = ShapeDataParser<LittleEndian<Coordinate2D>>(start: start)
    }
  }
}

// MARK: Record

struct SHPFilePointRecord {
  let recordNumber: Int
  let point: Coordinate2D
}

extension SHPFilePointRecord: SHPFileRecord {
  static let shapeType = ShapeType.point

  init(recordNumber: Int, data: Data, range: Range<Int>, endByte: inout Int) throws {
    self.recordNumber = recordNumber
    let parser = Parser(start: range.lowerBound)
    point = try parser.point.parse(data)
    endByte = parser.point.end - 1
  }
}

// MARK: Equatable

func == (lhs: SHPFilePointRecord, rhs: SHPFilePointRecord) -> Bool {
  return lhs.recordNumber == rhs.recordNumber && lhs.point == rhs.point
}

extension SHPFilePointRecord: Equatable {}
