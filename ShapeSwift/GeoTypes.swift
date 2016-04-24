//
//  GeoTypes.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 4/21/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import Foundation

struct RadianCoordinate {
  let x: Double
  let y: Double

  init(xDegrees: Double, yDegrees: Double) {
    x = xDegrees * M_PI / 180
    y = yDegrees * M_PI / 180
  }

  init(_ x: Double, _ y: Double) {
    self.x = x
    self.y = y
  }
}