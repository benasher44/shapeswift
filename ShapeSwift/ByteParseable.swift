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
  init?(data: NSData, range: NSRange, endianness: Endianness)
}

extension Int32: ByteParseable {
  init(data: NSData, range: NSRange, endianness: Endianness) {
    var rawInt: Int32 = 0
    data.getBytes(&rawInt, range: range)
    switch endianness {
    case .Big:
      self = Int32(bigEndian: rawInt)
    case .Little:
      self = Int32(littleEndian: rawInt)
    }
  }
}

extension Double: ByteParseable {
  init(data: NSData, range: NSRange, endianness: Endianness) {
    var rawDouble: Int64 = 0
    data.getBytes(&rawDouble, range: range)
    switch endianness {
    case .Big:
      self = unsafeBitCast(Int64(littleEndian: rawDouble), Double.self)
    case .Little:
      self = unsafeBitCast(Int64(littleEndian: rawDouble), Double.self)
    }
  }
}

extension NSRange {
  func shifted(amount: Int) -> NSRange {
    return NSRange(location: location + amount, length: length)
  }
}

