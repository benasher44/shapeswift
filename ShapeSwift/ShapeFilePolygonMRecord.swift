//
//  ShapeFilePolygonMRecord.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 6/9/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

// MARK: Parser

struct ShapeFilePolygonMRecordParser {
  let box: ShapeDataParser<LittleEndian<BoundingBoxXY>>
  let parts: ShapeDataArrayParser<LittleEndian<Int32>>
  let points: ShapeDataArrayParser<LittleEndian<Coordinate2D>>
  let mBounds: ShapeDataParser<LittleEndian<Coordinate2DBounds>>
  let measures: ShapeDataArrayParser<LittleEndian<Double>>
  init(data: NSData, start: Int) throws {
    box = ShapeDataParser<LittleEndian<BoundingBoxXY>>(start: start)
    let numPartsParser = ShapeDataParser<LittleEndian<Int32>>(start: box.end)
    let numParts = try Int(numPartsParser.parse(data))
    let numPointsParser = ShapeDataParser<LittleEndian<Int32>>(start: numPartsParser.end)
    let numPoints = try Int(numPointsParser.parse(data))
    parts = ShapeDataArrayParser<LittleEndian<Int32>>(start: numPointsParser.end, count: numParts)
    points = ShapeDataArrayParser<LittleEndian<Coordinate2D>>(start: parts.end, count: numPoints)
    mBounds = ShapeDataParser<LittleEndian<Coordinate2DBounds>>(start: points.end)
    measures = ShapeDataArrayParser<LittleEndian<Double>>(start: mBounds.end, count: numPoints)
  }
}

// MARK: Record

struct ShapeFilePolygonMRecord: ShapeFileRecord {
  let box: BoundingBoxXY
  let parts: [Int]
  let points: [Coordinate2D]
  let mBounds: Coordinate2DBounds?
  let measures: [Double]
}

extension ShapeFilePolygonMRecord {
  init(data: NSData, range: Range<Int>) throws {
    let parser = try ShapeFilePolygonMRecordParser(data: data, start: range.startIndex)
    box = try parser.box.parse(data)
    parts = try parser.parts.parse(data).map(Int.init)
    points = try parser.points.parse(data)
    if range.endIndex > parser.mBounds.start {
      mBounds = try valueOrNilForOptionalValue(parser.mBounds.parse(data))
      measures = try parser.measures.parse(data).flatMap(valueOrNilForOptionalValue)
    } else {
      mBounds = nil
      measures = []
    }
  }
}

extension ShapeFilePolygonMRecord: ByteEncodable {
  func encode() -> [Byte] {
    var byteEncodables: [[ByteEncodable]] = [
      [
        LittleEndianEncoded<ShapeType>(value: .polygonM),
        box,
        LittleEndianEncoded<Int32>(value: Int32(parts.count)),
        LittleEndianEncoded<Int32>(value: Int32(points.count))
      ],
      parts.map({ LittleEndianEncoded<Int32>(value: Int32($0)) as ByteEncodable }),
      points.map({$0 as ByteEncodable})
    ]

    if let mBounds = mBounds {
      byteEncodables.append([
        LittleEndianEncoded<Double>(value: mBounds.min),
        LittleEndianEncoded<Double>(value: mBounds.max),
        ])
      byteEncodables.append(
        measures.map({LittleEndianEncoded<Double>(value: $0) as ByteEncodable})
      )
    }

    return makeByteArray(from: byteEncodables.flatten())
  }
}

// MARK: Equatable

extension ShapeFilePolygonMRecord: Equatable {}

func ==(lhs: ShapeFilePolygonMRecord, rhs: ShapeFilePolygonMRecord) -> Bool {
  return lhs.box == rhs.box && lhs.points == rhs.points && lhs.parts == rhs.parts && lhs.mBounds == rhs.mBounds && lhs.measures == rhs.measures
}
