//
//  SHPFileRecord.swift
//  ShapeSwift
//
//  Created by Ben Asher on 4/29/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import Foundation

private let noDataValue: Double = -pow(10, 38)

func valueOrNilForOptionalValue(value: CoordinateBounds) -> CoordinateBounds? {
  if value.min < noDataValue || value.max < noDataValue{
    return nil
  } else {
    return value
  }
}

func valueOrNilForOptionalValue(value: Coordinate) -> Coordinate? {
  if value.x < noDataValue || value.x < noDataValue{
    return nil
  } else {
    return value
  }
}

protocol ShapeFileRecord {
  init(data: NSData, range: Range<Int>) throws
}

extension ShapeFileRecord {
  static func recordForShapeType(shapeType: ShapeType, data: NSData, range: Range<Int>) throws -> ShapeFileRecord? {
    var type: ShapeFileRecord.Type
    switch shapeType {
    case .point:
      type = ShapeFilePointRecord.self
    default:
      return nil
    }
    return try type.init(data: data, range: range)
  }
}

// MARK: Point

struct ShapeFilePointRecordParser {
  let point: ShapeDataParser<LittleEndian<Coordinate>>

  init(start: Int) {
    point = ShapeDataParser<LittleEndian<Coordinate>>(start: start)
  }
}

struct ShapeFilePointRecord: ShapeFileRecord {
  let point: Coordinate

  init(data: NSData, range: Range<Int>) throws {
    let parser = ShapeFilePointRecordParser(start: range.startIndex)
    point = try parser.point.parse(data)
  }
}

// MARK: MultiPoint

struct ShapeFileMultiPointRecordParser {
  let box: ShapeDataParser<LittleEndian<BoundingBoxXY>>
  let points: ShapeDataArrayParser<LittleEndian<Coordinate>>

  init(data: NSData, start: Int) throws {
    box = ShapeDataParser<LittleEndian<BoundingBoxXY>>(start: start)
    let numPoints = try Int(ShapeDataParser<LittleEndian<Int32>>(start: box.end).parse(data))
    points = ShapeDataArrayParser<LittleEndian<Coordinate>>(start: start + BoundingBoxXY.sizeBytes + Int32.sizeBytes, count: numPoints)
  }
}

struct ShapeFileMultiPointRecord: ShapeFileRecord {
  let box: BoundingBoxXY
  let points: [Coordinate]

  init(data: NSData, range: Range<Int>) throws {
    let parser = try ShapeFileMultiPointRecordParser(data: data, start: range.startIndex)
    box = try parser.box.parse(data)
    points = try parser.points.parse(data)
  }
}

// MARK: MultiPointZ

struct ShapeFileMultiPointZRecordParser {
  let box: ShapeDataParser<LittleEndian<BoundingBoxXY>>
  let points: ShapeDataArrayParser<LittleEndian<Coordinate>>
  let zBounds: ShapeDataParser<LittleEndian<CoordinateBounds>>
  let zPoints: ShapeDataArrayParser<LittleEndian<Coordinate>>
  let mBounds: ShapeDataParser<LittleEndian<CoordinateBounds>>
  let mPoints: ShapeDataArrayParser<LittleEndian<Coordinate>>
  init(data: NSData, start: Int) throws {
    box = ShapeDataParser<LittleEndian<BoundingBoxXY>>(start: start)
    let numPointsParser = ShapeDataParser<LittleEndian<Int32>>(start: box.end)
    let numPoints = try Int(numPointsParser.parse(data))
    points = ShapeDataArrayParser<LittleEndian<Coordinate>>(start: numPointsParser.end, count: numPoints)
    zBounds = ShapeDataParser<LittleEndian<CoordinateBounds>>(start: points.end)
    zPoints = ShapeDataArrayParser<LittleEndian<Coordinate>>(start: zBounds.end, count: numPoints)
    mBounds = ShapeDataParser<LittleEndian<CoordinateBounds>>(start: zPoints.end)
    mPoints = ShapeDataArrayParser<LittleEndian<Coordinate>>(start: mBounds.end, count: numPoints)
  }
}

struct ShapeFileMultiPointZRecord: ShapeFileRecord {
  let box: BoundingBoxXY
  let points: [Coordinate]
  let zBounds: CoordinateBounds
  let zPoints: [Coordinate]
  let mBounds: CoordinateBounds?
  let mPoints: [Coordinate]
  init(data: NSData, range: Range<Int>) throws {
    let parser = try ShapeFileMultiPointZRecordParser(data: data, start: range.startIndex)
    box = try parser.box.parse(data)
    points = try parser.points.parse(data)
    zBounds = try parser.zBounds.parse(data)
    zPoints = try parser.zPoints.parse(data)
    if range.endIndex > parser.mBounds.start {
      mBounds = try valueOrNilForOptionalValue(parser.mBounds.parse(data))
      mPoints = try parser.mPoints.parse(data).flatMap(valueOrNilForOptionalValue)
    } else {
      mBounds = nil
      mPoints = []
    }
  }
}

