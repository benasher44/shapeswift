//
//  DBFFileParser.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 4/6/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import Foundation

// http://www.dbf2002.com/dbf-file-format.html
// Note that all values are stored in little endian byte order (least significant byte first)

// MARK: File header

private let headerRange = NSRange(location: 0, length: 32)

/// From http://www.dbf2002.com/dbf-file-format.html
enum DBFFileType {
    case foxBase
    case foxBaseDBase3Plus
    case visualFoxPro
    case visualFoxProAutoIncrement
    case visualFoxProVarChar
    case dBase4SQLTable
    case dBase4SQLSystem
    case foxBaseDBase3PlusMemo
    case dBase4Memo
    case dBase4SQLTableMemo
    case foxPro2WithMemo
    case hiPerSixSMTMemo
    case unknown
}

extension DBFFileType: IntegerLiteralConvertible {
    init(integerLiteral value: Int) {
        switch value {
        case 0x02: self = .foxBase
        case 0xfb: self = .foxBase
        case 0x03: self = .foxBaseDBase3Plus
        case 0x30: self = .visualFoxPro
        case 0x31: self = .visualFoxProAutoIncrement
        case 0x32: self = .visualFoxProVarChar
        case 0x43: self = .dBase4SQLTable
        case 0x63: self = .dBase4SQLSystem
        case 0x83: self = .foxBaseDBase3PlusMemo
        case 0x8b: self = .dBase4Memo
        case 0xcb: self = .dBase4SQLTableMemo
        case 0xf5: self = .foxPro2WithMemo
        case 0xe5: self = .hiPerSixSMTMemo
        default: self = .unknown
        }
    }
}

struct DBFFileHeaderFlags : OptionSet {
    let rawValue: Int
    init(rawValue: Int) { self.rawValue = rawValue }
    
    static let HasStructuralCDX = DBFFileHeaderFlags(rawValue: 1)
    static let HasMemoField = DBFFileHeaderFlags(rawValue: 2)
    static let IsDatabaseDBC = DBFFileHeaderFlags(rawValue: 4)
}

struct DBFFileHeader {
    let fileType: DBFFileType
    let lastUpdated: Date
    let numRecords: Int
    let firstRecordPosition: Int
    let recordLength: Int // includes delete flag, which is the first byte in the record and ' ' if not deleted, '*' if deleted
    // todo: add file header flags
}
