//
//  SHPFilePointRecord.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 6/2/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

// MARK: Parser

extension SHPFilePointRecord {
  struct Parser {
    let point: ShapeDataParser<LittleEndian<Coordinate2D>>

    init(start: Int) {
      point = ShapeDataParser<LittleEndian<Coordinate2D>>(start: start)
    }
  }
}

// MARK: Record

struct SHPFilePointRecord {
  let point: Coordinate2D
}

extension SHPFilePointRecord: SHPFileRecord {
  init(data: Data, range: Range<Int>) throws {
    let parser = Parser(start: range.lowerBound)
    point = try parser.point.parse(data)
  }
}

extension SHPFilePointRecord: ByteEncodable {
  func encode() -> [Byte] {
    let byteEncodables: [ByteEncodable] = [
      LittleEndianEncoded<ShapeType>(value: .point),
      point,
      ]
    return makeByteArray(from: byteEncodables)
  }
}

// MARK: Equatable

func ==(lhs: SHPFilePointRecord, rhs: SHPFilePointRecord) -> Bool {
  return lhs.point == rhs.point
}

extension SHPFilePointRecord: Equatable {}
