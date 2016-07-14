//
//  SHPFileParserDebugging.swift
//  ShapeSwift
//
//  Created by Ben Asher on 4/29/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import Foundation

extension Coordinate2DBounds: CustomDebugStringConvertible {
  var debugDescription: String {
    return "{\(min), \(max)}"
  }
}

extension BoundingBoxXYZM: CustomDebugStringConvertible {
  var debugDescription: String {
    return [
      "X: \(x)",
      "Y: \(y)",
      "Z: \(z)",
      "M: \(m)",
      ].joined(separator: " ")
  }
}

extension ShapeFileHeader: CustomDebugStringConvertible {
  var debugDescription: String {
    return [
      "File Code: \(fileCode)",
      "File Length: \(fileLength)",
      "Version: \(version)",
      "Shape Type: \(shapeType)",
      "Bounding Box: \(boundingBox.debugDescription)",
      ].joined(separator: "\n")
  }
}
