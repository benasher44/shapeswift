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
  struct Parser {
    let fileCode = ShapeDataParser<BigEndian<Int32>>(start: 0)
    let fileLength = ShapeDataParser<BigEndian<Int32>>(start: 24)
    let version = ShapeDataParser<LittleEndian<Int32>>(start: 28)
    let shapeType = ShapeDataParser<LittleEndian<ShapeType>>(start: 32)
    let boundingBox = ShapeDataParser<LittleEndian<BoundingBoxXYZM>>(start: 36)
  }

  init(data: Data) throws {
    let parser = Parser()
    fileCode = try Int(parser.fileCode.parse(data))
    fileLength = try Int(parser.fileLength.parse(data))
    version = try Int(parser.version.parse(data))
    shapeType = try parser.shapeType.parse(data)
    boundingBox = try parser.boundingBox.parse(data)
  }
}
