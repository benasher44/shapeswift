//
//  SHPFilePointZShape.swift
//  ShapeSwift
//
//  Created by Ben Asher on 8/25/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

struct SHPFilePointZShape {
  let x: Double
  let y: Double
  let z: Double
  let m: Double?
}

extension SHPFilePointZShape: SHPFileShape {
  typealias Record = SHPFilePointZRecord
}

extension SHPFilePointZRecord: SHPFileShapeConvertible {
  func makeShape() -> SHPFilePointZShape {
    return SHPFilePointZShape(x: x, y: y, z: z, m: m)
  }
}

