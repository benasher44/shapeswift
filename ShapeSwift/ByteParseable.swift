//
//  ByteParseable.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 4/7/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

/// Container for a type that should be parsed from big endian bytes
struct BigEndian<T: BigEndianByteParseable> {
  let value: T
}

struct EndianAgnostic<T: SingleByteParseable> {
  let value: T
}

/// Container for a type that should be parsed from little endian bytes
struct LittleEndian<T: LittleEndianByteParseable> {
  let value: T
}

/// Empty protocol to allow constraining to ghost types that are ByteOrdered
protocol ByteOrdered {
  associatedtype ValueT
}

/// Allow constraining to ghost types that contain value types that can be parsed from big endian bytes
protocol BigEndianByteOrdered: ByteOrdered {
  associatedtype ValueT: BigEndianByteParseable
}

/// Allow constraining to ghost types that contain value types that can be parsed from little endian bytes
protocol LittleEndianByteOrdered: ByteOrdered {
  associatedtype ValueT: LittleEndianByteParseable
}

extension BigEndian: BigEndianByteOrdered {
  typealias ValueT = T
}
extension LittleEndian: LittleEndianByteOrdered {
  typealias ValueT = T
}
extension EndianAgnostic: ByteOrdered {
  typealias ValueT = T
}

enum ByteParseableError: Error {
  case notParseable(type: Any.Type)
  case boundsUnchecked(type: ByteParseable.Type)
  case outOfBounds(expectedBounds: Range<Int>, actualBounds: Range<Int>)
}

protocol ByteParseable {
  static var sizeBytes: Int { get }
}

protocol BigEndianByteParseable: ByteParseable {
  init?(bigEndianData data: Data, start: Int)
}

protocol LittleEndianByteParseable: ByteParseable {
  init?(littleEndianData data: Data, start: Int)
}

protocol SingleByteParseable: ByteParseable {
  init?(data: Data, location: Int)
}

extension SingleByteParseable {
  static var sizeBytes: Int {
    return 1
  }
}

extension Int32: ByteParseable {
  static let sizeBytes = 4
}

extension Int32: BigEndianByteParseable {
  init?(bigEndianData data: Data, start: Int) {
    let bitPattern: Int32 = self.dynamicType.bitPattern(fromData: data, start: start)
    self = Int32(bigEndian: bitPattern)
  }
}

extension Int32: LittleEndianByteParseable {
  init?(littleEndianData data: Data, start: Int) {
    let bitPattern: Int32 = self.dynamicType.bitPattern(fromData: data, start: start)
    self = Int32(littleEndian: bitPattern)
  }
}

// todo(noah): there's a lot duplicated between Int32 and Int16, could be cleaned up
extension Int16: ByteParseable {
  static let sizeBytes = 2
}

extension Int16: BigEndianByteParseable {
  init?(bigEndianData data: Data, start: Int) {
    var intBytes = [UInt8](repeating: 0, count: self.dynamicType.sizeBytes)
    data.copyBytes(to: &intBytes, from: start..<(start + self.dynamicType.sizeBytes))
    let value = intBytes.withUnsafeBufferPointer({
      UnsafePointer<Int16>($0.baseAddress!).pointee
    })
    self = Int16(bigEndian: value)
  }
}

extension Int16: LittleEndianByteParseable {
  init?(littleEndianData data: Data, start: Int) {
    var intBytes = [UInt8](repeating: 0, count: self.dynamicType.sizeBytes)
    data.copyBytes(to: &intBytes, from: start..<(start + self.dynamicType.sizeBytes))
    let value = intBytes.withUnsafeBufferPointer({
      UnsafePointer<Int16>($0.baseAddress!).pointee
    })
    self = Int16(littleEndian: value)
  }
}

func parseInt8(data: Data, location: Int) -> Int8 {
  var intBytes = [UInt8](repeating: 0, count: 1)
  data.copyBytes(to: &intBytes, from: location..<(location + 1))
  let value = intBytes.withUnsafeBufferPointer({
    UnsafePointer<Int8>($0.baseAddress!).pointee
  })
  return Int8(value)
}

// todo(noah): there's a lot duplicated between Int16 and Int8, could be cleaned up
extension Int8: SingleByteParseable {
  typealias ValueT = Int8
  init?(data: Data, location: Int) {
    self = parseInt8(data: data, location: location)
  }
}

extension UInt8: SingleByteParseable {
  typealias ValueT = Int8
  init?(data: Data, location: Int) {
    self = UInt8(parseInt8(data: data, location: location))
  }
}

extension Bool: SingleByteParseable {
  typealias ValueT = Int8
  init?(data: Data, location: Int) {
    self = parseInt8(data: data, location: location) != 0
  }
}

extension Double: ByteParseable {
  static let sizeBytes = 8
}

extension Double: LittleEndianByteParseable {
  init?(littleEndianData data: Data, start: Int) {
    let bitPattern: UInt64 = self.dynamicType.bitPattern(fromData: data, start: start)
    self = Double(bitPattern: bitPattern)
  }
}

private extension ByteParseable {
  static func bitPattern<T>(fromData data: Data, start: Int) -> T {
    return data.withUnsafeBytes({(pointer: UnsafePointer<UInt8>) -> T in
      return UnsafePointer<T>(pointer.advanced(by: start)).pointee
    })
  }
}
