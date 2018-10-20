//
//  SHPFileMultiPatchRecord.swift
//  ShapeSwift
//
//  Created by Ben Asher on 7/14/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

// MARK: Multipatch

extension SHPFileMultiPatchRecord {
  private struct Parser {
    let box: ByteParseableDataParser<BoundingBoxXY, LittleEndian>
    let parts: ByteParseableArrayDataParser<Int32, LittleEndian>
    let partTypes: ByteParseableArrayDataParser<MultiPatchPartType, LittleEndian>
    let points: ByteParseableArrayDataParser<Coordinate2D, LittleEndian>
    let zBounds: ByteParseableDataParser<Coordinate2DBounds, LittleEndian>
    let zValues: ByteParseableArrayDataParser<Double, LittleEndian>
    let mBounds: ByteParseableDataParser<Coordinate2DBounds, LittleEndian>
    let measures: ByteParseableArrayDataParser<Double, LittleEndian>

    init(data: Data, start: Int) throws {
      box = ByteParseableDataParser<BoundingBoxXY, LittleEndian>(start: start)
      let numPartsParser = ByteParseableDataParser<Int32, LittleEndian>(start: box.end)
      let numParts = try Int(numPartsParser.parse(data))
      let numPointsParser = ByteParseableDataParser<Int32, LittleEndian>(start: numPartsParser.end)
      let numPoints = try Int(numPointsParser.parse(data))
      parts = ByteParseableArrayDataParser<Int32, LittleEndian>(start: numPointsParser.end, count: numParts)
      partTypes = ByteParseableArrayDataParser<MultiPatchPartType, LittleEndian>(start: parts.end, count: numParts)
      points = ByteParseableArrayDataParser<Coordinate2D, LittleEndian>(start: partTypes.end, count: numPoints)
      zBounds = ByteParseableDataParser<Coordinate2DBounds, LittleEndian>(start: points.end)
      zValues = ByteParseableArrayDataParser<Double, LittleEndian>(start: zBounds.end, count: numPoints)
      mBounds = ByteParseableDataParser<Coordinate2DBounds, LittleEndian>(start: zValues.end)
      measures = ByteParseableArrayDataParser<Double, LittleEndian>(start: mBounds.end, count: numPoints)
    }
  }
}

// MARK: Record

struct SHPFileMultiPatchRecord: Equatable {
  let recordNumber: Int
  let box: BoundingBoxXY
  let parts: [Int]
  let partTypes: [MultiPatchPartType]
  let points: [Coordinate2D]
  let zBounds: Coordinate2DBounds
  let zValues: [Double]
  let mBounds: Coordinate2DBounds?
  let measures: [Double]
}

extension SHPFileMultiPatchRecord: SHPFileRecord {
  static let shapeType = ShapeType.multiPatch

  init(recordNumber: Int, data: Data, range: Range<Int>, endByte: inout Int) throws {
    self.recordNumber = recordNumber
    let parser = try Parser(data: data, start: range.lowerBound)
    box = try parser.box.parse(data)
    parts = try parser.parts.parse(data).map(Int.init)
    partTypes = try parser.partTypes.parse(data)
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
