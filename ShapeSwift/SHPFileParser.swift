//
//  SHPFileParser.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 3/30/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

private let headerRange = 0..<100

extension ShapeFileHeader {
  struct Parser {
    let fileCode = ShapeDataParser<BigEndian<Int32>>(start: 0)
    let fileLength = ShapeDataParser<BigEndian<Int32>>(start: 24)
    let version = ShapeDataParser<LittleEndian<Int32>>(start: 28)
    let shapeType = ShapeDataParser<LittleEndian<ShapeType>>(start: 32)
    let boundingBox = ShapeDataParser<LittleEndian<BoundingBoxXYZM>>(start: 36)
  }
}

struct ShapeFileHeader {
  let fileCode: Int
  let fileLength: Int
  let version: Int
  let shapeType: ShapeType
  let boundingBox: BoundingBoxXYZM
  init(data: Data) throws {
    let parser = Parser()
    fileCode = try Int(parser.fileCode.parse(data))
    fileLength = try Int(parser.fileLength.parse(data))
    version = try Int(parser.version.parse(data))
    shapeType = try parser.shapeType.parse(data)
    boundingBox = try parser.boundingBox.parse(data)
  }
}

extension ShapeFileRecordHeader {
  struct Parser {
    let recordNumber: ShapeDataParser<BigEndian<Int32>>
    let contentLength: ShapeDataParser<BigEndian<Int32>>
    init(start: Int) {
      recordNumber = ShapeDataParser<BigEndian<Int32>>(start: start)
      contentLength = ShapeDataParser<BigEndian<Int32>>(start: start + Int32.sizeBytes)
    }
  }
}

struct ShapeFileRecordHeader {
  let recordNumber: Int
  let contentLength: Int
  init(data: Data, start: Int) throws {
    let parser = Parser(start: start)
    recordNumber = try Int(parser.recordNumber.parse(data))
    contentLength = try Int(parser.contentLength.parse(data))
  }
}

public func parseFromURL(_ fileURL: URL) throws -> Void {
  let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
  let header = try ShapeFileHeader(data: data)
  print("header - \(header.debugDescription)")
}
