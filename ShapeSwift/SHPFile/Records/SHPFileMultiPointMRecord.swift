//
//  SHPFileMultiPointMRecord.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 6/4/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

// MARK: Parser

extension SHPFileMultiPointMRecord {
  private struct Parser {
    let box: ByteParser<BoundingBoxXY, LittleEndian>
    let points: ByteParser<Coordinate2D, LittleEndian>
    let mBounds: ByteParser<Coordinate2DBounds, LittleEndian>
    let measures: ByteParser<Double, LittleEndian>
    init(data: Data, start: Int) throws {
      self.box = ByteParser<BoundingBoxXY, LittleEndian>(start: start)
      let numPointsParser = ByteParser<Int32, LittleEndian>(start: box.end)
      let numPoints = try Int(numPointsParser.parse(data))
      self.points = ByteParser<Coordinate2D, LittleEndian>(start: numPointsParser.end, count: numPoints)
      self.mBounds = ByteParser<Coordinate2DBounds, LittleEndian>(start: points.end)
      self.measures = ByteParser<Double, LittleEndian>(start: mBounds.end, count: numPoints)
    }
  }
}

// MARK: Record

struct SHPFileMultiPointMRecord: Equatable {
  let recordNumber: Int
  let box: BoundingBoxXY
  let points: [Coordinate2D]
  let mBounds: Coordinate2DBounds?
  let measures: [Double]
}

extension SHPFileMultiPointMRecord: SHPFileRecord {
  static let shapeType = ShapeType.pointM

  init(recordNumber: Int, data: Data, range: Range<Int>, endByte: inout Int) throws {
    self.recordNumber = recordNumber
    let parser = try Parser(data: data, start: range.lowerBound)
    self.box = try parser.box.parse(data)
    self.points = try parser.points.parse(data)
    if range.contains(parser.mBounds.start) {
      self.mBounds = try valueOrNilIfNoDataValue(parser.mBounds.parse(data))
      self.measures = try parser.measures.parse(data).compactMap(valueOrNilIfNoDataValue)
      endByte = parser.measures.end - 1
    } else {
      self.mBounds = nil
      self.measures = []
      endByte = parser.points.end - 1
    }
  }
}
