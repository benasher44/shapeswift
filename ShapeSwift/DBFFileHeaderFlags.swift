//
//  DBFFileHeaderFlags.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 7/29/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

///
struct DBFFileHeaderFlags : OptionSet {
  let rawValue: Int
  init(rawValue: Int) { self.rawValue = rawValue }

  static let hasStructuralCDX = DBFFileHeaderFlags(rawValue: 1)
  static let hasMemoField = DBFFileHeaderFlags(rawValue: 2)
  static let isDatabaseDBC = DBFFileHeaderFlags(rawValue: 4)
}
