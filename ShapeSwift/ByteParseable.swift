//
//  ByteParseable.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 4/7/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import Foundation

struct BigEndian<T: BigEndianByteParseable> {
  private init() {}
}

struct LittleEndian<T: LittleEndianByteParseable> {
  private init() {}
}

protocol ByteOrdered {}

protocol BigEndianByteOrdered: ByteOrdered {
  associatedtype ValueT: BigEndianByteParseable
}
protocol LittleEndianByteOrdered: ByteOrdered {
  associatedtype ValueT: LittleEndianByteParseable
}

extension BigEndian: BigEndianByteOrdered {
  typealias ValueT = T
}
extension LittleEndian: LittleEndianByteOrdered {
  typealias ValueT = T
}

enum ByteParseableError: ErrorType {
  case NotParseable(type: ByteParseable.Type)
}

protocol ByteParseable {}

protocol BigEndianByteParseable: ByteParseable {
  static func makeFromBigEndian(data: NSData, range: Range<Int>) -> Self?
}

protocol LittleEndianByteParseable: ByteParseable {
  static func makeFromLittleEndian(data: NSData, range: Range<Int>) -> Self?
}

extension Int32: BigEndianByteParseable {
  static func makeFromBigEndian(data: NSData, range: Range<Int>) -> Int32? {
    var rawInt: Int32 = 0
    data.getBytes(&rawInt, range: NSRange(fromRange: range))
    return Int32(bigEndian: rawInt)
  }
}

extension Int32: LittleEndianByteParseable {
  static func makeFromLittleEndian(data: NSData, range: Range<Int>) -> Int32? {
    var rawInt: Int32 = 0
    data.getBytes(&rawInt, range: NSRange(fromRange: range))
    return Int32(littleEndian: rawInt)
  }
}

extension Double: LittleEndianByteParseable {
  static func makeFromLittleEndian(data: NSData, range: Range<Int>) -> Double? {
    var rawDouble: Int64 = 0
    data.getBytes(&rawDouble, range: NSRange(fromRange: range))
    return unsafeBitCast(Int64(littleEndian: rawDouble), Double.self)
  }
}

extension NSRange {
  init(fromRange range: Range<Int>) {
    self.init(location: range.startIndex, length: range.endIndex - range.startIndex)
  }
}

extension Range where Element: IntegerArithmeticType {
  func shifted(amount: Element) -> Range {
    return (startIndex + amount)...(endIndex + amount)
  }
}
