//
//  SHPFileDataParsers.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 5/1/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

struct ShapeDataParser<T: ByteOrdered> {
  let start: Int
}

extension ShapeDataParser where T.ValueT: ByteParseable {
  var end: Int {
    return start + T.ValueT.sizeBytes
  }
}

extension ShapeDataParser where T: LittleEndianByteOrdered {
  func parse(_ data: Data) throws -> T.ValueT {
    if let value = T.ValueT(littleEndianData: data, start: start) {
      return value
    } else {
      throw ByteParseableError.notParseable(type: T.ValueT.self)
    }
  }
}

extension ShapeDataParser where T: BigEndianByteOrdered {
  func parse(_ data: Data) throws -> T.ValueT {
    if let value = T.ValueT(bigEndianData: data, start: start) {
      return value
    } else {
      throw ByteParseableError.notParseable(type: T.ValueT.self)
    }
  }
}

struct ShapeDataArrayParser<T: ByteOrdered where T.ValueT: ByteParseable> {
  let start: Int
  let count: Int

  var end: Int {
    return start + (count * T.ValueT.sizeBytes)
  }

  private func iterParse(_ data: Data, _ parser: (data: Data, start: Int) -> T.ValueT?) throws -> [T.ValueT] {
    var values = Array<T.ValueT>()
    values.reserveCapacity(count)
    for byteOffset in stride(from: start, to: end, by: T.ValueT.sizeBytes) {
      if let value = parser(data: data, start: byteOffset) {
        values.append(value)
      } else {
        throw ByteParseableError.notParseable(type: T.ValueT.self)
      }
    }
    return values
  }
}

extension ShapeDataArrayParser where T: LittleEndianByteOrdered {
  func parse(_ data: Data) throws -> [T.ValueT] {
    return try iterParse(data) { data, start in
      return T.ValueT(littleEndianData: data, start: start)
    }
  }
}

extension ShapeDataArrayParser where T: BigEndianByteOrdered {
  func parse(_ data: Data) throws -> [T.ValueT] {
    return try iterParse(data) { data, start in
      return T.ValueT(bigEndianData: data, start: start)
    }
  }
}
