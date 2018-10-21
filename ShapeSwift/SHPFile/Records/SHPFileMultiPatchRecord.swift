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
    let box: ByteParser<BoundingBoxXY, LittleEndian>
    let parts: ByteParser<Int32, LittleEndian>
    let partTypes: ByteParser<MultiPatchPartType, LittleEndian>
    let points: ByteParser<Coordinate2D, LittleEndian>
    let zBounds: ByteParser<Coordinate2DBounds, LittleEndian>
    let zValues: ByteParser<Double, LittleEndian>
    let mBounds: ByteParser<Coordinate2DBounds, LittleEndian>
    let measures: ByteParser<Double, LittleEndian>

    init(data: Data, start: Int) throws {
      box = ByteParser<BoundingBoxXY, LittleEndian>(start: start)
      let numPartsParser = ByteParser<Int32, LittleEndian>(start: box.end)
      let numParts = try Int(numPartsParser.parse(data))
      let numPointsParser = ByteParser<Int32, LittleEndian>(start: numPartsParser.end)
      let numPoints = try Int(numPointsParser.parse(data))
      parts = ByteParser<Int32, LittleEndian>(start: numPointsParser.end, count: numParts)
      partTypes = ByteParser<MultiPatchPartType, LittleEndian>(start: parts.end, count: numParts)
      points = ByteParser<Coordinate2D, LittleEndian>(start: partTypes.end, count: numPoints)
      zBounds = ByteParser<Coordinate2DBounds, LittleEndian>(start: points.end)
      zValues = ByteParser<Double, LittleEndian>(start: zBounds.end, count: numPoints)
      mBounds = ByteParser<Coordinate2DBounds, LittleEndian>(start: zValues.end)
      measures = ByteParser<Double, LittleEndian>(start: mBounds.end, count: numPoints)
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
