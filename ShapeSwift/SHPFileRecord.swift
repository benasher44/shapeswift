//
//  SHPFileRecord.swift
//  ShapeSwift
//
//  Created by Ben Asher on 4/29/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import Foundation

protocol ShapeFileRecord {
  init?(data: NSData, start: Int) throws
}

extension ShapeFileRecord {
  static func recordForShapeType(shapeType: ShapeType, data: NSData, start: Int) throws -> ShapeFileRecord? {
    var type: ShapeFileRecord.Type
    switch shapeType {
    case .point:
      type = ShapeFilePointRecord.self
    default:
      return nil
    }
    return try type.init(data: data, start: start)
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

  init?(data: NSData, start: Int) throws {
    let parser = ShapeFilePointRecordParser(start: start)
    point = try parser.point.parse(data)!
  }
}

// MARK: MultiPoint

struct ShapeFileMultiPointRecordParser {
  let box: ShapeDataParser<LittleEndian<BoundingBoxXY>>
  let points: ShapeDataArrayParser<LittleEndian<Coordinate>>

  init?(data: NSData, start: Int) throws {
    box = ShapeDataParser<LittleEndian<BoundingBoxXY>>(start: start)
    let numPoints = try Int(ShapeDataParser<LittleEndian<Int32>>(start: box.end).parse(data)!)
    points = ShapeDataArrayParser<LittleEndian<Coordinate>>(start: start + BoundingBoxXY.sizeBytes + Int32.sizeBytes, count: numPoints)
  }
}

struct ShapeFileMultiPointRecord: ShapeFileRecord {
  let box: BoundingBoxXY
  let points: [Coordinate]

  init?(data: NSData, start: Int) throws {
    let parser = try ShapeFileMultiPointRecordParser(data: data, start: start)!
    box = try parser.box.parse(data)!
    points = try parser.points.parse(data)!
  }
}

// MARK: Multipatch

struct ShapeFileMultiPatchRecordParser {
  let box: ShapeDataParser<LittleEndian<BoundingBoxXY>>
  let numParts: ShapeDataParser<LittleEndian<Int32>>
  let numPoints: ShapeDataParser<LittleEndian<Int32>>
  let parts: ShapeDataArrayParser<LittleEndian<MultiPatchPartType>>
}

struct ShapeFileMultiPatchRecord: ShapeFileRecord {
  init?(data: NSData, start: Int) throws {

  }
}