// MARK: PolyLineZ

struct ShapeFilePolyLineZRecordParser {
  let box: ShapeDataParser<LittleEndian<BoundingBoxXY>>
  let parts: ShapeDataArrayParser<LittleEndian<Int32>>
  let points: ShapeDataArrayParser<LittleEndian<Coordinate>>
  let zBounds: ShapeDataParser<LittleEndian<CoordinateBounds>>
  let zPoints: ShapeDataArrayParser<LittleEndian<Coordinate>>
  let mBounds: ShapeDataParser<LittleEndian<CoordinateBounds>>
  let mPoints: ShapeDataArrayParser<LittleEndian<Coordinate>>
  init(data: NSData, start: Int) throws {
    box = ShapeDataParser<LittleEndian<BoundingBoxXY>>(start: start)
    let numPartsParser = ShapeDataParser<LittleEndian<Int32>>(start: box.end)
    let numParts = try Int(numPartsParser.parse(data))
    let numPointsParser = ShapeDataParser<LittleEndian<Int32>>(start: numPartsParser.end)
    let numPoints = try Int(numPointsParser.parse(data))
    parts = ShapeDataArrayParser<LittleEndian<Int32>>(start: numPointsParser.end, count: numParts)
    points = ShapeDataArrayParser<LittleEndian<Coordinate>>(start: parts.end, count: numPoints)
    zBounds = ShapeDataParser<LittleEndian<CoordinateBounds>>(start: points.end)
    zPoints = ShapeDataArrayParser<LittleEndian<Coordinate>>(start: zBounds.end, count: numPoints)
    mBounds = ShapeDataParser<LittleEndian<CoordinateBounds>>(start: zPoints.end)
    mPoints = ShapeDataArrayParser<LittleEndian<Coordinate>>(start: mBounds.end, count: numPoints)
  }
}

struct ShapeFilePolyLineZRecord: ShapeFileRecord {
  let box: BoundingBoxXY
  let parts: [Int]
  let points: [Coordinate]
  let zBounds: CoordinateBounds
  let zPoints: [Coordinate]
  let mBounds: CoordinateBounds?
  let mPoints: [Coordinate]
  init(data: NSData, range: Range<Int>) throws {
    let parser = try ShapeFilePolyLineZRecordParser(data: data, start: range.startIndex)
    box = try parser.box.parse(data)
    parts = try parser.parts.parse(data).map(Int.init)
    points = try parser.points.parse(data)
    zBounds = try parser.zBounds.parse(data)
    zPoints = try parser.zPoints.parse(data)
    if range.endIndex > parser.mBounds.start {
      mBounds = try valueOrNilForOptionalValue(parser.mBounds.parse(data))
      mPoints = try parser.mPoints.parse(data).flatMap(valueOrNilForOptionalValue)
    } else {
      mBounds = nil
      mPoints = []
    }
  }
}

// MARK: PolygonZ

struct ShapeFilePolygonZRecordParser {
  let box: ShapeDataParser<LittleEndian<BoundingBoxXY>>
  let parts: ShapeDataArrayParser<LittleEndian<Int32>>
  let points: ShapeDataArrayParser<LittleEndian<Coordinate>>
  let zBounds: ShapeDataParser<LittleEndian<CoordinateBounds>>
  let zPoints: ShapeDataArrayParser<LittleEndian<Coordinate>>
  let mBounds: ShapeDataParser<LittleEndian<CoordinateBounds>>
  let mPoints: ShapeDataArrayParser<LittleEndian<Coordinate>>
  init(data: NSData, start: Int) throws {
    box = ShapeDataParser<LittleEndian<BoundingBoxXY>>(start: start)
    let numPartsParser = ShapeDataParser<LittleEndian<Int32>>(start: box.end)
    let numParts = try Int(numPartsParser.parse(data))
    let numPointsParser = ShapeDataParser<LittleEndian<Int32>>(start: numPartsParser.end)
    let numPoints = try Int(numPointsParser.parse(data))
    parts = ShapeDataArrayParser<LittleEndian<Int32>>(start: numPointsParser.end, count: numParts)
    points = ShapeDataArrayParser<LittleEndian<Coordinate>>(start: parts.end, count: numPoints)
    zBounds = ShapeDataParser<LittleEndian<CoordinateBounds>>(start: points.end)
    zPoints = ShapeDataArrayParser<LittleEndian<Coordinate>>(start: zBounds.end, count: numPoints)
    mBounds = ShapeDataParser<LittleEndian<CoordinateBounds>>(start: zPoints.end)
    mPoints = ShapeDataArrayParser<LittleEndian<Coordinate>>(start: mBounds.end, count: numPoints)
  }
}

