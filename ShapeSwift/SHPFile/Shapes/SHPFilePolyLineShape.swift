//
//  SHPFilePolyLineShape.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 8/12/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

struct SHPFilePolyLineShape {
  let boundingBox: BoundingBoxXY
  let lines: [Line<SHPFilePointShape>]
}

extension SHPFilePolyLineShape: SHPFileShape {
  typealias Record = SHPFilePolyLineRecord
}

extension SHPFilePolyLineShape: SHPFilePolyShapeProtocol {
  init(boundingBox: BoundingBoxXY, subShapes: [Line<SHPFilePointShape>]) {
    self.boundingBox = boundingBox
    self.lines = subShapes
  }
}

extension SHPFilePolyLineRecord: SHPFilePolyShapeConvertible {
  typealias Shape = SHPFilePolyLineShape

  var pointCount: Int {
    return points.count
  }

  func coordinate(atIndex index: Int) -> SHPFilePointShape {
    let point = points[index]
    return SHPFilePointShape(x: point.x, y: point.y)
  }
}

extension SHPFilePolyLineRecord: SHPFileShapeConvertible {}

// MARK: SHPFilePolyLineZShape

struct SHPFilePolyLineZShape {
  let boundingBox: BoundingBoxXY
  let lines: [Line<SHPFilePointZShape>]
}

extension SHPFilePolyLineZShape: SHPFileShape {
  typealias Record = SHPFilePolyLineZRecord
}

extension SHPFilePolyLineZShape: SHPFilePolyShapeProtocol {
  init(boundingBox: BoundingBoxXY, subShapes: [Line<SHPFilePointZShape>]) {
    self.boundingBox = boundingBox
    self.lines = subShapes
  }
}

extension SHPFilePolyLineZRecord: SHPFilePolyShapeConvertible {
  typealias Shape = SHPFilePolyLineZShape

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

extension SHPFilePolyLineZRecord: SHPFileShapeConvertible {}

// MARK: SHPFilePolyLineMShape

struct SHPFilePolyLineMShape {
  let boundingBox: BoundingBoxXY
  let lines: [Line<SHPFilePointMShape>]
}

extension SHPFilePolyLineMShape: SHPFileShape {
  typealias Record = SHPFilePolyLineMRecord
}

extension SHPFilePolyLineMShape: SHPFilePolyShapeProtocol {
  init(boundingBox: BoundingBoxXY, subShapes: [Line<SHPFilePointMShape>]) {
    self.boundingBox = boundingBox
    self.lines = subShapes
  }
}

extension SHPFilePolyLineMRecord: SHPFilePolyShapeConvertible {
  typealias Shape = SHPFilePolyLineMShape

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

extension SHPFilePolyLineMRecord: SHPFileShapeConvertible {}
