//
//  SHPFilePolyLineShape.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 8/12/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

protocol SHPFilePolyLineShapeProtocol {
  associatedtype Coordinate: Equatable
  init(boundingBox: BoundingBoxXY, lines: [Line<Coordinate>])
}

protocol SHPFilePolyLineShapeConvertible {
  associatedtype PolyLineShape: SHPFilePolyLineShapeProtocol
  var parts: [Int] { get }
  var pointCount: Int { get }
  var box: BoundingBoxXY { get }
  func coordinate(atIndex index: Int) -> PolyLineShape.Coordinate
}

extension SHPFilePolyLineShapeConvertible {
  func makeShape() -> PolyLineShape {
    var lines = [Line<PolyLineShape.Coordinate>]()
    lines.reserveCapacity(parts.count)
    var prevPart: Int? = nil
    for part in parts {
      if let prevPart = prevPart {
        let count = part - prevPart
        line(forPart: prevPart, count: count).flatMap({ lines.append($0) })
      }
      prevPart = part
    }
    // The above loop body won't operate on the last part, so create the last line
    if let lastPart = prevPart {
      let intLastPart = Int(lastPart)
      line(forPart: intLastPart, count: pointCount - intLastPart).flatMap({ lines.append($0) })
    }
    return PolyLineShape(boundingBox: box, lines: lines)
  }

  private func line(forPart part: Int, count: Int) -> Line<PolyLineShape.Coordinate>? {
    var points = Array<PolyLineShape.Coordinate>()
    points.reserveCapacity(count)
    // Build the part, but only inlude points, if the point is not a consecutive duplicate
    var lastPoint: PolyLineShape.Coordinate? = nil
    for i in part..<(part + count) {
      let point = coordinate(atIndex: i)
      switch lastPoint {
      case let .some(lastPoint) where point != lastPoint:
        fallthrough
      case .none:
        points.append(point)
        lastPoint = point
      default:
        break
      }
    }
    // Only return the part, if we didn't exclude so many points that there was only one point left
    if points.count > 1 {
      return Line(points: points)
    } else {
      return nil
    }
  }
}


// MARK: SHPFilePolyLineShape

struct SHPFilePolyLineShape {
  let boundingBox: BoundingBoxXY
  let lines: [Line<Coordinate2D>]
}

extension SHPFilePolyLineShape: SHPFileShape {
  typealias Record = SHPFilePolyLineRecord
}

extension SHPFilePolyLineShape: SHPFilePolyLineShapeProtocol {}

extension SHPFilePolyLineRecord: SHPFilePolyLineShapeConvertible {
  typealias PolyLineShape = SHPFilePolyLineShape

  var pointCount: Int {
    return points.count
  }

  func coordinate(atIndex index: Int) -> Coordinate2D {
    return points[index]
  }
}

extension SHPFilePolyLineRecord: SHPFileShapeConvertible {}


// MARK: SHPFilePolyLineZShape

struct SHPFilePolyLineZShape {
  let boundingBox: BoundingBoxXY
  let lines: [Line<Coordinate3D>]
}

extension SHPFilePolyLineZShape: SHPFileShape {
  typealias Record = SHPFilePolyLineZRecord
}

extension SHPFilePolyLineZShape: SHPFilePolyLineShapeProtocol {}

extension SHPFilePolyLineZRecord: SHPFilePolyLineShapeConvertible {
  typealias PolyLineShape = SHPFilePolyLineZShape

  var pointCount: Int {
    return points.count
  }

  func coordinate(atIndex index: Int) -> Coordinate3D {
    let point = points[index]
    return Coordinate3D(x: point.x, y: point.y, z: zValues[index])
  }
}

extension SHPFilePolyLineZRecord: SHPFileShapeConvertible {}
