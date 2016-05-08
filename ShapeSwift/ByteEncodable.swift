//
//  ByteEncodable.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 5/7/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import Foundation

typealias Byte = UInt8

protocol ByteEncodable {
  func encode() -> [Byte]
}

extension BigEndian: ByteEncodable {
  func encode() -> [Byte] {
    var mutableValue = value
    let size = value.dynamicType.sizeBytes
    return withUnsafePointer(&mutableValue) { pointer in
      Array(UnsafeBufferPointer(start: UnsafePointer<Byte>(pointer), count: size))
    }
  }
}

extension LittleEndian: ByteEncodable {
  func encode() -> [Byte] {
    var mutableValue = value
    let size = value.dynamicType.sizeBytes
    return withUnsafePointer(&mutableValue) { pointer in
      Array(UnsafeBufferPointer(start: UnsafePointer<Byte>(pointer), count: size)).reverse()
    }
  }
}

extension NSData {
  convenience init(byteEncodableArray array: [ByteEncodable]) {
    let bytes = array.flatMap { byteEncodable in
      byteEncodable.encode()
    }
    self.init(bytes: bytes, length: bytes.count)
  }
}
