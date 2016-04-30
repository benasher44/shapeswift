//
//  ShapeFileParser.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 3/30/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import Foundation

struct ShapeDataDefinition<T: ByteOrdered> {
  let range: Range<Int>
}

extension ShapeDataDefinition where T: LittleEndianByteOrdered {
  func parse(data: NSData) throws -> T.ValueT? {
    return T.ValueT.makeFromLittleEndian(data, range: range)
  }
}

extension ShapeDataDefinition where T: BigEndianByteOrdered {
  func parse(data: NSData) throws -> T.ValueT? {
    return T.ValueT.makeFromBigEndian(data, range: range)
  }
}

struct BoundingBox {
  let x: CoordinateBounds
  let y: CoordinateBounds
  let z: CoordinateBounds
  let m: CoordinateBounds
}

struct CoordinateBounds {
  let min: Double
  let max: Double
}

enum ShapeType: Int {
  case nullShape = 0
  case point = 1
  case polyLine = 3
  case polygon = 5
  case multiPoint = 8
  case pointZ = 11
  case polyLineZ = 13
  case polygonZ = 15
  case multiPointZ = 18
  case pointM = 21
  case polyLineM = 23
  case polygonM = 25
  case multiPointM = 28
  case multiPatch = 31
}

extension ShapeType: LittleEndianByteOrdered {
  typealias ValueT = ShapeType
}

extension BoundingBox: LittleEndianByteOrdered {
  typealias ValueT = BoundingBox
}

extension ShapeType: LittleEndianByteParseable {
  static func makeFromLittleEndian(data: NSData, range: Range<Int>) -> ShapeType? {
    return ShapeType(rawValue: Int(Int32.makeFromLittleEndian(data, range: range)!))
  }
}

extension BoundingBox: LittleEndianByteParseable {
  static func makeFromLittleEndian(data: NSData, range: Range<Int>) -> BoundingBox? {
    let byteRange = (range.startIndex)..<(range.startIndex + 8)
    return BoundingBox(x: CoordinateBounds(min: Double.makeFromLittleEndian(data, range: byteRange)!,
                                           max: Double.makeFromLittleEndian(data, range: byteRange.shifted(16))!),
                       y: CoordinateBounds(min: Double.makeFromLittleEndian(data, range: byteRange.shifted(8))!,
                                           max: Double.makeFromLittleEndian(data, range: byteRange.shifted(24))!),
                       z: CoordinateBounds(min: Double.makeFromLittleEndian(data, range: byteRange.shifted(32))!,
                                           max: Double.makeFromLittleEndian(data, range: byteRange.shifted(40))!),
                       m: CoordinateBounds(min: Double.makeFromLittleEndian(data, range: byteRange.shifted(48))!,
                                           max: Double.makeFromLittleEndian(data, range: byteRange.shifted(56))!))
  }
}

private let headerRange = 0..<100

struct ShapeFileHeaderDefinition {
  let fileCode = ShapeDataDefinition<BigEndian<Int32>>(range: 0..<4)
  let fileLength = ShapeDataDefinition<BigEndian<Int32>>(range: 24..<28)
  let version = ShapeDataDefinition<LittleEndian<Int32>>(range: 28..<32)
  let shapeType = ShapeDataDefinition<ShapeType>(range: 32..<36)
  let boundingBox = ShapeDataDefinition<BoundingBox>(range: 36..<100)
}

struct ShapeFileHeader {
  let fileCode: Int
  let fileLength: Int
  let version: Int
  let shapeType: ShapeType
  let boundingBox: BoundingBox
  init?(data: NSData) throws {
    let def = ShapeFileHeaderDefinition()
    fileCode = try Int(def.fileCode.parse(data)!)
    fileLength = try Int(def.fileLength.parse(data)!)
    version = try Int(def.version.parse(data)!)
    shapeType = try def.shapeType.parse(data)!
    boundingBox = try def.boundingBox.parse(data)!
  }
}

struct ShapeFileRecordHeaderDefinition {
  let recordNumber: ShapeDataDefinition<BigEndian<Int32>>
  let contentLength: ShapeDataDefinition<BigEndian<Int32>>
  init(start: Int) {
    recordNumber = ShapeDataDefinition<BigEndian<Int32>>(range: start..<(start + 4))
    contentLength = ShapeDataDefinition<BigEndian<Int32>>(range: (start + 4)..<(start + 8))
  }
}

struct ShapeFileRecordHeader {
  let recordNumber: Int
  let contentLength: Int
  init?(data: NSData, start: Int) throws {
    let def = ShapeFileRecordHeaderDefinition(start: start)
    recordNumber = try Int(def.recordNumber.parse(data)!)
    contentLength = try Int(def.contentLength.parse(data)!)
  }
}

public func parseFromURL(fileURL: NSURL) throws -> Void {
  let data = try NSData(contentsOfURL: fileURL, options: .DataReadingMappedIfSafe)
  let header = try ShapeFileHeader(data: data)
  print("header - \(header.debugDescription)")
}
