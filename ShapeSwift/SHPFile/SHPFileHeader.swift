//
//  SHPFileHeader.swift
//  ShapeSwift
//
//  Created by Ben Asher on 8/4/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

struct SHPFileHeader {
  let fileCode: Int
  let fileLength: Int
  let version: Int
  let shapeType: ShapeType
  let boundingBox: BoundingBoxXYZM
}

extension SHPFileHeader {
  private struct Parser {
    let fileCode = ByteParseableDataParser<Int32, BigEndian>(start: 0)
    let fileLength = ByteParseableDataParser<Int32, BigEndian>(start: 24)
    let version = ByteParseableDataParser<Int32, LittleEndian>(start: 28)
    let shapeType = ByteParseableDataParser<ShapeType, LittleEndian>(start: 32)
    let boundingBox = ByteParseableDataParser<BoundingBoxXYZM, LittleEndian>(start: 36)
  }

  init(data: Data) throws {
    let parser = Parser()
    fileCode = try Int(parser.fileCode.parse(data))
    fileLength = try Int(parser.fileLength.parse(data)) * 2 // This value is the length in words, so multiply * 2 to get bytes
    version = try Int(parser.version.parse(data))
    shapeType = try parser.shapeType.parse(data)
    boundingBox = try parser.boundingBox.parse(data)
  }
}
