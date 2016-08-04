//
//  SHPFileParser.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 3/30/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

private let headerRange = 0..<100

public func parse(dataAtURL fileURL: URL) throws -> Void {
  let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
  let header = try SHPFileHeader(data: data)
  print("header - \(header.debugDescription)")
}
