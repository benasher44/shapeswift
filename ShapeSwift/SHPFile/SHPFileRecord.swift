//
//  SHPFileRecord.swift
//  ShapeSwift
//
//  Created by Ben Asher on 4/29/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

/// Values less than this are consider "no data" values in shape files
private let noDataThreshold = Double(sign: .minus, exponent: 129, significand: 1.4693679385278592963715027508442290127277) // 10^38
private let noDataValue = Double(sign: .minus, exponent: 129, significand: 1.5) // Value smaller than 10^38

func valueOrNilIfNoDataValue(_ value: Coordinate2DBounds) -> Coordinate2DBounds? {
  if value.min < noDataThreshold || value.max < noDataThreshold {
    return nil
  } else {
    return value
  }
}

func valueOrNilIfNoDataValue(_ value: Double) -> Double? {
  if value < noDataThreshold {
    return nil
  } else {
    return value
  }
}

func valueOrNoDataValueForOptional(_ value: Double?) -> Double {
  return value ?? noDataValue
}

protocol SHPFileRecord {
  init(data: Data, range: Range<Int>, endByte: inout Int) throws
}

extension SHPFileRecord {
  static func recordForShapeType(_ shapeType: ShapeType, data: Data, range: Range<Int>) throws -> SHPFileRecord? {
    var type: SHPFileRecord.Type
    switch shapeType {
    case .point:
      type = SHPFilePointRecord.self
    default:
      return nil
    }
    var endByte = 0;
    let record = try type.init(data: data, range: range, endByte: &endByte)
    let byteRange: Range = 4..<endByte + 1 // Skip the first 4 bytes because of the shape type
    if endByte == 0 {
      throw ByteParseableError.boundsUnchecked(type: type as! ByteParseable.Type)
    } else if (byteRange != range) {
      throw ByteParseableError.outOfBounds(expectedBounds: range, actualBounds: byteRange)
    }
    return record
  }
}

