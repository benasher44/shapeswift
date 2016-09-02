//
//  SHPFilePolygonShape.swift
//  ShapeSwift
//
//  Created by Ben Asher on 9/2/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

struct SHPFilePolygonShape {
  let boundingBox: BoundingBoxXY
  let rings: [Ring<SHPFilePointShape>]
}

extension SHPFilePolygonShape: SHPFileShape {
  typealias Record = SHPFilePolygonRecord
}

extension SHPFilePolygonShape: SHPFilePolyShapeProtocol {
  init(boundingBox: BoundingBoxXY, subShapes: [Ring<SHPFilePointShape>]) {
    self.boundingBox = boundingBox
    rings = subShapes
  }
}

extension SHPFilePolygonRecord: SHPFilePolyShapeConvertible {
  typealias Shape = SHPFilePolygonShape

  var pointCount: Int {
    return points.count
  }

  func coordinate(atIndex index: Int) -> SHPFilePointShape {
    let point = points[index]
    return SHPFilePointShape(x: point.x, y: point.y)
  }
}

extension SHPFilePolygonRecord: SHPFileShapeConvertible {}

// MARK: SHPFilePolygonZShape

struct SHPFilePolygonZShape {
  let boundingBox: BoundingBoxXY
  let rings: [Ring<SHPFilePointZShape>]
}

extension SHPFilePolygonZShape: SHPFileShape {
  typealias Record = SHPFilePolygonZRecord
}

extension SHPFilePolygonZShape: SHPFilePolyShapeProtocol {
  init(boundingBox: BoundingBoxXY, subShapes: [Ring<SHPFilePointZShape>]) {
    self.boundingBox = boundingBox
    rings = subShapes
  }
}

extension SHPFilePolygonZRecord: SHPFilePolyShapeConvertible {
  typealias Shape = SHPFilePolygonZShape

  var pointCount: Int {
    return points.count
  }

  func coordinate(atIndex index: Int) -> SHPFilePointZShape {
    let point = points[index]
    let m: Double?
    if !measures.isEmpty {
      m = measures[index]
    } else {
      m = nil
    }
    return SHPFilePointZShape(x: point.x, y: point.y, z: zValues[index], m: m)
  }
}

extension SHPFilePolygonZRecord: SHPFileShapeConvertible {}

// MARK: SHPFilePolygonMShape

struct SHPFilePolygonMShape {
  let boundingBox: BoundingBoxXY
  let rings: [Ring<SHPFilePointMShape>]
}

extension SHPFilePolygonMShape: SHPFileShape {
  typealias Record = SHPFilePolygonMRecord
}

extension SHPFilePolygonMShape: SHPFilePolyShapeProtocol {
  init(boundingBox: BoundingBoxXY, subShapes: [Ring<SHPFilePointMShape>]) {
    self.boundingBox = boundingBox
    rings = subShapes
  }
}

extension SHPFilePolygonMRecord: SHPFilePolyShapeConvertible {
  typealias Shape = SHPFilePolygonMShape

  var pointCount: Int {
    return points.count
  }

  func coordinate(atIndex index: Int) -> SHPFilePointMShape {
    let point = points[index]
    let m: Double?
    if !measures.isEmpty {
      m = measures[index]
    } else {
      m = nil
    }
    return SHPFilePointMShape(x: point.x, y: point.y, m: m)
  }
}

extension SHPFilePolygonMRecord: SHPFileShapeConvertible {}
