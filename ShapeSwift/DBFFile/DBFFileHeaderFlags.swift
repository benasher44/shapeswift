//
//  DBFFileHeaderFlags.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 7/29/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

///
struct DBFFileHeaderFlags: OptionSet {
  let rawValue: Int
  init(rawValue: Int) { self.rawValue = rawValue }

  static let hasStructuralCDX = DBFFileHeaderFlags(rawValue: 1)
  static let hasMemoField = DBFFileHeaderFlags(rawValue: 1 << 1)
  static let isDatabaseDBC = DBFFileHeaderFlags(rawValue: 1 << 2)
  static let hasDBase4Transaction = DBFFileHeaderFlags(rawValue: 1 << 3)
  static let hasDBase4Encryption = DBFFileHeaderFlags(rawValue: 1 << 4)
  static let hasProductionMDX = DBFFileHeaderFlags(rawValue: 1 << 5)
}
