//
//  SHPFileMultiPointRecord.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 6/2/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

// MARK: Parser

extension SHPFileMultiPointRecord {
  struct Parser {
    let box: ShapeDataParser<LittleEndian<BoundingBoxXY>>
    let points: ShapeDataArrayParser<LittleEndian<Coordinate2D>>

    init(data: Data, start: Int) throws {
      box = ShapeDataParser<LittleEndian<BoundingBoxXY>>(start: start)
      let numPointsParser = ShapeDataParser<LittleEndian<Int32>>(start: box.end)
      let numPoints = try Int(numPointsParser.parse(data))
      points = ShapeDataArrayParser<LittleEndian<Coordinate2D>>(start: numPointsParser.end, count: numPoints)
    }
  }
}

// MARK: Record

struct SHPFileMultiPointRecord {
  let box: BoundingBoxXY
  let points: [Coordinate2D]
}

extension SHPFileMultiPointRecord: SHPFileRecord {
  static let shapeType = ShapeType.multiPoint

  init(data: Data, range: Range<Int>, endByte: inout Int) throws {
    let parser = try Parser(data: data, start: range.lowerBound)
    box = try parser.box.parse(data)
    points = try parser.points.parse(data)
    endByte = parser.points.end - 1
  }
}

extension SHPFileMultiPointRecord: ByteEncodable {
  func encode() -> [Byte] {
    let byteEncodables: [[ByteEncodable]] = [[
      LittleEndianEncoded<ShapeType>(value: .multiPoint),
      box,
      LittleEndianEncoded<Int32>(value: Int32(points.count)),
    ], points.map({$0 as ByteEncodable})]
    return makeByteArray(from: byteEncodables.flatten())
  }
}

// MARK: Equatable

extension SHPFileMultiPointRecord: Equatable {}

func == (lhs: SHPFileMultiPointRecord, rhs: SHPFileMultiPointRecord) -> Bool {
  return lhs.box == rhs.box && lhs.points == rhs.points
}
