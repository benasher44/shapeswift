//
//  Projection.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 4/21/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import proj4

protocol Projection {
  var projInitArgs: String { get }
}

enum ProjectionConversionFunction: String {
  case pjInit = "pj_init_plus"
  case pjTransform = "pj_transform"
}

enum ProjectionConversionError: Error {
  case error(errorNumber: Int32, function: ProjectionConversionFunction)
}

extension ProjectionConversionError: CustomDebugStringConvertible {
  var debugDescription: String {
    switch self {
    case let .error(errorNumber, function):
      let errStr = String(cString: pj_strerrno(errorNumber))
      return "\(function): \(errStr)"
    }
  }
}


extension Projection {
  func convertForward(_ coordinates: [Coordinate2D], to otherProjection: Projection) throws -> [Coordinate2D] {
    let src = pj_init_plus(projInitArgs.cString(using: String.Encoding.utf8)!)
    if let err = pjInitError {
      throw ProjectionConversionError.error(errorNumber: err, function: .pjInit)
    }
    let dest = pj_init_plus(otherProjection.projInitArgs.cString(using: String.Encoding.utf8)!)
    if let err = pjInitError {
      throw ProjectionConversionError.error(errorNumber: err, function: .pjInit)
    }
    return try coordinates.map { coordinate in
      var x = coordinate.x
      var y = coordinate.y
      let err = pj_transform(src, dest, 1, 1, &x, &y, nil)
      if err != 0 {
        throw ProjectionConversionError.error(errorNumber: err, function: .pjTransform)
      }
      return Coordinate2D(x: x, y: y)
    }
  }
}

private extension Projection {
  var pjInitError: Int32? {
    let err = pj_get_default_ctx().pointee.last_errno
    return err == 0 ? nil : err
  }
}
