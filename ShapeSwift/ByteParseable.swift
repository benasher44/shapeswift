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

// MARK: - ByteParseable Implementations

extension SingleByteParseable {
  static var byteWidth: Int { return 1 }
}

// MARK: FixedWidthInteger

extension ByteParseable where Self: FixedWidthInteger {
  static var byteWidth: Int { return Self.bitWidth / 8 }
}

extension BigEndianByteParseable where Self: FixedWidthInteger {
  init?(bigEndianData data: Data, start: Int) {
    let bitPattern: Self = ShapeSwift.bitPattern(fromData: data, start: start)
    self.init(bigEndian: bitPattern)
  }
}

extension LittleEndianByteParseable where Self: FixedWidthInteger {
  init?(littleEndianData data: Data, start: Int) {
    let bitPattern: Self = ShapeSwift.bitPattern(fromData: data, start: start)
    self.init(littleEndian: bitPattern)
  }
}

extension SingleByteParseable where Self: FixedWidthInteger {
  typealias ValueT = Self
  init?(data: Data, location: Int) {
    self = ShapeSwift.bitPattern(fromData: data, start: location)
  }
}

extension Int32: BigEndianByteParseable, LittleEndianByteParseable {}
extension UInt32: BigEndianByteParseable, LittleEndianByteParseable {}
extension Int16: BigEndianByteParseable, LittleEndianByteParseable {}

extension Int8: SingleByteParseable {}
extension UInt8: SingleByteParseable {}

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
    let bitPattern: UInt64 = ShapeSwift.bitPattern(fromData: data, start: start)
    self = Double(bitPattern: bitPattern)
  }
}

// MARK: - Helper Functions

private func bitPattern<T>(fromData data: Data, start: Int) -> T {
  return data.withUnsafeBytes { (bytePointer: UnsafePointer<Byte>) -> T in
    UnsafeRawPointer(bytePointer.advanced(by: start)).bindMemory(to: T.self, capacity: 1).pointee
  }
}

// MARK: - RawRepresentable

extension RawRepresentable where Self.RawValue: ByteParseable {
  static var byteWidth: Int { return Self.RawValue.byteWidth }
}
