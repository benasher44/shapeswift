//
//  SHPFilePointShape.swift
//  ShapeSwift
//
//  Created by Ben Asher on 8/25/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

struct SHPFilePointShape {
  let x: Double
  let y: Double
}

extension SHPFilePointShape: SHPFileShape {
  typealias Record = SHPFilePointRecord
}

extension SHPFilePointRecord: SHPFileShapeConvertible {
  func makeShape() -> SHPFilePointShape {
    return SHPFilePointShape(x: point.x, y: point.y)
  }
}

func == (lhs: SHPFilePointShape, rhs: SHPFilePointShape) -> Bool {
  return lhs.x == rhs.x && lhs.y == rhs.y
}

extension SHPFilePointShape: Equatable {}

