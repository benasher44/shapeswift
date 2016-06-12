//
//  ShapeFilePolyLineRecord.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 6/2/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import Foundation

// MARK: Parser

extension ShapeFilePolyLineRecord {
  struct Parser {
    let box: ShapeDataParser<LittleEndian<BoundingBoxXY>>
    let points: ShapeDataArrayParser<LittleEndian<Coordinate2D>>
    let parts: ShapeDataArrayParser<LittleEndian<Int32>>
    init(data: NSData, start: Int) throws {
      box = ShapeDataParser<LittleEndian<BoundingBoxXY>>(start: start)
      let numPartsParser = ShapeDataParser<LittleEndian<Int32>>(start: box.end)
      let numPointsParser = ShapeDataParser<LittleEndian<Int32>>(start: numPartsParser.end)
      let numPoints = try Int(numPointsParser.parse(data))
      let numParts = try Int(numPartsParser.parse(data))
      parts = ShapeDataArrayParser<LittleEndian<Int32>>(start: numPointsParser.end, count: numParts)
      points = ShapeDataArrayParser<LittleEndian<Coordinate2D>>(start: parts.end, count: numPoints)
    }
  }
}

// MARK: Record

/// todo: Because this specification does not forbid consecutive points with identical coordinates,
/// shapefile readers must handle such cases. On the other hand, the degenerate, zero length
/// parts that might result are not allowed.
struct ShapeFilePolyLineRecord: ShapeFileRecord {
  let box: BoundingBoxXY
  let points: [Coordinate2D]
  let parts: [Int32]
}

extension ShapeFilePolyLineRecord {
  init(data: NSData, range: Range<Int>) throws {
    let parser = try Parser(data: data, start: range.startIndex)
    box = try parser.box.parse(data)
    points = try parser.points.parse(data)
    parts = try parser.parts.parse(data)
  }
}

extension ShapeFilePolyLineRecord: ByteEncodable {
  func encode() -> [Byte] {
    let byteEncodables = [[
      LittleEndianEncoded<ShapeType>(value: .polyLine),
      box,
      LittleEndianEncoded<Int32>(value: Int32(parts.count)),
      LittleEndianEncoded<Int32>(value: Int32(points.count))
      ], parts.map({ LittleEndianEncoded<Int32>(value: $0) as ByteEncodable }), points.map({$0 as ByteEncodable})]
    return makeByteArray(from: byteEncodables.flatten())
  }
}

// MARK: Equatable

extension ShapeFilePolyLineRecord: Equatable {}

func ==(lhs: ShapeFilePolyLineRecord, rhs: ShapeFilePolyLineRecord) -> Bool {
  return lhs.box == rhs.box && lhs.points == rhs.points && lhs.parts == rhs.parts
}
