//
//  SHPFilePolyLineZRecord.swift
//  ShapeSwift
//
//  Created by Ben Asher on 6/16/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

// MARK: Parser

extension SHPFilePolyLineZRecord {
  private struct Parser {
    let box: ByteParser<BoundingBoxXY, LittleEndian>
    let parts: ByteParser<Int32, LittleEndian>
    let points: ByteParser<Coordinate2D, LittleEndian>
    let zBounds: ByteParser<Coordinate2DBounds, LittleEndian>
    let zValues: ByteParser<Double, LittleEndian>
    let mBounds: ByteParser<Coordinate2DBounds, LittleEndian>
    let measures: ByteParser<Double, LittleEndian>
    init(data: Data, start: Int) throws {
      self.box = ByteParser<BoundingBoxXY, LittleEndian>(start: start)
      let numPartsParser = ByteParser<Int32, LittleEndian>(start: box.end)
      let numParts = try Int(numPartsParser.parse(data))
      let numPointsParser = ByteParser<Int32, LittleEndian>(start: numPartsParser.end)
      let numPoints = try Int(numPointsParser.parse(data))
      self.parts = ByteParser<Int32, LittleEndian>(start: numPointsParser.end, count: numParts)
      self.points = ByteParser<Coordinate2D, LittleEndian>(start: parts.end, count: numPoints)
      self.zBounds = ByteParser<Coordinate2DBounds, LittleEndian>(start: points.end)
      self.zValues = ByteParser<Double, LittleEndian>(start: zBounds.end, count: numPoints)
      self.mBounds = ByteParser<Coordinate2DBounds, LittleEndian>(start: zValues.end)
      self.measures = ByteParser<Double, LittleEndian>(start: mBounds.end, count: numPoints)
    }
  }
}

// MARK: Record

struct SHPFilePolyLineZRecord: Equatable {
  let recordNumber: Int
  let box: BoundingBoxXY
  let parts: [Int]
  let points: [Coordinate2D]
  let zBounds: Coordinate2DBounds
  let zValues: [Double]
  let mBounds: Coordinate2DBounds?
  let measures: [Double]
}

extension SHPFilePolyLineZRecord: SHPFileRecord {
  static let shapeType = ShapeType.polyLineZ

  init(recordNumber: Int, data: Data, range: Range<Int>, endByte: inout Int) throws {
    self.recordNumber = recordNumber
    let parser = try Parser(data: data, start: range.lowerBound)
    self.box = try parser.box.parse(data)
    self.parts = try parser.parts.parse(data).map(Int.init)
    self.points = try parser.points.parse(data)
    self.zBounds = try parser.zBounds.parse(data)
    self.zValues = try parser.zValues.parse(data)
    if range.contains(parser.mBounds.start) {
      self.mBounds = try valueOrNilIfNoDataValue(parser.mBounds.parse(data))
      self.measures = try parser.measures.parse(data).compactMap(valueOrNilIfNoDataValue)
      endByte = parser.measures.end - 1
    } else {
      self.mBounds = nil
      self.measures = []
      endByte = parser.zValues.end - 1
    }
  }
}
