//
//  SHPFileShape.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 8/12/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

protocol SHPFileShape {
  associatedtype Record: SHPFileRecord
}

protocol SHPFileShapeConvertible {
  associatedtype Shape: SHPFileShape
  func makeShape() -> Shape
}
