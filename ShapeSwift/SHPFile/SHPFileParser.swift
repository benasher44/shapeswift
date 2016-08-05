//
//  SHPFileParser.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 3/30/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

private let headerRange = 0..<100

class SHPFileParser {
  private let data: Data
  private let header: SHPFileHeader
  private var currentByteOffset = 0

  init(fileURL: URL) throws {
    data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
    header = try SHPFileHeader(data: data)
    currentByteOffset = headerRange.upperBound
  }
}

extension SHPFileParser: IteratorProtocol {
  func next() -> SHPFileRecord? {
    if currentByteOffset < header.fileLength {
      let recordHeader = try! SHPFileRecordHeader(data: data, start: currentByteOffset)
      currentByteOffset += SHPFileRecordHeader.sizeBytes
      let shapeType = ShapeType(littleEndianData: data, start: currentByteOffset)!
      let recordStart = currentByteOffset + ShapeType.sizeBytes
      let record = try! parseRecord(forShapeType: shapeType, data: data, range: recordStart..<(currentByteOffset + recordHeader.contentLength))
      currentByteOffset += recordHeader.contentLength
      return record
    } else {
      return nil
    }
  }
}

func parseRecord(forShapeType shapeType: ShapeType, data: Data, range: Range<Int>) throws -> SHPFileRecord? {
  let type: SHPFileRecord.Type
  switch shapeType {
  case .null:
    type = SHPFileNullShapeRecord.self
  case .point:
    type = SHPFilePointRecord.self
  case .polyLine:
    type = SHPFilePolyLineRecord.self
  case .polygon:
    type = SHPFilePolygonRecord.self
  case .multiPoint:
    type = SHPFileMultiPointRecord.self
  case .pointZ:
    type = SHPFileMultiPointZRecord.self
  case .polyLineZ:
    type = SHPFilePolyLineZRecord.self
  case .polygonZ:
    type = SHPFilePolygonZRecord.self
  case .multiPointZ:
    type = SHPFileMultiPointZRecord.self
  case .pointM:
    type = SHPFilePointZRecord.self
  case .polyLineM:
    type = SHPFilePolyLineMRecord.self
  case .polygonM:
    type = SHPFilePolygonMRecord.self
  case .multiPointM:
    type = SHPFileMultiPointMRecord.self
  case .multiPatch:
    type = SHPFileMultiPatchRecord.self
  }
  var endByte = 0;
  let record = try type.init(data: data, range: range, endByte: &endByte)
  let byteRange: Range = range.lowerBound..<endByte + 1 // Skip the first 4 bytes because of the shape type
  if endByte == 0 {
    throw ByteParseableError.boundsUnchecked(type: type as! ByteParseable.Type)
  } else if (byteRange != range) {
    throw ByteParseableError.outOfBounds(expectedBounds: range, actualBounds: byteRange)
  }
  return record
}
