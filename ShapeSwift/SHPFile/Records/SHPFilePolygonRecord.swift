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

struct SHPFilePolygonRecord {
  let recordNumber: Int
  let box: BoundingBoxXY
  let parts: [Int]
  let points: [Coordinate2D]
}

extension SHPFilePolygonRecord: SHPFileRecord {
  static let shapeType = ShapeType.polygon

  init(recordNumber: Int, data: Data, range: Range<Int>, endByte: inout Int) throws {
    self.recordNumber = recordNumber
    let parser = try Parser(data: data, start: range.lowerBound)
    box = try parser.box.parse(data)
    parts = try parser.parts.parse(data).map(Int.init)
    points = try parser.points.parse(data)
    endByte = parser.points.end - 1
  }
}

// MARK: Equatable

extension SHPFilePolygonRecord: Equatable {}

func == (lhs: SHPFilePolygonRecord, rhs: SHPFilePolygonRecord) -> Bool {
  return (
    lhs.recordNumber == rhs.recordNumber &&
      lhs.box == rhs.box &&
      lhs.points == rhs.points &&
      lhs.parts == rhs.parts
  )
}
