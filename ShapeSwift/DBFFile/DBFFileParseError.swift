//
//  DBFFileParseError.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 8/25/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

enum DBFFileParseError: Error {
  case invalidDate(dateComponents: DateComponents)
}
