//
//  SHPFilePolygonShape.swift
//  ShapeSwift
//
//  Created by Ben Asher on 9/2/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

struct SHPFilePolygonShape {
  let boundingBox: BoundingBoxXY
  let rings: [Ring<Coordinate2D>]
}

extension SHPFilePolygonShape: SHPFileShape {
  typealias Record = SHPFilePolygonRecord
}

extension SHPFilePolygonShape: SHPFilePolyShapeProtocol {
  init(boundingBox: BoundingBoxXY, subShapes: [Ring<Coordinate2D>]) {
    self.boundingBox = boundingBox
    self.rings = subShapes
  }
}

extension SHPFilePolygonRecord: SHPFilePolyShapeConvertible {
  typealias Shape = SHPFilePolygonShape

  var pointCount: Int {
    return points.count
  }

  func coordinate(atIndex index: Int) -> Coordinate2D {
    return self.points[index]
  }
}

extension SHPFilePolygonRecord: SHPFileShapeConvertible {}

// MARK: SHPFilePolygonZShape

struct SHPFilePolygonZShape {
  let boundingBox: BoundingBoxXY
  let rings: [Ring<Coordinate4D>]
}

extension SHPFilePolygonZShape: SHPFileShape {
  typealias Record = SHPFilePolygonZRecord
}

extension SHPFilePolygonZShape: SHPFilePolyShapeProtocol {
  init(boundingBox: BoundingBoxXY, subShapes: [Ring<Coordinate4D>]) {
    self.boundingBox = boundingBox
    self.rings = subShapes
  }
}

extension SHPFilePolygonZRecord: SHPFilePolyShapeConvertible {
  typealias Shape = SHPFilePolygonZShape

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

extension SHPFilePolygonZRecord: SHPFileShapeConvertible {}

// MARK: SHPFilePolygonMShape

struct SHPFilePolygonMShape {
  let boundingBox: BoundingBoxXY
  let rings: [Ring<Coordinate3DM>]
}

extension SHPFilePolygonMShape: SHPFileShape {
  typealias Record = SHPFilePolygonMRecord
}

extension SHPFilePolygonMShape: SHPFilePolyShapeProtocol {
  init(boundingBox: BoundingBoxXY, subShapes: [Ring<Coordinate3DM>]) {
    self.boundingBox = boundingBox
    self.rings = subShapes
  }
}

extension SHPFilePolygonMRecord: SHPFilePolyShapeConvertible {
  typealias Shape = SHPFilePolygonMShape

  var pointCount: Int {
    return self.points.count
  }

  func coordinate(atIndex index: Int) -> Coordinate3DM {
    let point = self.points[index]
    let m: Double?
    if !measures.isEmpty {
      m = measures[index]
    } else {
      m = nil
    }
    return Coordinate3DM(x: point.x, y: point.y, m: m)
  }
}

extension SHPFilePolygonMRecord: SHPFileShapeConvertible {}
