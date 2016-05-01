//
//  ShapeFileRecord.swift
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

struct ShapeFilePointRecordDefinition {
  let x: ShapeDataDefinition<LittleEndian<Double>>
  let y: ShapeDataDefinition<LittleEndian<Double>>

  init(start: Int) {
    x = ShapeDataDefinition<LittleEndian<Double>>(range: start..<(start + 8))
    y = ShapeDataDefinition<LittleEndian<Double>>(range: (start + 8)..<(start + 16))
  }
}

struct ShapeFilePointRecord: ShapeFileRecord {
  let x: Double
  let y: Double

  init?(data: NSData, start: Int) throws {
    let def = ShapeFilePointRecordDefinition(start: start)
    x = try def.x.parse(data)!
    y = try def.y.parse(data)!
  }
}

struct ShapeFileMultiPatchRecordDefinition {
  let box: ShapeDataDefinition<LittleEndian<BoundingBoxXY>>
  let numParts: ShapeDataDefinition<LittleEndian<Int32>>
  let numPoints: ShapeDataDefinition<LittleEndian<Int32>>
}

struct ShapeFileMultiPatchRecord: ShapeFileRecord {
  init?(data: NSData, start: Int) throws {

  }
}