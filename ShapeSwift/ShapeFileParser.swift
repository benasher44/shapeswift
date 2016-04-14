//
//  ShapeFileParser.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 3/30/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import Foundation

struct ShapeDataDefinition<T: ByteParseable> {
  let range: Range<Int>
  let endianness: Endianness
  func parse(data: NSData) throws -> T? {
    return T(data: data, range: range, endianness: endianness)
  }
}

struct BoundingBox {
  let x: CoordinateBounds
  let y: CoordinateBounds
  let z: CoordinateBounds
  let m: CoordinateBounds
}

struct CoordinateBounds {
  let min: Double
  let max: Double
}

enum ShapeType: Int {
  case NullShape = 0
  case Point = 1
  case PolyLine = 3
  case Polygon = 5
  case MultiPoint = 8
  case PointZ = 11
  case PolyLineZ = 13
  case PolygonZ = 15
  case MultiPointZ = 18
  case PointM = 21
  case PolyLineM = 23
  case PolygonM = 25
  case MultiPointM = 28
  case MultiPatch = 31
}

extension ShapeType: ByteParseable {
  init?(data: NSData, range: Range<Int>, endianness: Endianness) {
    if let shapeType = ShapeType(rawValue: Int(Int32(data: data, range: range, endianness: endianness))) {
      self = shapeType
    } else {
      return nil
    }
  }
}

extension BoundingBox: ByteParseable {
  init(data: NSData, range: Range<Int>, endianness: Endianness) {
    let byteRange = (range.startIndex)..<(range.startIndex + 8)
    self = BoundingBox(x: CoordinateBounds(min: Double(data: data, range: byteRange, endianness: endianness),
                                           max: Double(data: data, range: byteRange.shifted(16), endianness: endianness)),
                       y: CoordinateBounds(min: Double(data: data, range: byteRange.shifted(8), endianness: endianness),
                                           max: Double(data: data, range: byteRange.shifted(24), endianness: endianness)),
                       z: CoordinateBounds(min: Double(data: data, range: byteRange.shifted(32), endianness: endianness),
                                           max: Double(data: data, range: byteRange.shifted(40), endianness: endianness)),
                       m: CoordinateBounds(min: Double(data: data, range: byteRange.shifted(48), endianness: endianness),
                                           max: Double(data: data, range: byteRange.shifted(56), endianness: endianness)))
  }
}

private let headerRange = NSRange(location: 0, length: 100)

struct ShapeFileHeaderDefinition {
  let fileCode = ShapeDataDefinition<Int32>(range: 0..<4, endianness: .Big)
  let fileLength = ShapeDataDefinition<Int32>(range: 24..<28, endianness: .Big)
  let version = ShapeDataDefinition<Int32>(range: 28..<32, endianness: .Little)
  let shapeType = ShapeDataDefinition<ShapeType>(range: 32..<36, endianness: .Little)
  let boundingBox = ShapeDataDefinition<BoundingBox>(range: 36..<100, endianness: .Little)
}

struct ShapeFileHeader {
  let fileCode: Int
  let fileLength: Int
  let version: Int
  let shapeType: ShapeType
  let boundingBox: BoundingBox
  init?(data: NSData) throws {
    let def = ShapeFileHeaderDefinition()
    fileCode = try Int(def.fileCode.parse(data)!)
    fileLength = try Int(def.fileLength.parse(data)!)
    version = try Int(def.version.parse(data)!)
    shapeType = try def.shapeType.parse(data)!
    boundingBox = try def.boundingBox.parse(data)!
  }
}

public func parseFromURL(fileURL: NSURL) throws -> Void {
  let data = try NSData(contentsOfURL: fileURL, options: .DataReadingMappedIfSafe)
  let header = try ShapeFileHeader(data: data)
}