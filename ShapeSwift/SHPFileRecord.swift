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
  let x: ShapeDataParser<LittleEndian<Double>>
  let y: ShapeDataParser<LittleEndian<Double>>

  init(start: Int) {
    x = ShapeDataParser<LittleEndian<Double>>(range: start..<(start + 8))
    y = ShapeDataParser<LittleEndian<Double>>(range: (start + 8)..<(start + 16))
  }
}

struct ShapeFilePointRecord: ShapeFileRecord {
  let x: Double
  let y: Double

  init?(data: NSData, start: Int) throws {
    let parser = ShapeFilePointRecordParser(start: start)
    x = try parser.x.parse(data)!
    y = try parser.y.parse(data)!
  }
}

struct ShapeFileMultiPatchRecordParser {
  let box: ShapeDataParser<LittleEndian<BoundingBoxXY>>
  let numParts: ShapeDataParser<LittleEndian<Int32>>
  let numPoints: ShapeDataParser<LittleEndian<Int32>>
}

struct ShapeFileMultiPatchRecord: ShapeFileRecord {
  init?(data: NSData, start: Int) throws {

  }
}