struct ShapeFilePolygonZRecord: ShapeFileRecord {
  let box: BoundingBoxXY
  let parts: [Int]
  let points: [Coordinate]
  let zBounds: CoordinateBounds
  let zPoints: [Coordinate]
  let mBounds: CoordinateBounds?
  let mPoints: [Coordinate]
  init(data: NSData, range: Range<Int>) throws {
    let parser = try ShapeFilePolygonZRecordParser(data: data, start: range.startIndex)
    box = try parser.box.parse(data)
    parts = try parser.parts.parse(data).map(Int.init)
    points = try parser.points.parse(data)
    zBounds = try parser.zBounds.parse(data)
    zPoints = try parser.zPoints.parse(data)
    if range.endIndex > parser.mBounds.start {
      mBounds = try valueOrNilForOptionalValue(parser.mBounds.parse(data))
      mPoints = try parser.mPoints.parse(data).flatMap(valueOrNilForOptionalValue)
    } else {
      mBounds = nil
      mPoints = []
    }
  }
}

// MARK: Multipatch

struct ShapeFileMultiPatchRecordParser {
  let box: ShapeDataParser<LittleEndian<BoundingBoxXY>>
  let parts: ShapeDataArrayParser<LittleEndian<Int32>>
  let partTypes: ShapeDataArrayParser<LittleEndian<MultiPatchPartType>>
  let points: ShapeDataArrayParser<LittleEndian<Coordinate>>
  let zBounds: ShapeDataParser<LittleEndian<CoordinateBounds>>
  let zPoints: ShapeDataArrayParser<LittleEndian<Coordinate>>
  let mBounds: ShapeDataParser<LittleEndian<CoordinateBounds>>
  let mPoints: ShapeDataArrayParser<LittleEndian<Coordinate>>

  init(data: NSData, start: Int) throws {
    box = ShapeDataParser<LittleEndian<BoundingBoxXY>>(start: start)
    let numPartsParser = ShapeDataParser<LittleEndian<Int32>>(start: box.end)
    let numParts = try Int(numPartsParser.parse(data))
    let numPointsParser = ShapeDataParser<LittleEndian<Int32>>(start: numPartsParser.end)
    let numPoints = try Int(numPointsParser.parse(data))
    parts = ShapeDataArrayParser<LittleEndian<Int32>>(start: numPointsParser.end, count: numParts)
    partTypes = ShapeDataArrayParser<LittleEndian<MultiPatchPartType>>(start: parts.end, count: numParts)
    points = ShapeDataArrayParser<LittleEndian<Coordinate>>(start: partTypes.end, count: numPoints)
    zBounds = ShapeDataParser<LittleEndian<CoordinateBounds>>(start: points.end)
    zPoints = ShapeDataArrayParser<LittleEndian<Coordinate>>(start: zBounds.end, count: numPoints)
    mBounds = ShapeDataParser<LittleEndian<CoordinateBounds>>(start: zPoints.end)
    mPoints = ShapeDataArrayParser<LittleEndian<Coordinate>>(start: mBounds.end, count: numPoints)
  }
}

struct ShapeFileMultiPatchRecord: ShapeFileRecord {
  let box: BoundingBoxXY
  let parts: [Int]
  let partTypes: [MultiPatchPartType]
  let points: [Coordinate]
  let zBounds: CoordinateBounds
  let zPoints: [Coordinate]
  let mBounds: CoordinateBounds?
  let mPoints: [Coordinate]
  init(data: NSData, range: Range<Int>) throws {
    let parser = try ShapeFileMultiPatchRecordParser(data: data, start: range.startIndex)
    box = try parser.box.parse(data)
    parts = try parser.parts.parse(data).map(Int.init)
    partTypes = try parser.partTypes.parse(data)
    points = try parser.points.parse(data)
    zBounds = try parser.zBounds.parse(data)
    zPoints = try parser.zPoints.parse(data)
    if range.endIndex > parser.mBounds.start {
      mBounds = try valueOrNilForOptionalValue(parser.mBounds.parse(data))
      mPoints = try parser.mPoints.parse(data).flatMap(valueOrNilForOptionalValue)
    } else {
      mBounds = nil
      mPoints = []
    }
  }
}

