//
//  SHPFileRecord.swift
//  ShapeSwift
//
//  Created by Ben Asher on 4/29/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

private let noDataValue: Double = -pow(10, 38)

func valueOrNilForOptionalValue(_ value: Coordinate2DBounds) -> Coordinate2DBounds? {
  if value.min < noDataValue || value.max < noDataValue {
    return nil
  } else {
    return value
  }
}

//TODO: remove
func valueOrNilForOptionalValue(_ value: Coordinate2D) -> Coordinate2D? {
  if value.x < noDataValue || value.x < noDataValue {
    return nil
  } else {
    return value
  }
}

// TODO(noah): rename this function
func valueOrNilForOptionalValue(_ value: Double) -> Double? {
  if value == noDataValue {
    return nil
  } else {
    return value
  }
}

func valueOrNoDataValueForOptionalValue(_ value: Double?) -> Double {
  if let value = value {
    return value
  }
  return noDataValue
}

protocol ShapeFileRecord {
  init(data: Data, range: Range<Int>) throws
}

extension ShapeFileRecord {
  static func recordForShapeType(_ shapeType: ShapeType, data: Data, range: Range<Int>) throws -> ShapeFileRecord? {
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

// MARK: Multipatch

extension ShapeFileMultiPatchRecord {
  struct Parser {
    let box: ShapeDataParser<LittleEndian<BoundingBoxXY>>
    let parts: ShapeDataArrayParser<LittleEndian<Int32>>
    let partTypes: ShapeDataArrayParser<LittleEndian<MultiPatchPartType>>
    let points: ShapeDataArrayParser<LittleEndian<Coordinate2D>>
    let zBounds: ShapeDataParser<LittleEndian<Coordinate2DBounds>>
    let zPoints: ShapeDataArrayParser<LittleEndian<Coordinate2D>>
    let mBounds: ShapeDataParser<LittleEndian<Coordinate2DBounds>>
    let mPoints: ShapeDataArrayParser<LittleEndian<Coordinate2D>>

    init(data: Data, start: Int) throws {
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
  init(data: Data, range: Range<Int>) throws {
    let parser = try Parser(data: data, start: range.lowerBound)
    box = try parser.box.parse(data)
    parts = try parser.parts.parse(data).map(Int.init)
    partTypes = try parser.partTypes.parse(data)
    points = try parser.points.parse(data)
    zBounds = try parser.zBounds.parse(data)
    zPoints = try parser.zPoints.parse(data)
    if range.upperBound > parser.mBounds.start {
      mBounds = try valueOrNilForOptionalValue(parser.mBounds.parse(data))
      mPoints = try parser.mPoints.parse(data).flatMap(valueOrNilForOptionalValue)
    } else {
      mBounds = nil
      mPoints = []
    }
  }
}

