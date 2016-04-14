//
//  ByteParseable.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 4/7/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import Foundation


enum Endianness {
  case Big
  case Little
}

enum ByteParseableError: ErrorType {
  case NotParseable(type: ByteParseable.Type)
}

protocol ByteParseable {
  init?(data: NSData, range: Range<Int>, endianness: Endianness)
}

extension Int32: ByteParseable {
  init(data: NSData, range: Range<Int>, endianness: Endianness) {
    var rawInt: Int32 = 0
    data.getBytes(&rawInt, range: NSRange(fromRange: range))
    switch endianness {
    case .Big:
      self = Int32(bigEndian: rawInt)
    case .Little:
      self = Int32(littleEndian: rawInt)
    }
  }
}

extension Double: ByteParseable {
  init(data: NSData, range: Range<Int>, endianness: Endianness) {
    var rawDouble: Int64 = 0
    data.getBytes(&rawDouble, range: NSRange(fromRange: range))
    switch endianness {
    case .Big:
      self = unsafeBitCast(Int64(bigEndian: rawDouble), Double.self)
    case .Little:
      self = unsafeBitCast(Int64(littleEndian: rawDouble), Double.self)
    }
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

