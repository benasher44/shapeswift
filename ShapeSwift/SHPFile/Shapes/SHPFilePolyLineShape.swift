//
//  SHPFilePolyLineShape.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 8/12/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

struct SHPFilePolyLineShape {
  let boundingBox: BoundingBoxXY
  let lines: [Line<Coordinate2D>]
}

extension SHPFilePolyLineShape: SHPFileShape {
  typealias Record = SHPFilePolyLineRecord
}

extension SHPFilePolyLineShape: SHPFilePolyShapeProtocol {
  init(boundingBox: BoundingBoxXY, subShapes: [Line<Coordinate2D>]) {
    self.boundingBox = boundingBox
    self.lines = subShapes
  }
}

extension SHPFilePolyLineRecord: SHPFilePolyShapeConvertible {
  typealias Shape = SHPFilePolyLineShape

  var pointCount: Int {
    return self.points.count
  }

  func coordinate(atIndex index: Int) -> Coordinate2D {
    return self.points[index]
  }
}

extension SHPFilePolyLineRecord: SHPFileShapeConvertible {}

// MARK: SHPFilePolyLineZShape

struct SHPFilePolyLineZShape {
  let boundingBox: BoundingBoxXY
  let lines: [Line<Coordinate4D>]
}

extension SHPFilePolyLineZShape: SHPFileShape {
  typealias Record = SHPFilePolyLineZRecord
}

extension SHPFilePolyLineZShape: SHPFilePolyShapeProtocol {
  init(boundingBox: BoundingBoxXY, subShapes: [Line<Coordinate4D>]) {
    self.boundingBox = boundingBox
    self.lines = subShapes
  }
}

extension SHPFilePolyLineZRecord: SHPFilePolyShapeConvertible {
  typealias Shape = SHPFilePolyLineZShape

  var pointCount: Int {
    return points.count
  }

  func coordinate(atIndex index: Int) -> Coordinate4D {
    let point = self.points[index]
    let m: Double?
    if !self.measures.isEmpty {
      m = self.measures[index]
    } else {
      m = nil
    }
    return Coordinate4D(x: point.x, y: point.y, z: self.zValues[index], m: m)
  }
}

extension SHPFilePolyLineZRecord: SHPFileShapeConvertible {}

// MARK: SHPFilePolyLineMShape

struct SHPFilePolyLineMShape {
  let boundingBox: BoundingBoxXY
  let lines: [Line<Coordinate3DM>]
}

extension SHPFilePolyLineMShape: SHPFileShape {
  typealias Record = SHPFilePolyLineMRecord
}

extension SHPFilePolyLineMShape: SHPFilePolyShapeProtocol {
  init(boundingBox: BoundingBoxXY, subShapes: [Line<Coordinate3DM>]) {
    self.boundingBox = boundingBox
    self.lines = subShapes
  }
}

extension SHPFilePolyLineMRecord: SHPFilePolyShapeConvertible {
  typealias Shape = SHPFilePolyLineMShape

  var pointCount: Int {
    return self.points.count
  }

  func coordinate(atIndex index: Int) -> Coordinate3DM {
    let point = self.points[index]
    let m: Double?
    if !self.measures.isEmpty {
      m = self.measures[index]
    } else {
      m = nil
    }
    return Coordinate3DM(x: point.x, y: point.y, m: m)
  }
}

extension SHPFilePolyLineMRecord: SHPFileShapeConvertible {}
