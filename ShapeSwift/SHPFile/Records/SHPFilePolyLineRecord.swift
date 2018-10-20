//
//  SHPFilePolyLineRecord.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 6/2/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

// MARK: Parser

extension SHPFilePolyLineRecord {
  struct Parser {
    let box: ShapeDataParser<BoundingBoxXY, LittleEndian>
    let points: ShapeDataArrayParser<Coordinate2D, LittleEndian>
    let parts: ShapeDataArrayParser<Int32, LittleEndian>
    init(data: Data, start: Int) throws {
      box = ShapeDataParser<BoundingBoxXY, LittleEndian>(start: start)
      let numPartsParser = ShapeDataParser<Int32, LittleEndian>(start: box.end)
      let numPointsParser = ShapeDataParser<Int32, LittleEndian>(start: numPartsParser.end)
      let numPoints = try Int(numPointsParser.parse(data))
      let numParts = try Int(numPartsParser.parse(data))
      parts = ShapeDataArrayParser<Int32, LittleEndian>(start: numPointsParser.end, count: numParts)
      points = ShapeDataArrayParser<Coordinate2D, LittleEndian>(start: parts.end, count: numPoints)
    }
  }
}

// MARK: Record

struct SHPFilePolyLineRecord: Equatable {
  let recordNumber: Int
  let box: BoundingBoxXY
  let parts: [Int]
  let points: [Coordinate2D]
}

extension SHPFilePolyLineRecord: SHPFileRecord {
  static let shapeType = ShapeType.polyLine

  init(recordNumber: Int, data: Data, range: Range<Int>, endByte: inout Int) throws {
    self.recordNumber = recordNumber
    let parser = try Parser(data: data, start: range.lowerBound)
    box = try parser.box.parse(data)
    parts = try parser.parts.parse(data).map(Int.init)
    points = try parser.points.parse(data)
    endByte = parser.points.end - 1
  }
}
