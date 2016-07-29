//
//  SHPFileRecord.swift
//  ShapeSwift
//
//  Created by Ben Asher on 4/29/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

private let noDataValue: Double = -pow(10, 38)

func valueOrNilForOptionalValue(_ value: Coordinate2DBounds) -> Coordinate2DBounds? {
  if value.min < noDataValue || value.max < noDataValue {
    return nil
  } else {
    return value
  }
}

//TODO: remove
func valueOrNilForOptionalValue(_ value: Coordinate2D) -> Coordinate2D? {
  if value.x < noDataValue || value.x < noDataValue {
    return nil
  } else {
    return value
  }
}

// TODO(noah): rename this function
func valueOrNilForOptionalValue(_ value: Double) -> Double? {
  if value == noDataValue {
    return nil
  } else {
    return value
  }
}

func valueOrNoDataValueForOptionalValue(_ value: Double?) -> Double {
  if let value = value {
    return value
  }
  return noDataValue
}

protocol SHPFileRecord {
  init(data: Data, range: Range<Int>) throws
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
    return try type.init(data: data, range: range)
  }
}

