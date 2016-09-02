//
//  SHPFileShapeDataTypes.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 8/14/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

struct Line<Point: Equatable> {
  let points: [Point]
}

struct Ring<Point: Equatable> {
  let points: [Point]
}

extension Line: SHPFilePolySubShape {
  typealias PointShape = Point
  static var minPoints: Int {
    return 2
  }
}

extension Ring: SHPFilePolySubShape {
  typealias PointShape = Point
  static var minPoints: Int {
    return 3
  }
}
