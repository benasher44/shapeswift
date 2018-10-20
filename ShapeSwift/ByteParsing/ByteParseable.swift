//
//  ByteParseable.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 4/7/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

typealias Byte = UInt8

/// Groups the phantom types to use for configuring parsers to parse types in a
/// particular byte order
protocol ByteOrder {}

// Phantom type to use when parsing little-endian numbers
enum LittleEndian: ByteOrder {}

// Phantom type to use when parsing big-endian numbers
enum BigEndian: ByteOrder {}

/// Errors that can occur parsing `ByteParesable` types
enum ByteParseableError: Error {
  case notParseable(type: Any.Type)
  case boundsUnchecked(type: ByteParseable.Type)
  case outOfBounds(expectedBounds: Range<Int>, actualBounds: Range<Int>)
}

/// Types that can be parsed from binary bytes
protocol ByteParseable {
  static var byteWidth: Int { get }
}

/// Types that be parsed from big-endian binary bytes
protocol BigEndianByteParseable: ByteParseable {
  init?(bigEndianData data: Data, start: Int)
}

/// Types that be parsed from little-endian binary bytes
protocol LittleEndianByteParseable: ByteParseable {
  init?(littleEndianData data: Data, start: Int)
}

// MARK: - ByteParseable Implementations

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

extension Int32: BigEndianByteParseable, LittleEndianByteParseable {}
extension UInt32: BigEndianByteParseable, LittleEndianByteParseable {}
extension Int16: BigEndianByteParseable, LittleEndianByteParseable {}

extension Int8: LittleEndianByteParseable {}
extension UInt8: LittleEndianByteParseable {}

extension Bool: LittleEndianByteParseable {
  static var byteWidth: Int { return 1 }
  init?(littleEndianData data: Data, start: Int) {
    self = UInt8(littleEndianData: data, start: start) != 0
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
