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

enum ByteParseableError: Error {
  case notParseable(type: ByteParseable.Type)
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
    var bytes = [UInt8](repeating: 0, count: sizeBytes)
    data.copyBytes(to: &bytes, from: start..<(start + sizeBytes))
    return bytes.withUnsafeBufferPointer({
      UnsafePointer<T>($0.baseAddress!).pointee
    })
  }
}
