//
//  SHPFileIndex.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 11/8/18.
//  Copyright © 2018 Benjamin Asher. All rights reserved.
//

import Foundation

struct SHPFileIndexRecord {
    let recordNumber: Int
    let offset: Int
    let contentLength: Int
}

extension SHPFileIndexRecord {
    private struct Parser {
        let offset = ByteParser<Int32, BigEndian>(start: 0)
        let contentLength = ByteParser<Int32, BigEndian>(start: 4)
    }

    init(recordNumber: Int, data: Data, start: Int) throws {
        self.recordNumber = recordNumber

        let parser = Parser()
        self.offset = try Int(parser.offset.parse(data))
        self.contentLength = try Int(parser.contentLength.parse(data))
    }
}

extension SHPFileParser {

    func makeIndexRecordIteratorParser() -> AnyIterator<SHPFileIndexRecord> {
        var currentByteOffset = SHPFile.headerRange.upperBound
        var recordNumber = 0
        return AnyIterator {
            if currentByteOffset < self.header.fileLength {
                defer {
                    currentByteOffset += 8
                    recordNumber += 1
                }
                return try! SHPFileIndexRecord(
                    recordNumber: recordNumber,
                    data: self.data,
                    start: currentByteOffset
                )
            } else {
                return nil
            }
        }
    }
}
