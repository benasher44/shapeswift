//
//  String+DBFParsing.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 11/17/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

extension String {
  func nullStripped() -> String {
    guard let nullRange = self.range(of: "\0") else {
      return self
    }
    return String(self[..<nullRange.lowerBound])
  }
}
