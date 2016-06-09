//
//  SHPFileRecord.swift
//  ShapeSwift
//
//  Created by Ben Asher on 4/29/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import Foundation

private let noDataValue: Double = -pow(10, 38)

func valueOrNilForOptionalValue(value: Coordinate2DBounds) -> Coordinate2DBounds? {
  if value.min < noDataValue || value.max < noDataValue {
    return nil
  } else {
    return value
  }
}

func valueOrNilForOptionalValue(value: Coordinate2D) -> Coordinate2D? {
  if value.x < noDataValue || value.x < noDataValue {
    return nil
  } else {
    return value
  }
}

func valueOrNilForOptionalValue(value: Double) -> Double? {
  if value < noDataValue || value < noDataValue {
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

// MARK: PolyLineM

struct ShapeFilePolyLineMRecordParser {
  let box: ShapeDataParser<LittleEndian<BoundingBoxXY>>
  let parts: ShapeDataArrayParser<LittleEndian<Int32>>
  let points: ShapeDataArrayParser<LittleEndian<Coordinate2D>>
  let mBounds: ShapeDataParser<LittleEndian<Coordinate2DBounds>>
  let mPoints: ShapeDataArrayParser<LittleEndian<Coordinate2D>>
  init(data: NSData, start: Int) throws {
    box = ShapeDataParser<LittleEndian<BoundingBoxXY>>(start: start)
    let numPartsParser = ShapeDataParser<LittleEndian<Int32>>(start: box.end)
    let numParts = try Int(numPartsParser.parse(data))
    let numPointsParser = ShapeDataParser<LittleEndian<Int32>>(start: numPartsParser.end)
    let numPoints = try Int(numPointsParser.parse(data))
    parts = ShapeDataArrayParser<LittleEndian<Int32>>(start: numPointsParser.end, count: numParts)
    points = ShapeDataArrayParser<LittleEndian<Coordinate2D>>(start: parts.end, count: numPoints)
    mBounds = ShapeDataParser<LittleEndian<Coordinate2DBounds>>(start: points.end)
    mPoints = ShapeDataArrayParser<LittleEndian<Coordinate2D>>(start: mBounds.end, count: numPoints)
  }
}

struct ShapeFilePolyLineMRecord: ShapeFileRecord {
  let box: BoundingBoxXY
  let parts: [Int]
  let points: [Coordinate2D]
  let mBounds: Coordinate2DBounds?
  let mPoints: [Coordinate2D]
  init(data: NSData, range: Range<Int>) throws {
    let parser = try ShapeFilePolyLineMRecordParser(data: data, start: range.startIndex)
    box = try parser.box.parse(data)
    parts = try parser.parts.parse(data).map(Int.init)
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

// MARK: PointZ

struct ShapeFilePointZRecordParser {
  let x: ShapeDataParser<LittleEndian<Double>>
  let y: ShapeDataParser<LittleEndian<Double>>
  let z: ShapeDataParser<LittleEndian<Double>>
  let m: ShapeDataParser<LittleEndian<Double>>
  init(start: Int) {
    x = ShapeDataParser<LittleEndian<Double>>(start: start)
    y = ShapeDataParser<LittleEndian<Double>>(start: x.end)
    z = ShapeDataParser<LittleEndian<Double>>(start: y.end)
    m = ShapeDataParser<LittleEndian<Double>>(start: z.end)
  }
}

struct ShapeFilePointZRecord: ShapeFileRecord {
  let x: Double
  let y: Double
  let z: Double
  let m: Double
  init(data: NSData, range: Range<Int>) throws {
    let parser = ShapeFilePointZRecordParser(start: range.startIndex)
    x = try parser.x.parse(data)
    y = try parser.y.parse(data)
    z = try parser.z.parse(data)
    m = try parser.m.parse(data)
  }
}

// MARK: MultiPointZ

struct ShapeFileMultiPointZRecordParser {
  let box: ShapeDataParser<LittleEndian<BoundingBoxXY>>
  let points: ShapeDataArrayParser<LittleEndian<Coordinate2D>>
  let zBounds: ShapeDataParser<LittleEndian<Coordinate2DBounds>>
  let zPoints: ShapeDataArrayParser<LittleEndian<Coordinate2D>>
  let mBounds: ShapeDataParser<LittleEndian<Coordinate2DBounds>>
  let mPoints: ShapeDataArrayParser<LittleEndian<Coordinate2D>>
  init(data: NSData, start: Int) throws {
    box = ShapeDataParser<LittleEndian<BoundingBoxXY>>(start: start)
    let numPointsParser = ShapeDataParser<LittleEndian<Int32>>(start: box.end)
    let numPoints = try Int(numPointsParser.parse(data))
    points = ShapeDataArrayParser<LittleEndian<Coordinate2D>>(start: numPointsParser.end, count: numPoints)
    zBounds = ShapeDataParser<LittleEndian<Coordinate2DBounds>>(start: points.end)
    zPoints = ShapeDataArrayParser<LittleEndian<Coordinate2D>>(start: zBounds.end, count: numPoints)
    mBounds = ShapeDataParser<LittleEndian<Coordinate2DBounds>>(start: zPoints.end)
    mPoints = ShapeDataArrayParser<LittleEndian<Coordinate2D>>(start: mBounds.end, count: numPoints)
  }
}

struct ShapeFileMultiPointZRecord: ShapeFileRecord {
  let box: BoundingBoxXY
  let points: [Coordinate2D]
  let zBounds: Coordinate2DBounds
  let zPoints: [Coordinate2D]
  let mBounds: Coordinate2DBounds?
  let mPoints: [Coordinate2D]
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
  let points: ShapeDataArrayParser<LittleEndian<Coordinate2D>>
  let zBounds: ShapeDataParser<LittleEndian<Coordinate2DBounds>>
  let zPoints: ShapeDataArrayParser<LittleEndian<Coordinate2D>>
  let mBounds: ShapeDataParser<LittleEndian<Coordinate2DBounds>>
  let mPoints: ShapeDataArrayParser<LittleEndian<Coordinate2D>>
  init(data: NSData, start: Int) throws {
    box = ShapeDataParser<LittleEndian<BoundingBoxXY>>(start: start)
    let numPartsParser = ShapeDataParser<LittleEndian<Int32>>(start: box.end)
    let numParts = try Int(numPartsParser.parse(data))
    let numPointsParser = ShapeDataParser<LittleEndian<Int32>>(start: numPartsParser.end)
    let numPoints = try Int(numPointsParser.parse(data))
    parts = ShapeDataArrayParser<LittleEndian<Int32>>(start: numPointsParser.end, count: numParts)
    points = ShapeDataArrayParser<LittleEndian<Coordinate2D>>(start: parts.end, count: numPoints)
    zBounds = ShapeDataParser<LittleEndian<Coordinate2DBounds>>(start: points.end)
    zPoints = ShapeDataArrayParser<LittleEndian<Coordinate2D>>(start: zBounds.end, count: numPoints)
    mBounds = ShapeDataParser<LittleEndian<Coordinate2DBounds>>(start: zPoints.end)
    mPoints = ShapeDataArrayParser<LittleEndian<Coordinate2D>>(start: mBounds.end, count: numPoints)
  }
}

struct ShapeFilePolyLineZRecord: ShapeFileRecord {
  let box: BoundingBoxXY
  let parts: [Int]
  let points: [Coordinate2D]
  let zBounds: Coordinate2DBounds
  let zPoints: [Coordinate2D]
  let mBounds: Coordinate2DBounds?
  let mPoints: [Coordinate2D]
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
  let points: ShapeDataArrayParser<LittleEndian<Coordinate2D>>
  let zBounds: ShapeDataParser<LittleEndian<Coordinate2DBounds>>
  let zPoints: ShapeDataArrayParser<LittleEndian<Coordinate2D>>
  let mBounds: ShapeDataParser<LittleEndian<Coordinate2DBounds>>
  let mPoints: ShapeDataArrayParser<LittleEndian<Coordinate2D>>
  init(data: NSData, start: Int) throws {
    box = ShapeDataParser<LittleEndian<BoundingBoxXY>>(start: start)
    let numPartsParser = ShapeDataParser<LittleEndian<Int32>>(start: box.end)
    let numParts = try Int(numPartsParser.parse(data))
    let numPointsParser = ShapeDataParser<LittleEndian<Int32>>(start: numPartsParser.end)
    let numPoints = try Int(numPointsParser.parse(data))
    parts = ShapeDataArrayParser<LittleEndian<Int32>>(start: numPointsParser.end, count: numParts)
    points = ShapeDataArrayParser<LittleEndian<Coordinate2D>>(start: parts.end, count: numPoints)
    zBounds = ShapeDataParser<LittleEndian<Coordinate2DBounds>>(start: points.end)
    zPoints = ShapeDataArrayParser<LittleEndian<Coordinate2D>>(start: zBounds.end, count: numPoints)
    mBounds = ShapeDataParser<LittleEndian<Coordinate2DBounds>>(start: zPoints.end)
    mPoints = ShapeDataArrayParser<LittleEndian<Coordinate2D>>(start: mBounds.end, count: numPoints)
  }
}

struct ShapeFilePolygonZRecord: ShapeFileRecord {
  let box: BoundingBoxXY
  let parts: [Int]
  let points: [Coordinate2D]
  let zBounds: Coordinate2DBounds
  let zPoints: [Coordinate2D]
  let mBounds: Coordinate2DBounds?
  let mPoints: [Coordinate2D]
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
  let points: ShapeDataArrayParser<LittleEndian<Coordinate2D>>
  let zBounds: ShapeDataParser<LittleEndian<Coordinate2DBounds>>
  let zPoints: ShapeDataArrayParser<LittleEndian<Coordinate2D>>
  let mBounds: ShapeDataParser<LittleEndian<Coordinate2DBounds>>
  let mPoints: ShapeDataArrayParser<LittleEndian<Coordinate2D>>

  init(data: NSData, start: Int) throws {
    box = ShapeDataParser<LittleEndian<BoundingBoxXY>>(start: start)
    let numPartsParser = ShapeDataParser<LittleEndian<Int32>>(start: box.end)
    let numParts = try Int(numPartsParser.parse(data))
    let numPointsParser = ShapeDataParser<LittleEndian<Int32>>(start: numPartsParser.end)
    let numPoints = try Int(numPointsParser.parse(data))
    parts = ShapeDataArrayParser<LittleEndian<Int32>>(start: numPointsParser.end, count: numParts)
    partTypes = ShapeDataArrayParser<LittleEndian<MultiPatchPartType>>(start: parts.end, count: numParts)
    points = ShapeDataArrayParser<LittleEndian<Coordinate2D>>(start: partTypes.end, count: numPoints)
    zBounds = ShapeDataParser<LittleEndian<Coordinate2DBounds>>(start: points.end)
    zPoints = ShapeDataArrayParser<LittleEndian<Coordinate2D>>(start: zBounds.end, count: numPoints)
    mBounds = ShapeDataParser<LittleEndian<Coordinate2DBounds>>(start: zPoints.end)
    mPoints = ShapeDataArrayParser<LittleEndian<Coordinate2D>>(start: mBounds.end, count: numPoints)
  }
}

struct ShapeFileMultiPatchRecord: ShapeFileRecord {
  let box: BoundingBoxXY
  let parts: [Int]
  let partTypes: [MultiPatchPartType]
  let points: [Coordinate2D]
  let zBounds: Coordinate2DBounds
  let zPoints: [Coordinate2D]
  let mBounds: Coordinate2DBounds?
  let mPoints: [Coordinate2D]
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

