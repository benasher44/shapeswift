//
//  SHPFileRecord.swift
//  ShapeSwift
//
//  Created by Ben Asher on 4/29/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

/// Values less than this are consider "no data" values in shape files
private let noDataThreshold = Double(sign: .minus, exponent: 129, significand: 1.4693679385278592963715027508442290127277) // 10^38
let noDataValue = Double(sign: .minus, exponent: 129, significand: 1.5) // Value smaller than 10^38

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

protocol SHPFileRecord {
  var recordNumber: Int { get }
  static var shapeType: ShapeType { get }
  init(recordNumber: Int, data: Data, range: Range<Int>, endByte: inout Int) throws
}

// MARK: Null Shape

struct SHPFileNullShapeRecord {
  let recordNumber: Int

}
extension SHPFileNullShapeRecord: SHPFileRecord {
  static let shapeType = ShapeType.null

  init(recordNumber: Int, data: Data, range: Range<Int>, endByte: inout Int) {
    self.recordNumber = recordNumber
    endByte = 0
  }
}
