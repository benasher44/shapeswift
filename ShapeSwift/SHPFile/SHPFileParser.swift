//
//  SHPFileParser.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 3/30/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

private let headerRange = 0..<100

final class SHPFileParser<Shape: SHPFileShape> where Shape.Record: SHPFileShapeConvertible {
  fileprivate let data: Data
  fileprivate let header: SHPFileHeader
  fileprivate var currentByteOffset = 0

  init(fileURL: URL) throws {
    self.data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
    self.header = try SHPFileHeader(data: data)
    self.currentByteOffset = headerRange.upperBound
  }
}

enum SHPFileParseResult<Record: SHPFileRecord> {
  case nullShapeRecord(SHPFileNullShapeRecord)
  case shapeRecord(Record)
}

extension SHPFileParser: IteratorProtocol {
  typealias Record = Shape.Record

  func next() -> SHPFileParseResult<Record>? {
    if currentByteOffset < header.fileLength {
      let recordHeader = try! SHPFileRecordHeader(data: data, start: currentByteOffset)
      currentByteOffset += SHPFileRecordHeader.byteWidth
      let shapeType = ShapeType(littleEndianData: data, start: currentByteOffset)!
      let recordStart = currentByteOffset + ShapeType.byteWidth
      let recordRange: Range = recordStart..<(currentByteOffset + recordHeader.contentLength)
      currentByteOffset += recordHeader.contentLength
      if shapeType == .null {
        let nullShapeRecord: SHPFileNullShapeRecord = try! parseRecord(recordNumber: recordHeader.recordNumber,
                                                                       data: data,
                                                                       range: recordRange)!
        return .nullShapeRecord(nullShapeRecord)
      } else {
        let shapeRecord: Record = try! parseRecord(recordNumber: recordHeader.recordNumber,
                                                   data: data,
                                                   range: recordRange)!
        return .shapeRecord(shapeRecord)
      }
    } else {
      return nil
    }
  }
}

func parseRecord<Record: SHPFileRecord>(recordNumber: Int, data: Data, range: Range<Int>) throws -> Record? {
  var endByte = 0
  let record = try Record(recordNumber: recordNumber, data: data, range: range, endByte: &endByte)
  let byteRange: Range = range.lowerBound..<endByte + 1 // Skip the first 4 bytes because of the shape type
  if endByte == 0 {
    throw ByteParseableError.unknownBounds(type: Record.self)
  } else if byteRange != range {
    throw ByteParseableError.mismatchedBounds(
      type: Record.self,
      expectedBounds: range,
      actualBounds: byteRange
    )
  }
  return record
}
