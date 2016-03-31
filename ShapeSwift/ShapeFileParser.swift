//
//  ShapeFileParser.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 3/30/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import Foundation

private let headerRange = NSRange(location: 0, length: 100)

struct BoundingBox {
  let xMin: Double
  let xMax: Double
  let yMin: Double
  let yMax: Double
  let zMin: Double
  let zMax: Double
  let mMin: Double
  let mMax: Double
}

enum ShapeType {
  case NullShape
  case Point
  case PolyLine
  case Polygon
  case MultiPoint
  case PointZ
  case PolyLineZ
  case PolygonZ
  case MultiPointZ
  case PointM
  case PolyLineM
  case PolygonM
  case MultiPointM
  case MultiPatch
  case Unknown
}

extension ShapeType: IntegerLiteralConvertible {
  init(integerLiteral value: Int) {
    switch (value) {
    case 0:
      self = .NullShape
    case 1:
      self = .Point
    case 3:
      self = .PolyLine
    case 5:
      self = .Polygon
    case 8:
      self = .MultiPoint
    case 11:
      self = .PointZ
    case 13:
      self = .PolyLineZ
    case 15:
      self = .PolygonZ
    case 18:
      self = .MultiPointZ
    case 21:
      self = .PointZ
    case 23:
      self = .PolyLineZ
    case 25:
      self = .PolygonZ
    case 28:
      self = .MultiPointZ
    case 31:
      self = .MultiPatch
    default:
      self = .Unknown
    }
  }
}

struct ShapeFileHeader {
  let fileCode: Int
  let fileLength: Int
  let version: Int
  let shapeType: ShapeType
  let boundingBox: BoundingBox
}

func parseInt(data: NSData, location: Int, bigEndian: Bool) -> Int {
  var rawInt: Int32 = 0
  data.getBytes(&rawInt, range: NSRange(location: location, length: 4))
  if bigEndian {
    return Int(Int32(bigEndian: rawInt))
  } else {
    return Int(Int32(littleEndian: rawInt))
  }
}

func parseDouble(data: NSData, location: Int) -> Double {
  var rawDouble: Int64 = 0
  data.getBytes(&rawDouble, range: NSRange(location: location, length: 8))
  return unsafeBitCast(Int64(littleEndian: rawDouble), Double.self)
}

func parseHeader(data: NSData) {
  let fileCode = parseInt(data, location: headerRange.location, bigEndian: true)
  let fileLength = parseInt(data, location: headerRange.location + 24, bigEndian: true)
  let version = parseInt(data, location: headerRange.location + 28, bigEndian: false)
  let shapeType = ShapeType(integerLiteral: parseInt(data, location: headerRange.location + 32, bigEndian: false))
  let xMin = parseDouble(data, location: headerRange.location + 36)
  let xMax = parseDouble(data, location: headerRange.location + 52)
}

public func parseFromURL(fileURL: NSURL) throws -> Void {
  let data = try NSData(contentsOfURL: fileURL, options: .DataReadingMappedIfSafe)
  parseHeader(data)
}