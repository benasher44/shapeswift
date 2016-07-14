//
//  ShapeFileMultiPointMRecord.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 6/4/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

// MARK: Parser

extension ShapeFileMultiPointMRecord {
  struct Parser {
    let box: ShapeDataParser<LittleEndian<BoundingBoxXY>>
    let points: ShapeDataArrayParser<LittleEndian<Coordinate2D>>
    let mBounds: ShapeDataParser<LittleEndian<Coordinate2DBounds>>
    let measures: ShapeDataArrayParser<LittleEndian<Double>>
    init(data: Data, start: Int) throws {
      box = ShapeDataParser<LittleEndian<BoundingBoxXY>>(start: start)
      let numPointsParser = ShapeDataParser<LittleEndian<Int32>>(start: box.end)
      let numPoints = try Int(numPointsParser.parse(data))
      points = ShapeDataArrayParser<LittleEndian<Coordinate2D>>(start: numPointsParser.end, count: numPoints)
      mBounds = ShapeDataParser<LittleEndian<Coordinate2DBounds>>(start: points.end)
      measures = ShapeDataArrayParser<LittleEndian<Double>>(start: mBounds.end, count: numPoints)
    }
  }
}

// MARK: Record

struct ShapeFileMultiPointMRecord: ShapeFileRecord {
  let box: BoundingBoxXY
  let points: [Coordinate2D]
  let mBounds: Coordinate2DBounds?
  let measures: [Double]
}

extension ShapeFileMultiPointMRecord {
  init(data: Data, range: Range<Int>) throws {
    let parser = try Parser(data: data, start: range.lowerBound)
    box = try parser.box.parse(data)
    points = try parser.points.parse(data)
    if range.upperBound > parser.mBounds.start {
      mBounds = try valueOrNilForOptionalValue(parser.mBounds.parse(data))
      measures = try parser.measures.parse(data).flatMap(valueOrNilForOptionalValue)
    } else {
      mBounds = nil
      measures = []
    }
  }
}

extension ShapeFileMultiPointMRecord: ByteEncodable {
  func encode() -> [Byte] {
    var byteEncodables = [[
      LittleEndianEncoded<ShapeType>(value: .multiPointM),
      box,
      LittleEndianEncoded<Int32>(value: Int32(points.count))
    ],
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

extension ShapeFileMultiPointMRecord: Equatable {}

func ==(lhs: ShapeFileMultiPointMRecord, rhs: ShapeFileMultiPointMRecord) -> Bool {
  return lhs.box == rhs.box && lhs.points == rhs.points && lhs.mBounds == rhs.mBounds && lhs.measures == rhs.measures
}
