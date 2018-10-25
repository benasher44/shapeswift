//
//  SHPFileDataParsers.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 5/1/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

struct ByteParser<Value: ByteParseable, Order: ByteOrder> {
  let start: Int
  let count: Int

  init(start: Int, count: Int = 1) {
    precondition(count > 0, "count must be non-zero: \(count)")
    self.start = start
    self.count = count
  }
}

extension ByteParser {
  var end: Int { return self.start + (self.count * Value.byteWidth) }
}

/// MARK: - Single Value Parsing

extension ByteParser where Value: LittleEndianByteParseable, Order == LittleEndian {
  func parse(_ data: Data) throws -> Value {
    precondition(self.count == 1, "Parsing a single value with an invalid count: \(self.count)")
    if let value = Value(littleEndianData: data, start: start) {
      return value
    } else {
      throw ByteParseableError.notParseable(type: Value.self)
    }
  }
}

extension ByteParser where Value: BigEndianByteParseable, Order == BigEndian {
  func parse(_ data: Data) throws -> Value {
    precondition(self.count == 1, "Parsing a single value with an invalid count: \(self.count)")
    if let value = Value(bigEndianData: data, start: start) {
      return value
    } else {
      throw ByteParseableError.notParseable(type: Value.self)
    }
  }
}

/// MARK: - Value Sequence Parsing

extension ByteParser {
  private func parseValues(_ data: Data, _ parser: (_ data: Data, _ start: Int) -> Value?) throws -> [Value] {
    var values = [Value]()
    values.reserveCapacity(self.count)
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

extension ByteParser where Value: LittleEndianByteParseable, Order == LittleEndian {
  func parse(_ data: Data) throws -> [Value] {
    return try self.parseValues(data) { data, start in
      return Value(littleEndianData: data, start: start)
    }
  }
}

extension ByteParser where Value: BigEndianByteParseable, Order == BigEndian {
  func parse(_ data: Data) throws -> [Value] {
    return try self.parseValues(data) { data, start in
      return Value(bigEndianData: data, start: start)
    }
  }
}

extension ByteParser where Value == CChar, Order == LittleEndian {
  func parseAsciiString(_ data: Data) throws -> String {
    let characters = try self.parse(data).map { Unicode.ASCII.CodeUnit($0) }
    let characterSequence: ArraySlice<Unicode.ASCII.CodeUnit>

    /// If the last character is null, exclude it
    if characters.last == 0 {
      characterSequence = characters.dropLast()
    } else {
      characterSequence = characters[...]
    }

    return String(
      decoding: characterSequence,
      as: Unicode.ASCII.self
    )
  }
}

typealias StringDataParser = ByteParser<CChar, LittleEndian>
