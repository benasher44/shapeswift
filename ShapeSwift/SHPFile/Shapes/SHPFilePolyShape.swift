//
//  SHPFilePolyShape.swift
//  ShapeSwift
//
//  Created by Ben Asher on 9/2/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

protocol SHPFilePolySubShape {
  associatedtype PointShape: Equatable
  static var minPoints: Int { get }
  init(points: [PointShape])
}

protocol SHPFilePolyShapeProtocol {
  associatedtype PolySubShape: SHPFilePolySubShape
  init(boundingBox: BoundingBoxXY, subShapes: [PolySubShape])
}

protocol SHPFilePolyShapeConvertible {
  associatedtype Shape: SHPFilePolyShapeProtocol
  var parts: [Int] { get }
  var pointCount: Int { get }
  var box: BoundingBoxXY { get }
  func coordinate(atIndex index: Int) -> Shape.PolySubShape.PointShape
}

extension SHPFilePolyShapeConvertible {
  func makeShape() -> Shape {
    var subShapes = Array<Shape.PolySubShape>()
    subShapes.reserveCapacity(parts.count)
    var prevPart: Int? = nil
    for part in parts {
      if let prevPart = prevPart {
        let count = part - prevPart
        self.shape(forPart: prevPart, count: count).flatMap({ subShapes.append($0) })
      }
      prevPart = part
    }
    // The above loop body won't operate on the last part, so create the last line
    if let lastPart = prevPart {
      let intLastPart = Int(lastPart)
      self.shape(forPart: intLastPart, count: pointCount - intLastPart).flatMap({ subShapes.append($0) })
    }
    return Shape(boundingBox: box, subShapes: subShapes)
  }

  private func shape(forPart part: Int, count: Int) -> Shape.PolySubShape? {
    var points = Array<Shape.PolySubShape.PointShape>()
    points.reserveCapacity(count)
    // Build the part, but only include points, if the point is not a consecutive duplicate
    var lastPoint: Shape.PolySubShape.PointShape? = nil
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
    if points.count >= Shape.PolySubShape.minPoints {
      return Shape.PolySubShape(points: points)
    } else {
      return nil
    }
  }
}

