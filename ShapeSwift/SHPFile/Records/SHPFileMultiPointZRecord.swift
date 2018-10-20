//
//  SHPFileMultiPointZRecord.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 6/16/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

// MARK: Record

struct SHPFileMultiPointZRecord: Equatable {
  let recordNumber: Int
  let box: BoundingBoxXY
  let points: [Coordinate2D]
  let zBounds: Coordinate2DBounds
  let zValues: [Double]
  let mBounds: Coordinate2DBounds?
  let measures: [Double]
}

extension SHPFileMultiPointZRecord: SHPFileRecord {
  static let shapeType = ShapeType.pointZ

  init(recordNumber: Int, data: Data, range: Range<Int>, endByte: inout Int) throws {
    self.recordNumber = recordNumber
    let parser = try Parser(data: data, start: range.lowerBound)
    box = try parser.box.parse(data)
    points = try parser.points.parse(data)
    zBounds = try parser.zBounds.parse(data)
    zValues = try parser.zValues.parse(data)
    if range.contains(parser.mBounds.start) {
      mBounds = try valueOrNilIfNoDataValue(parser.mBounds.parse(data))
      measures = try parser.measures.parse(data).compactMap(valueOrNilIfNoDataValue)
      endByte = parser.measures.end - 1
    } else {
      mBounds = nil
      measures = []
      endByte = parser.zValues.end - 1
    }
  }
}

// MARK: Parser

extension SHPFileMultiPointZRecord {
  struct Parser {
    let box: ByteParseableDataParser<BoundingBoxXY, LittleEndian>
    let points: ByteParseableArrayDataParser<Coordinate2D, LittleEndian>
    let zBounds: ByteParseableDataParser<Coordinate2DBounds, LittleEndian>
    let zValues: ByteParseableArrayDataParser<Double, LittleEndian>
    let mBounds: ByteParseableDataParser<Coordinate2DBounds, LittleEndian>
    let measures: ByteParseableArrayDataParser<Double, LittleEndian>
    init(data: Data, start: Int) throws {
      box = ByteParseableDataParser<BoundingBoxXY, LittleEndian>(start: start)
      let numPointsParser = ByteParseableDataParser<Int32, LittleEndian>(start: box.end)
      let numPoints = try Int(numPointsParser.parse(data))
      points = ByteParseableArrayDataParser<Coordinate2D, LittleEndian>(start: numPointsParser.end, count: numPoints)
      zBounds = ByteParseableDataParser<Coordinate2DBounds, LittleEndian>(start: points.end)
      zValues = ByteParseableArrayDataParser<Double, LittleEndian>(start: zBounds.end, count: numPoints)
      mBounds = ByteParseableDataParser<Coordinate2DBounds, LittleEndian>(start: zValues.end)
      measures = ByteParseableArrayDataParser<Double, LittleEndian>(start: mBounds.end, count: numPoints)
    }
  }
}
