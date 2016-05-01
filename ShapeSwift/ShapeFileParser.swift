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
    if let value = T.ValueT.makeFromLittleEndian(data, range: range) {
      return value
    } else {
      throw ByteParseableError.NotParseable(type: T.ValueT.self)
    }
  }
}

extension ShapeDataDefinition where T: BigEndianByteOrdered {
  func parse(data: NSData) throws -> T.ValueT? {
    if let value = T.ValueT.makeFromBigEndian(data, range: range) {
      return value
    } else {
      throw ByteParseableError.NotParseable(type: T.ValueT.self)
    }
  }
}

struct ShapeDataArrayDefinition<T: ByteOrdered> {
  let start: Int
  let size: Int
  let count: Int

  private func enumerateRanges(rangeEnumerationBlock: (Range<Int>) throws -> Void) rethrows {
    let end = start + (count * size)
    for rangeStart in start.stride(to: end, by: size) {
      try rangeEnumerationBlock(rangeStart..<(rangeStart + size))
    }
  }
}

extension ShapeDataArrayDefinition where T: LittleEndianByteOrdered {
  func parse(data: NSData) throws -> [T.ValueT]? {
    var values = Array<T.ValueT>()
    try enumerateRanges { range in
      if let value = T.ValueT.makeFromLittleEndian(data, range: range) {
        values.append(value)
      } else {
        throw ByteParseableError.NotParseable(type: T.ValueT.self)
      }
    }
    return values
  }
}

extension ShapeDataArrayDefinition where T: BigEndianByteOrdered {
  func parse(data: NSData) throws -> [T.ValueT]? {
    var values = Array<T.ValueT>()
    try enumerateRanges { range in
      if let value = T.ValueT.makeFromBigEndian(data, range: range) {
        values.append(value)
      } else {
        throw ByteParseableError.NotParseable(type: T.ValueT.self)
      }
    }
    return values
  }
}

private let headerRange = 0..<100

struct ShapeFileHeaderDefinition {
  let fileCode = ShapeDataDefinition<BigEndian<Int32>>(range: 0..<4)
  let fileLength = ShapeDataDefinition<BigEndian<Int32>>(range: 24..<28)
  let version = ShapeDataDefinition<LittleEndian<Int32>>(range: 28..<32)
  let shapeType = ShapeDataDefinition<LittleEndian<ShapeType>>(range: 32..<36)
  let boundingBox = ShapeDataDefinition<LittleEndian<BoundingBoxXYZM>>(range: 36..<100)
}

struct ShapeFileHeader {
  let fileCode: Int
  let fileLength: Int
  let version: Int
  let shapeType: ShapeType
  let boundingBox: BoundingBoxXYZM
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
