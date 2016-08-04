//
//  SHPFileMultiPatchRecord.swift
//  ShapeSwift
//
//  Created by Ben Asher on 7/14/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import Foundation

// MARK: Multipatch

extension SHPFileMultiPatchRecord {
  struct Parser {
    let box: ShapeDataParser<LittleEndian<BoundingBoxXY>>
    let parts: ShapeDataArrayParser<LittleEndian<Int32>>
    let partTypes: ShapeDataArrayParser<LittleEndian<MultiPatchPartType>>
    let points: ShapeDataArrayParser<LittleEndian<Coordinate2D>>
    let zBounds: ShapeDataParser<LittleEndian<Coordinate2DBounds>>
    let zValues: ShapeDataArrayParser<LittleEndian<Double>>
    let mBounds: ShapeDataParser<LittleEndian<Coordinate2DBounds>>
    let measures: ShapeDataArrayParser<LittleEndian<Double>>

    init(data: Data, start: Int) throws {
      box = ShapeDataParser<LittleEndian<BoundingBoxXY>>(start: start)
      let numPartsParser = ShapeDataParser<LittleEndian<Int32>>(start: box.end)
      let numParts = try Int(numPartsParser.parse(data))
      let numPointsParser = ShapeDataParser<LittleEndian<Int32>>(start: numPartsParser.end)
      let numPoints = try Int(numPointsParser.parse(data))
      parts = ShapeDataArrayParser<LittleEndian<Int32>>(start: numPointsParser.end, count: numParts)
      partTypes = ShapeDataArrayParser<LittleEndian<MultiPatchPartType>>(start: parts.end, count: numParts)
      points = ShapeDataArrayParser<LittleEndian<Coordinate2D>>(start: partTypes.end, count: numPoints)
      zBounds = ShapeDataParser<LittleEndian<Coordinate2DBounds>>(start: points.end)
      zValues = ShapeDataArrayParser<LittleEndian<Double>>(start: zBounds.end, count: numPoints)
      mBounds = ShapeDataParser<LittleEndian<Coordinate2DBounds>>(start: zValues.end)
      measures = ShapeDataArrayParser<LittleEndian<Double>>(start: mBounds.end, count: numPoints)
    }
  }
}

//MARK: Record

struct SHPFileMultiPatchRecord {
  let box: BoundingBoxXY
  let parts: [Int]
  let partTypes: [MultiPatchPartType]
  let points: [Coordinate2D]
  let zBounds: Coordinate2DBounds
  let zValues: [Double]
  let mBounds: Coordinate2DBounds?
  let measures: [Double]
}

extension SHPFileMultiPatchRecord: SHPFileRecord {
  init(data: Data, range: Range<Int>, endByte: inout Int) throws {
    let parser = try Parser(data: data, start: range.lowerBound)
    box = try parser.box.parse(data)
    parts = try parser.parts.parse(data).map(Int.init)
    partTypes = try parser.partTypes.parse(data)
    points = try parser.points.parse(data)
    zBounds = try parser.zBounds.parse(data)
    zValues = try parser.zValues.parse(data)
    if range.contains(parser.mBounds.start) {
      mBounds = try valueOrNilIfNoDataValue(parser.mBounds.parse(data))
      measures = try parser.measures.parse(data).flatMap(valueOrNilIfNoDataValue)
      endByte = parser.measures.end - 1
    } else {
      mBounds = nil
      measures = []
      endByte = parser.zValues.end - 1
    }
  }
}

extension SHPFileMultiPatchRecord: ByteEncodable {
  func encode() -> [Byte] {
    var byteEncodables: [[ByteEncodable]] = [
      [
        LittleEndianEncoded<ShapeType>(value: .polyLineM),
        box,
        LittleEndianEncoded<Int32>(value: Int32(parts.count)),
        LittleEndianEncoded<Int32>(value: Int32(points.count))
      ],
      parts.map({LittleEndianEncoded<Int32>(value: Int32($0))}),
      partTypes.map(LittleEndianEncoded<MultiPatchPartType>.init),
      points.map({$0 as ByteEncodable}),
      [zBounds],
      zValues.map(LittleEndianEncoded<Double>.init),
      ]

    if let mBounds = mBounds {
      byteEncodables.append([mBounds])
      byteEncodables.append(
        measures.map({LittleEndianEncoded<Double>(value: $0) as ByteEncodable})
      )
    }

    return makeByteArray(from: byteEncodables.flatten())
  }
}

//MARK: Equatable

func == (lhs: SHPFileMultiPatchRecord, rhs: SHPFileMultiPatchRecord) -> Bool {
  return (
    lhs.box == rhs.box &&
      lhs.parts == rhs.parts &&
      lhs.partTypes == rhs.partTypes &&
      lhs.points == rhs.points &&
      lhs.zBounds == rhs.zBounds &&
      lhs.zValues == rhs.zValues &&
      lhs.mBounds == rhs.mBounds &&
      lhs.measures == rhs.measures
  )
}

extension SHPFileMultiPatchRecord: Equatable {}
