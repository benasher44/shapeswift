//
//  ShapeFileMultiPointZRecord.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 6/16/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

// MARK: Record

struct ShapeFileMultiPointZRecord: ShapeFileRecord {
  let box: BoundingBoxXY
  let points: [Coordinate2D]
  let zBounds: Coordinate2DBounds
  let zValues: [Double]
  let mBounds: Coordinate2DBounds?
  let measures: [Double]
}

extension ShapeFileMultiPointZRecord {
  init(data: Data, range: Range<Int>) throws {
    let parser = try Parser(data: data, start: range.lowerBound)
    box = try parser.box.parse(data)
    points = try parser.points.parse(data)
    zBounds = try parser.zBounds.parse(data)
    zValues = try parser.zValues.parse(data)
    if range.upperBound > parser.mBounds.start {
      mBounds = try valueOrNilForOptionalValue(parser.mBounds.parse(data))
      measures = try parser.measures.parse(data).flatMap(valueOrNilForOptionalValue)
    } else {
      mBounds = nil
      measures = []
    }
  }
}

extension ShapeFileMultiPointZRecord: ByteEncodable {
  func encode() -> [Byte] {
    var byteEncodables = [
      [
        LittleEndianEncoded<ShapeType>(value: .multiPointZ),
        box,
        LittleEndianEncoded<Int32>(value: Int32(points.count))
      ],
      points.map({$0 as ByteEncodable}),
      [
        LittleEndianEncoded<Double>(value: zBounds.min),
        LittleEndianEncoded<Double>(value: zBounds.max),
      ],
      zValues.map({LittleEndianEncoded<Double>(value: $0) as ByteEncodable})
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

// MARK: Parser

extension ShapeFileMultiPointZRecord {
  struct Parser {
    let box: ShapeDataParser<LittleEndian<BoundingBoxXY>>
    let points: ShapeDataArrayParser<LittleEndian<Coordinate2D>>
    let zBounds: ShapeDataParser<LittleEndian<Coordinate2DBounds>>
    let zValues: ShapeDataArrayParser<LittleEndian<Double>>
    let mBounds: ShapeDataParser<LittleEndian<Coordinate2DBounds>>
    let measures: ShapeDataArrayParser<LittleEndian<Double>>
    init(data: Data, start: Int) throws {
      box = ShapeDataParser<LittleEndian<BoundingBoxXY>>(start: start)
      let numPointsParser = ShapeDataParser<LittleEndian<Int32>>(start: box.end)
      let numPoints = try Int(numPointsParser.parse(data))
      points = ShapeDataArrayParser<LittleEndian<Coordinate2D>>(start: numPointsParser.end, count: numPoints)
      zBounds = ShapeDataParser<LittleEndian<Coordinate2DBounds>>(start: points.end)
      zValues = ShapeDataArrayParser<LittleEndian<Double>>(start: zBounds.end, count: numPoints)
      mBounds = ShapeDataParser<LittleEndian<Coordinate2DBounds>>(start: zValues.end)
      measures = ShapeDataArrayParser<LittleEndian<Double>>(start: mBounds.end, count: numPoints)
    }
  }
}

// MARK: Equatable

extension ShapeFileMultiPointZRecord: Equatable {}

func ==(lhs: ShapeFileMultiPointZRecord, rhs: ShapeFileMultiPointZRecord) -> Bool {
  return lhs.box == rhs.box &&
    lhs.points == rhs.points &&
    lhs.zBounds == rhs.zBounds &&
    lhs.zValues == rhs.zValues &&
    lhs.mBounds == rhs.mBounds &&
    lhs.measures == rhs.measures
}
