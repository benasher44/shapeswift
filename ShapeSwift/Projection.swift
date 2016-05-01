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

enum ProjectionConversionFunction: String {
  case pjInit = "pj_init_plus"
  case pjTransform = "pj_transform"
}

enum ProjectionConversionError: ErrorType {
  case error(errorNumber: Int32, function: ProjectionConversionFunction)
}

extension ProjectionConversionError: CustomDebugStringConvertible {
  var debugDescription: String {
    switch self {
    case let .error(errorNumber, function):
      let errStr = String.fromCString(pj_strerrno(errorNumber)) ?? ""
      return "\(function): \(errStr)"
    }
  }
}


extension Projection {
  func convertForward(coordinates: [Coordinate], to otherProjection: Projection) throws -> [Coordinate] {
    let src = pj_init_plus(projInitArgs.cStringUsingEncoding(NSUTF8StringEncoding)!)
    if let err = pjInitError {
      throw ProjectionConversionError.error(errorNumber: err, function: .pjInit)
    }
    let dest = pj_init_plus(otherProjection.projInitArgs.cStringUsingEncoding(NSUTF8StringEncoding)!)
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
      return Coordinate(x: x, y: y)
    }
  }
}

private extension Projection {
  var pjInitError: Int32? {
    let err = pj_get_default_ctx().memory.last_errno
    return err == 0 ? nil : err
  }
}
