//
//  SHPFileDataParsers.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 5/1/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import Foundation

struct ShapeDataParser<T: ByteOrdered> {
  let range: Range<Int>
}

extension ShapeDataParser where T: LittleEndianByteOrdered {
  func parse(data: NSData) throws -> T.ValueT? {
    if let value = T.ValueT.makeFromLittleEndian(data, range: range) {
      return value
    } else {
      throw ByteParseableError.NotParseable(type: T.ValueT.self)
    }
  }
}

extension ShapeDataParser where T: BigEndianByteOrdered {
  func parse(data: NSData) throws -> T.ValueT? {
    if let value = T.ValueT.makeFromBigEndian(data, range: range) {
      return value
    } else {
      throw ByteParseableError.NotParseable(type: T.ValueT.self)
    }
  }
}

struct ShapeDataArrayParser<T: ByteOrdered> {
  let start: Int
  let size: Int
  let count: Int

  var end: Int {
    return start + (count * size)
  }

  private func enumerateRanges(rangeEnumerationBlock: (Range<Int>) throws -> Void) rethrows {
    for rangeStart in start.stride(to: end, by: size) {
      try rangeEnumerationBlock(rangeStart..<(rangeStart + size))
    }
  }
}

extension ShapeDataArrayParser where T: LittleEndianByteOrdered {
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

extension ShapeDataArrayParser where T: BigEndianByteOrdered {
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
