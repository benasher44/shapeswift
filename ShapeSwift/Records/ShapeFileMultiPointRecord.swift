//
//  ShapeFileMultiPointRecord.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 6/2/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import Foundation

// MARK: Parser

struct ShapeFileMultiPointRecordParser {
  let box: ShapeDataParser<LittleEndian<BoundingBoxXY>>
  let points: ShapeDataArrayParser<LittleEndian<Coordinate2D>>

  init(data: NSData, start: Int) throws {
    box = ShapeDataParser<LittleEndian<BoundingBoxXY>>(start: start)
    let numPointsParser = ShapeDataParser<LittleEndian<Int32>>(start: box.end)
    let numPoints = try Int(numPointsParser.parse(data))
    points = ShapeDataArrayParser<LittleEndian<Coordinate2D>>(start: numPointsParser.end, count: numPoints)
  }
}

// MARK: Record

struct ShapeFileMultiPointRecord {
  let box: BoundingBoxXY
  let points: [Coordinate2D]
}

extension ShapeFileMultiPointRecord: ShapeFileRecord {
  init(data: NSData, range: Range<Int>) throws {
    let parser = try ShapeFileMultiPointRecordParser(data: data, start: range.startIndex)
    box = try parser.box.parse(data)
    points = try parser.points.parse(data)
  }
}

extension ShapeFileMultiPointRecord: ByteEncodable {
  func encode() -> [Byte] {
    var bytes = Array([
      LittleEndianEncoded<ShapeType>(value: .multiPoint).encode(),
      box.encode(),
      LittleEndianEncoded<Int32>(value: Int32(points.count)).encode()
      ].flatten())
    bytes.appendContentsOf(points.flatMap({ $0.encode() }))
    return bytes
  }
}

// MARK: Equatable

extension ShapeFileMultiPointRecord: Equatable {}

func ==(lhs: ShapeFileMultiPointRecord, rhs: ShapeFileMultiPointRecord) -> Bool {
  return lhs.box == rhs.box && lhs.points == rhs.points
}
