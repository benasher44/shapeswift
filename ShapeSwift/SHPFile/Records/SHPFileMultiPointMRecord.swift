//
//  SHPFileMultiPointMRecord.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 6/4/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

// MARK: Parser

extension SHPFileMultiPointMRecord {
  struct Parser {
    let box: ShapeDataParser<LittleEndian<BoundingBoxXY>>
    let points: ShapeDataArrayParser<LittleEndian<Coordinate2D>>
    let mBounds: ShapeDataParser<LittleEndian<Coordinate2DBounds>>
    let measures: ShapeDataArrayParser<LittleEndian<Double>>
    init(data: Data, start: Int) throws {
      box = ShapeDataParser<LittleEndian<BoundingBoxXY>>(start: start)
      let numPointsParser = ShapeDataParser<LittleEndian<Int32>>(start: box.end)
      let numPoints = try Int(numPointsParser.parse(data))
      points = ShapeDataArrayParser<LittleEndian<Coordinate2D>>(start: numPointsParser.end, count: numPoints)
      mBounds = ShapeDataParser<LittleEndian<Coordinate2DBounds>>(start: points.end)
      measures = ShapeDataArrayParser<LittleEndian<Double>>(start: mBounds.end, count: numPoints)
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
    box = try parser.box.parse(data)
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
