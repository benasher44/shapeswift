//
//  Projection.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 4/21/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import Foundation
import proj4

protocol Projection {
  var projInitArgs: String { get }
}

extension Projection {
  func convertForward(coordinates: [Coordinate], to: Projection) {

  }
}

struct SFSweepRoutesProjection: Projection {
  let projInitArgs = "+proj=lcc +lat_1=37.06666666666667 +lat_2=38.43333333333333 +lat_0=36.5 +lon_0=-120.5 +x_0=2000000 +y_0=500000.0000000001 +datum=NAD83 +units=us-ft +no_defs"
}

struct WGS84Projection: Projection {
  let projInitArgs = "+proj=latlong +ellps=WGS84"
}