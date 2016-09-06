//
//  SHPFileMultiPointShape.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 9/5/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

// MARK: SHPFileMultiPointShape

struct SHPFileMultiPointMShape {
  let points: [SHPFilePointMShape]
}

extension SHPFileMultiPointMShape: SHPFileShape {
  typealias Record = SHPFileMultiPointRecord
}

extension SHPFileMultiPointMRecord: SHPFileShapeConvertible {
  func makeShape() -> SHPFileMultiPointMShape {
    return SHPFileMultiPointMShape(points: points.enumerated().map {
      SHPFilePointMShape(x: $1.x, y: $1.y, m: measures[$0])
    })
  }
}

// MARK: SHPFileMultiPointShape

struct SHPFileMultiPointShape {
  let points: [SHPFilePointShape]
}

extension SHPFileMultiPointShape: SHPFileShape {
  typealias Record = SHPFileMultiPointRecord
}

extension SHPFileMultiPointRecord: SHPFileShapeConvertible {
  func makeShape() -> SHPFileMultiPointShape {
    return SHPFileMultiPointShape(points: points.map {
      SHPFilePointShape(x: $0.x, y: $0.y)
    })
  }
}

// MARK: SHPFileMultiPointZShape

struct SHPFileMultiPointZShape {
  let points: [SHPFilePointZShape]
}

extension SHPFileMultiPointZShape: SHPFileShape {
  typealias Record = SHPFileMultiPointZRecord
}

extension SHPFileMultiPointZRecord: SHPFileShapeConvertible {
  func makeShape() -> SHPFileMultiPointZShape {
    return SHPFileMultiPointZShape(points: points.enumerated().map {
      SHPFilePointZShape(x: $1.x, y: $1.y, z: zValues[$0], m: measures[$0])
    })
  }
}

