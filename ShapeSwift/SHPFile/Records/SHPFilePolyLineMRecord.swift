//
//  SHPFilePolyLineMRecord.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 6/9/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

// MARK: Parser

extension SHPFilePolyLineMRecord {
  private struct Parser {
    let box: ByteParseableDataParser<BoundingBoxXY, LittleEndian>
    let parts: ByteParseableArrayDataParser<Int32, LittleEndian>
    let points: ByteParseableArrayDataParser<Coordinate2D, LittleEndian>
    let mBounds: ByteParseableDataParser<Coordinate2DBounds, LittleEndian>
    let measures: ByteParseableArrayDataParser<Double, LittleEndian>
    init(data: Data, start: Int) throws {
      box = ByteParseableDataParser<BoundingBoxXY, LittleEndian>(start: start)
      let numPartsParser = ByteParseableDataParser<Int32, LittleEndian>(start: box.end)
      let numParts = try Int(numPartsParser.parse(data))
      let numPointsParser = ByteParseableDataParser<Int32, LittleEndian>(start: numPartsParser.end)
      let numPoints = try Int(numPointsParser.parse(data))
      parts = ByteParseableArrayDataParser<Int32, LittleEndian>(start: numPointsParser.end, count: numParts)
      points = ByteParseableArrayDataParser<Coordinate2D, LittleEndian>(start: parts.end, count: numPoints)
      mBounds = ByteParseableDataParser<Coordinate2DBounds, LittleEndian>(start: points.end)
      measures = ByteParseableArrayDataParser<Double, LittleEndian>(start: mBounds.end, count: numPoints)
    }
  }
}

// MARK: Record

struct SHPFilePolyLineMRecord: Equatable {
  let recordNumber: Int
  let box: BoundingBoxXY
  let parts: [Int]
  let points: [Coordinate2D]
  let mBounds: Coordinate2DBounds?
  let measures: [Double]
}

extension SHPFilePolyLineMRecord: SHPFileRecord {
  static let shapeType = ShapeType.polyLineM

  init(recordNumber: Int, data: Data, range: Range<Int>, endByte: inout Int) throws {
    self.recordNumber = recordNumber
    let parser = try Parser(data: data, start: range.lowerBound)
    box = try parser.box.parse(data)
    parts = try parser.parts.parse(data).map(Int.init)
    points = try parser.points.parse(data)
    if range.contains(parser.mBounds.start) {
      mBounds = try valueOrNilIfNoDataValue(parser.mBounds.parse(data))
      measures = try parser.measures.parse(data).compactMap(valueOrNilIfNoDataValue)
      endByte = parser.measures.end - 1
    } else {
      mBounds = nil
      measures = []
      endByte = parser.points.end - 1
    }
  }
}
