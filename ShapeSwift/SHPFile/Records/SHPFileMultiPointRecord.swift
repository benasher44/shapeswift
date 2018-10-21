//
//  SHPFileMultiPointRecord.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 6/2/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

// MARK: Parser

extension SHPFileMultiPointRecord {
  private struct Parser {
    let box: ByteParser<BoundingBoxXY, LittleEndian>
    let points: ByteParser<Coordinate2D, LittleEndian>

    init(data: Data, start: Int) throws {
      self.box = ByteParser<BoundingBoxXY, LittleEndian>(start: start)
      let numPointsParser = ByteParser<Int32, LittleEndian>(start: box.end)
      let numPoints = try Int(numPointsParser.parse(data))
      self.points = ByteParser<Coordinate2D, LittleEndian>(start: numPointsParser.end, count: numPoints)
    }
  }
}

// MARK: Record

struct SHPFileMultiPointRecord: Equatable {
  let recordNumber: Int
  let box: BoundingBoxXY
  let points: [Coordinate2D]
}

extension SHPFileMultiPointRecord: SHPFileRecord {
  static let shapeType = ShapeType.multiPoint

  init(recordNumber: Int, data: Data, range: Range<Int>, endByte: inout Int) throws {
    self.recordNumber = recordNumber
    let parser = try Parser(data: data, start: range.lowerBound)
    self.box = try parser.box.parse(data)
    self.points = try parser.points.parse(data)
    endByte = parser.points.end - 1
  }
}
