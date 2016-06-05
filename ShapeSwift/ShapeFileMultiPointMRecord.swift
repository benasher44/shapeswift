//
//  ShapeFileMultiPointMRecord.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 6/4/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import Foundation

// MARK: Parser

struct ShapeFileMultiPointMRecordParser {
  let box: ShapeDataParser<LittleEndian<BoundingBoxXY>>
  let points: ShapeDataArrayParser<LittleEndian<Coordinate2D>>
  let mBounds: ShapeDataParser<LittleEndian<Coordinate2DBounds>>
  let mPoints: ShapeDataArrayParser<LittleEndian<Coordinate2D>>
  init(data: NSData, start: Int) throws {
    box = ShapeDataParser<LittleEndian<BoundingBoxXY>>(start: start)
    let numPointsParser = ShapeDataParser<LittleEndian<Int32>>(start: box.end)
    let numPoints = try Int(numPointsParser.parse(data))
    points = ShapeDataArrayParser<LittleEndian<Coordinate2D>>(start: numPointsParser.end, count: numPoints)
    mBounds = ShapeDataParser<LittleEndian<Coordinate2DBounds>>(start: points.end)
    mPoints = ShapeDataArrayParser<LittleEndian<Coordinate2D>>(start: mBounds.end, count: numPoints)
  }
}

// MARK: Record

struct ShapeFileMultiPointMRecord: ShapeFileRecord {
  let box: BoundingBoxXY
  let points: [Coordinate2D]
  let mBounds: Coordinate2DBounds?
  let mPoints: [Coordinate2D]
  init(data: NSData, range: Range<Int>) throws {
    let parser = try ShapeFileMultiPointMRecordParser(data: data, start: range.startIndex)
    box = try parser.box.parse(data)
    points = try parser.points.parse(data)
    if range.endIndex > parser.mBounds.start {
      mBounds = try valueOrNilForOptionalValue(parser.mBounds.parse(data))
      mPoints = try parser.mPoints.parse(data).flatMap(valueOrNilForOptionalValue)
    } else {
      mBounds = nil
      mPoints = []
    }
  }
}
