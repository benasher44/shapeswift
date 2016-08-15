//
//  SHPFilePolyLineShape.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 8/12/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

struct SHPFilePolyLineShape {
  let boundingBox: BoundingBoxXY
  let lines: [Line]
}

extension SHPFilePolyLineShape: SHPFileShape {
  typealias Record = SHPFilePolyLineRecord
}

extension SHPFilePolyLineRecord: SHPFileShapeConvertible {
  func makeShape() -> SHPFilePolyLineShape {
    var lines = [Line]()
    lines.reserveCapacity(parts.count)
    var prevPart: Int32? = nil
    for part in parts {
      if let prevPart = prevPart {
        let intPart = Int(prevPart)
        let count = Int(part) - intPart
        line(forPart: intPart, count: count).flatMap({ lines.append($0) })
      }
      prevPart = part
    }
    // The above loop body won't operate on the last part, so create the last line
    if let lastPart = prevPart {
      let intLastPart = Int(lastPart)
      line(forPart: intLastPart, count: self.points.count - intLastPart).flatMap({ lines.append($0) })
    }
    return SHPFilePolyLineShape(boundingBox: box, lines: lines)
  }

  private func line(forPart part: Int, count: Int) -> Line? {
    var points = [Coordinate2D]()
    points.reserveCapacity(count)
    // Build the part, but only inlude points, if the point is not a consecutive duplicate
    var lastPoint: Coordinate2D? = nil
    for i in part..<(part + count) {
      let point = self.points[i]
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
