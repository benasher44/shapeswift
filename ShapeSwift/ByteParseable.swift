//
//  ByteParseable.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 4/7/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

typealias Byte = UInt8

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
protocol BigEndianByteOrdered: ByteOrdered where ValueT: BigEndianByteParseable {}

/// Allow constraining to ghost types that contain value types that can be parsed from little endian bytes
protocol LittleEndianByteOrdered: ByteOrdered where ValueT: LittleEndianByteParseable {}

protocol SingleByteOrdered: ByteOrdered where ValueT: SingleByteParseable {}

extension BigEndian: BigEndianByteOrdered {
  typealias ValueT = T
}
extension LittleEndian: LittleEndianByteOrdered {
  typealias ValueT = T
}
extension EndianAgnostic: SingleByteOrdered {
  typealias ValueT = T
}

enum ByteParseableError: Error {
  case notParseable(type: Any.Type)
  case boundsUnchecked(type: ByteParseable.Type)
  case outOfBounds(expectedBounds: Range<Int>, actualBounds: Range<Int>)
}

protocol ByteParseable {
  static var byteWidth: Int { get }
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
  static var byteWidth: Int {
    return 1
  }
}

extension ByteParseable where Self: FixedWidthInteger {
    static var byteWidth: Int { return Self.bitWidth / 8 }
}

extension RawRepresentable where Self.RawValue: ByteParseable {
    static var byteWidth: Int { return Self.RawValue.byteWidth }
}

extension Int32: ByteParseable {}
extension UInt32: ByteParseable {}
extension Int16: ByteParseable {}

extension Int32: BigEndianByteParseable {
  init?(bigEndianData data: Data, start: Int) {
    let bitPattern: Int32 = type(of: self).bitPattern(fromData: data, start: start)
    self = Int32(bigEndian: bitPattern)
  }
}

extension Int32: LittleEndianByteParseable {
  init?(littleEndianData data: Data, start: Int) {
    let bitPattern: Int32 = type(of: self).bitPattern(fromData: data, start: start)
    self = Int32(littleEndian: bitPattern)
  }
}

extension UInt32: LittleEndianByteParseable {
  init?(littleEndianData data: Data, start: Int) {
    let bitPattern: UInt32 = type(of: self).bitPattern(fromData: data, start: start)
    self = UInt32(littleEndian: bitPattern)
  }
}

extension Int8: SingleByteParseable {
  typealias ValueT = Int8
  init?(data: Data, location: Int) {
    self = ShapeSwift.bitPattern(fromData: data, start: location, byteWidth: 1)
  }
}

extension UInt8: SingleByteParseable {
  typealias ValueT = UInt8
  init?(data: Data, location: Int) {
    self = ShapeSwift.bitPattern(fromData: data, start: location, byteWidth: 1)
  }
}

extension Int16: BigEndianByteParseable {
  init?(bigEndianData data: Data, start: Int) {
    let bitPattern: Int16 = type(of: self).bitPattern(fromData: data, start: start)
    self = Int16(bigEndian: bitPattern)
  }
}

extension Int16: LittleEndianByteParseable {
  init?(littleEndianData data: Data, start: Int) {
    let bitPattern: Int16 = type(of: self).bitPattern(fromData: data, start: start)
    self = Int16(littleEndian: bitPattern)
  }
}

extension Bool: SingleByteParseable {
  typealias ValueT = Int8
  init?(data: Data, location: Int) {
    self = Int8(data: data, location: location) != 0
  }
}

extension Double: ByteParseable {
  static let byteWidth = 8
}

extension Double: LittleEndianByteParseable {
  init?(littleEndianData data: Data, start: Int) {
    let bitPattern: UInt64 = type(of: self).bitPattern(fromData: data, start: start)
    self = Double(bitPattern: bitPattern)
  }
}

fileprivate extension ByteParseable {
  static func bitPattern<T>(fromData data: Data, start: Int) -> T {
    return ShapeSwift.bitPattern(fromData: data, start: start, byteWidth: byteWidth)
  }
}

fileprivate func bitPattern<T>(fromData data: Data, start: Int, byteWidth: Int) -> T {
  return data.withUnsafeBytes { (bytePointer: UnsafePointer<Byte>) -> T in
    bytePointer.advanced(by: start).withMemoryRebound(to: T.self, capacity: byteWidth) { pointer in
      return pointer.pointee
    }
  }
}
