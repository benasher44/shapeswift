//
//  SHPFileShapeParser.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 11/10/18.
//  Copyright © 2018 Benjamin Asher. All rights reserved.
//

import Foundation

enum SHPFileParseResult<Shape: SHPFileShape> where Shape.Record: SHPFileShapeConvertible {
    case nullShapeRecord(SHPFileNullShapeRecord)
    case shapeRecord(Shape.Record)
}

typealias ShapeIteratorParser<Shape: SHPFileShape> = AnyIterator<SHPFileParseResult<Shape>> where Shape.Record: SHPFileShapeConvertible

extension SHPFileParser {

    func makeIteratorParser<Shape>() -> ShapeIteratorParser<Shape> {
        var currentByteOffset = SHPFile.headerRange.upperBound
        return AnyIterator {
            self._parseNextShape(
                currentByteOffset: &currentByteOffset
            )
        }
    }

    private func _parseNextShape<Shape>(
        currentByteOffset: inout Int
    ) -> SHPFileParseResult<Shape>? {
        if currentByteOffset < header.fileLength {
            let recordHeader = try! SHPFileRecordHeader(data: data, start: currentByteOffset)
            currentByteOffset += SHPFileRecordHeader.byteWidth
            let shapeType = ShapeType(littleEndianData: data, start: currentByteOffset)!
            let recordStart = currentByteOffset + ShapeType.byteWidth
            let recordRange: Range = recordStart..<(currentByteOffset + recordHeader.contentLength)
            currentByteOffset += recordHeader.contentLength
            if shapeType == .null {
                return .nullShapeRecord(
                    SHPFileNullShapeRecord(
                        recordNumber: recordHeader.recordNumber
                    )
                )
            } else {
                let shapeRecord: Shape.Record = try! _parseRecord(
                    recordNumber: recordHeader.recordNumber,
                    data: data,
                    range: recordRange,
                    forShapeOfType: Shape.self
                )!
                return .shapeRecord(shapeRecord)
            }
        } else {
            return nil
        }
    }
}

private func _parseRecord<Shape: SHPFileShape>(
    recordNumber: Int,
    data: Data,
    range: Range<Int>,
    forShapeOfType: Shape.Type
) throws -> Shape.Record? where Shape.Record: SHPFileShapeConvertible {
    var endByte = 0
    let record = try Shape.Record(recordNumber: recordNumber, data: data, range: range, endByte: &endByte)
    let byteRange: Range = range.lowerBound..<endByte + 1 // Skip the first 4 bytes because of the shape type
    if endByte == 0 {
        throw ByteParseableError.unknownBounds(type: Shape.Record.self)
    } else if byteRange != range {
        throw ByteParseableError.mismatchedBounds(
            type: Shape.Record.self,
            expectedBounds: range,
            actualBounds: byteRange
        )
    }
    return record
}
