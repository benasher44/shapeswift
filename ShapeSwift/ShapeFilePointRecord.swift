//
//  ShapeFilePointRecord.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 6/2/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import Foundation

//MARK: Parser

struct ShapeFilePointRecordParser {
  let point: ShapeDataParser<LittleEndian<Coordinate2D>>

  init(start: Int) {
    point = ShapeDataParser<LittleEndian<Coordinate2D>>(start: start)
  }
}

//MARK: Record

struct ShapeFilePointRecord {
  let point: Coordinate2D
}

extension ShapeFilePointRecord: ShapeFileRecord {
  init(data: NSData, range: Range<Int>) throws {
    let parser = ShapeFilePointRecordParser(start: range.startIndex)
    point = try parser.point.parse(data)
  }
}

extension ShapeFilePointRecord: ByteEncodable {
  func encode() -> [Byte] {
    return makeByteArray(from: [
      LittleEndianEncoded<ShapeType>(value: .point),
      point,
      ])
  }
}

//MARK: Equatable

func ==(lhs: ShapeFilePointRecord, rhs: ShapeFilePointRecord) -> Bool {
  return lhs.point == rhs.point
}

extension ShapeFilePointRecord: Equatable {}
