//
//  ByteEncodable.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 5/7/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

@testable import ShapeSwift

// MARK: Byte encodable protocols

/// A type encodable to bytes without caring about endianness.
protocol ByteEncodable {
  func encode() -> [Byte]
}

func makeByteArray<T: Sequence>(from byteEncodables: T) -> [Byte] where T.Iterator.Element == ByteEncodable {
  return byteEncodables.flatMap { $0.encode() }
}

/// A type encodable to bytes in big endian
protocol BigEndianByteEncodable: ByteParseable {
  func encodeBigEndian() -> [Byte]
}

/// A type encodable to bytes in little endian
protocol LittleEndianByteEncodable: ByteParseable {
  func encodeLittleEndian() -> [Byte]
}

// MARK: Endianness wrappers

/**
 A wrapper for a LittleEndianByteEncodable value (the wrapper itself being ByteEncodable). If you only
 have a LittleEndianByteEncodable and you want to represent it as a ByteEncodable, wrap it in this struct.
 */
struct LittleEndianEncoded<EncodedType: LittleEndianByteEncodable>: ByteEncodable {
  static var sizeBytes: Int {
    get {
      return EncodedType.sizeBytes
    }
  }
  let value: EncodedType
  func encode() -> [Byte] {
    return value.encodeLittleEndian()
  }
}

/// A wrapper for a BigEndianByteEncodable value (the wrapper itself being ByteEncodable)
struct BigEndianEncoded<EncodedType: BigEndianByteEncodable>: ByteEncodable {
  static var sizeBytes: Int {
    get {
      return EncodedType.sizeBytes
    }
  }
  let value: EncodedType
  func encode() -> [Byte] {
    return value.encodeBigEndian()
  }
}

extension Data {
  init(byteEncodableArray array: [ByteEncodable]) {
    let bytes = array.flatMap { byteEncodable in
      byteEncodable.encode()
    }
    self.init(bytes: bytes, count: bytes.count)
  }
}

// MARK: ByteEncodable extensions

func toByteArray<T>(value: T, size: Int) -> [Byte] {
  var mutableValue = value
  return withUnsafePointer(to: &mutableValue) { pointer in
    return pointer.withMemoryRebound(to: Byte.self, capacity: size) { bytePointer in
      Array(UnsafeBufferPointer(start: bytePointer, count: size))
    }
  }
}

extension Double: LittleEndianByteEncodable {
  func encodeLittleEndian() -> [Byte] {
    return toByteArray(value: self, size: type(of: self).sizeBytes)
  }
}

extension Int32: LittleEndianByteEncodable {
  func encodeLittleEndian() -> [Byte] {
    return toByteArray(value: self, size: type(of: self).sizeBytes)
  }
}

extension Int32: BigEndianByteEncodable {
  func encodeBigEndian() -> [Byte] {
    return toByteArray(value: self, size: type(of: self).sizeBytes).reversed()
  }
}

extension MultiPatchPartType: LittleEndianByteEncodable {
  func encodeLittleEndian() -> [Byte] {
    return Int32(self.rawValue).encodeLittleEndian()
  }
}

extension ShapeType: LittleEndianByteEncodable {
  func encodeLittleEndian() -> [Byte] {
    return Int32(self.rawValue).encodeLittleEndian()
  }
}

extension Coordinate2D: ByteEncodable {
  func encode() -> [Byte] {
    return Array([
      LittleEndianEncoded<Double>(value: x).encode(),
      LittleEndianEncoded<Double>(value: y).encode()
    ].joined())
  }
}

extension Coordinate2DBounds: ByteEncodable {
  func encode() -> [Byte] {
    return Array([
      LittleEndianEncoded<Double>(value: min).encode(),
      LittleEndianEncoded<Double>(value: max).encode()
      ].joined())
  }
}

extension BoundingBoxXY: ByteEncodable {
  func encode() -> [Byte] {
    return Array([
      LittleEndianEncoded<Double>(value: x.min).encode(),
      LittleEndianEncoded<Double>(value: y.min).encode(),
      LittleEndianEncoded<Double>(value: x.max).encode(),
      LittleEndianEncoded<Double>(value: y.max).encode()
      ].joined())
  }
}
