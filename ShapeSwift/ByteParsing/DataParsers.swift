//
//  SHPFileDataParsers.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 5/1/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

struct ByteParseableDataParser<Value: ByteParseable, Order: ByteOrder> {
  let start: Int
}

extension ByteParseableDataParser {
  var end: Int { return start + Value.byteWidth }
}

extension ByteParseableDataParser where Value: LittleEndianByteParseable, Order == LittleEndian {
  func parse(_ data: Data) throws -> Value {
    if let value = Value(littleEndianData: data, start: start) {
      return value
    } else {
      throw ByteParseableError.notParseable(type: Value.self)
    }
  }
}

extension ByteParseableDataParser where Value: BigEndianByteParseable, Order == BigEndian {
  func parse(_ data: Data) throws -> Value {
    if let value = Value(bigEndianData: data, start: start) {
      return value
    } else {
      throw ByteParseableError.notParseable(type: Value.self)
    }
  }
}

struct ByteParseableSequentialDataParser<Value: ByteParseable, Order: ByteOrder> {
  let start: Int
  let count: Int

  var end: Int {
    return start + (count * Value.byteWidth)
  }

  fileprivate func iterParse(_ data: Data, _ parser: (_ data: Data, _ start: Int) -> Value?) throws -> [Value] {
    var values = Array<Value>()
    values.reserveCapacity(count)
    for byteOffset in stride(from: start, to: end, by: Value.byteWidth) {
      if let value = parser(data, byteOffset) {
        values.append(value)
      } else {
        throw ByteParseableError.notParseable(type: Value.self)
      }
    }
    return values
  }
}

extension ByteParseableSequentialDataParser where Value: LittleEndianByteParseable, Order == LittleEndian {
  func parse(_ data: Data) throws -> [Value] {
    return try iterParse(data) { data, start in
      return Value(littleEndianData: data, start: start)
    }
  }
}

extension ByteParseableSequentialDataParser where Value: BigEndianByteParseable, Order == BigEndian {
  func parse(_ data: Data) throws -> [Value] {
    return try iterParse(data) { data, start in
      return Value(bigEndianData: data, start: start)
    }
  }
}

extension ByteParseableSequentialDataParser where Value == CChar, Order == LittleEndian {
  func parseAsciiString(_ data: Data) throws -> String {
    return String(
      decoding: try self.parse(data).map { Unicode.ASCII.CodeUnit($0) },
      as: Unicode.ASCII.self
    )
  }
}

typealias StringDataParser = ByteParseableSequentialDataParser<CChar, LittleEndian>
