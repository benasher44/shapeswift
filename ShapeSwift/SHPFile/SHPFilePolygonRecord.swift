//
//  SHPFilePolygonRecord.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 6/2/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

// MARK: Parser

extension SHPFilePolygonRecord {
  struct Parser {
    let box: ShapeDataParser<LittleEndian<BoundingBoxXY>>
    let parts: ShapeDataArrayParser<LittleEndian<Int32>>
    let points: ShapeDataArrayParser<LittleEndian<Coordinate2D>>
    init(data: Data, start: Int) throws {
      box = ShapeDataParser<LittleEndian<BoundingBoxXY>>(start: start)
      let numPartsParser = ShapeDataParser<LittleEndian<Int32>>(start: box.end)
      let numParts = try Int(numPartsParser.parse(data))
      let numPointsParser = ShapeDataParser<LittleEndian<Int32>>(start: numPartsParser.end)
      let numPoints = try Int(numPointsParser.parse(data))
      parts = ShapeDataArrayParser<LittleEndian<Int32>>(start: numPointsParser.end, count: numParts)
      points = ShapeDataArrayParser<LittleEndian<Coordinate2D>>(start: parts.end, count: numPoints)
    }
  }
}

// MARK: Record

struct SHPFilePolygonRecord: SHPFileRecord {
  let box: BoundingBoxXY
  let parts: [Int32]
  let points: [Coordinate2D]
}

extension SHPFilePolygonRecord {
  init(data: Data, range: Range<Int>) throws {
    let parser = try Parser(data: data, start: range.lowerBound)
    box = try parser.box.parse(data)
    parts = try parser.parts.parse(data)
    points = try parser.points.parse(data)
  }
}

extension SHPFilePolygonRecord: ByteEncodable {
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

extension SHPFilePolygonRecord: Equatable {}

func ==(lhs: SHPFilePolygonRecord, rhs: SHPFilePolygonRecord) -> Bool {
  return lhs.box == rhs.box && lhs.points == rhs.points && lhs.parts == rhs.parts
}
