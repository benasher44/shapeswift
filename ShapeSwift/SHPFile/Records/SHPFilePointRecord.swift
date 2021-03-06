//
//  SHPFilePointRecord.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 6/2/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

// MARK: Parser

extension SHPFilePointRecord {
  private struct Parser {
    let point: ByteParser<Coordinate2D, LittleEndian>

    init(start: Int) {
      self.point = ByteParser<Coordinate2D, LittleEndian>(start: start)
    }
  }
}

// MARK: Record

struct SHPFilePointRecord: Equatable {
  let recordNumber: Int
  let point: Coordinate2D
}

extension SHPFilePointRecord: SHPFileRecord {
  static let shapeType = ShapeType.point

  init(recordNumber: Int, data: Data, range: Range<Int>, endByte: inout Int) throws {
    self.recordNumber = recordNumber
    let parser = Parser(start: range.lowerBound)
    self.point = try parser.point.parse(data)
    endByte = parser.point.end - 1
  }
}
