//
//  DBFFileParser.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 4/6/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

// http://www.dbf2002.com/dbf-file-format.html
// http://www.dbase.com/KnowledgeBase/int/db7_file_fmt.htm
// Note that all values are stored in little endian byte order (least significant byte first)

final class DBFFileParser {
  fileprivate let data: Data
  fileprivate let header: DBFFileHeader

  init(fileURL: URL) throws {
    data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
    header = try DBFFileHeader(data: data, start: 0)
  }
}
