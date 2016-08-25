//
//  SHPFilePointMShape.swift
//  ShapeSwift
//
//  Created by Ben Asher on 8/25/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

struct SHPFilePointMShape {
  let x: Double
  let y: Double
  let m: Double?
}

extension SHPFilePointMShape: SHPFileShape {
  typealias Record = SHPFilePointMRecord
}

extension SHPFilePointMRecord: SHPFileShapeConvertible {
  func makeShape() -> SHPFilePointMShape {
    return SHPFilePointMShape(x: x, y: y, m: m)
  }
}

func == (lhs: SHPFilePointMShape, rhs: SHPFilePointMShape) -> Bool {
  return lhs.x == rhs.x && lhs.y == rhs.y && lhs.m == rhs.m
}

extension SHPFilePointMShape: Equatable {}
