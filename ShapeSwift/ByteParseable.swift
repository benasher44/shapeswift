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

enum ByteParseableError: ErrorProtocol {
  case notParseable(type: ByteParseable.Type)
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
    var intBytes = [UInt8](repeating: 0, count: self.dynamicType.sizeBytes)
    data.copyBytes(to: &intBytes, from: start..<(start + self.dynamicType.sizeBytes))
    let value = intBytes.withUnsafeBufferPointer({
      UnsafePointer<Int32>($0.baseAddress!).pointee
    })
    self = Int32(bigEndian: value)
  }
}

extension Int32: LittleEndianByteParseable {
  init?(littleEndianData data: Data, start: Int) {
    var intBytes = [UInt8](repeating: 0, count: self.dynamicType.sizeBytes)
    data.copyBytes(to: &intBytes, from: start..<(start + self.dynamicType.sizeBytes))
    let value = intBytes.withUnsafeBufferPointer({
      UnsafePointer<Int32>($0.baseAddress!).pointee
    })
    self = Int32(littleEndian: value)
  }
}

extension Double: ByteParseable {
  static let sizeBytes = 8
}

extension Double: LittleEndianByteParseable {
  init?(littleEndianData data: Data, start: Int) {
    var doubleBytes = [UInt8](repeating: 0, count: self.dynamicType.sizeBytes)
    data.copyBytes(to: &doubleBytes, from: start..<(start + self.dynamicType.sizeBytes))
    let value = doubleBytes.withUnsafeBufferPointer({
      UnsafePointer<UInt64>($0.baseAddress!).pointee
    })
    self = Double(bitPattern: value)
  }
}

