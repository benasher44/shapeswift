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

struct ShapeFilePointRecordParser {
  let point: ShapeDataParser<LittleEndian<Coordinate>>

  init(start: Int) {
    point = ShapeDataParser<LittleEndian<Coordinate>>(range: start..<(start + 16))
  }
}

struct ShapeFilePointRecord: ShapeFileRecord {
  let point: Coordinate

  init?(data: NSData, start: Int) throws {
    let parser = ShapeFilePointRecordParser(start: start)
    point = try parser.point.parse(data)!
  }
}

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

