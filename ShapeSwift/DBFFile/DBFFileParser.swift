//
//  DBFFileParser.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 4/6/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

// http://www.dbf2002.com/dbf-file-format.html
// Note that all values are stored in little endian byte order (least significant byte first)

// MARK: File header

private let headerRange = NSRange(location: 0, length: 32)

final class DBFFileParser {
  fileprivate let data: Data
  fileprivate let header: DBFFileHeader

  init(fileURL: URL) throws {
    self.data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
    self.header = try DBFFileHeader(data: data, start: 0)
  }
}
