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
    let fileCode = ByteParser<Int32, BigEndian>(start: 0)
    let fileLength = ByteParser<Int32, BigEndian>(start: 24)
    let version = ByteParser<Int32, LittleEndian>(start: 28)
    let shapeType = ByteParser<ShapeType, LittleEndian>(start: 32)
    let boundingBox = ByteParser<BoundingBoxXYZM, LittleEndian>(start: 36)
  }

  init(data: Data) throws {
    let parser = Parser()
    self.fileCode = try Int(parser.fileCode.parse(data))
    self.fileLength = try Int(parser.fileLength.parse(data)) * 2 // This value is the length in words, so multiply * 2 to get bytes
    self.version = try Int(parser.version.parse(data))
    self.shapeType = try parser.shapeType.parse(data)
    self.boundingBox = try parser.boundingBox.parse(data)
  }
}
