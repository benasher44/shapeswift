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
    case FoxBase
    case FoxBaseDBase3Plus
    case VisualFoxPro
    case VisualFoxProAutoIncrement
    case VisualFoxProVarChar
    case DBase4SQLTable
    case DBase4SQLSystem
    case FoxBaseDBase3PlusMemo
    case DBase4Memo
    case DBase4SQLTableMemo
    case FoxPro2WithMemo
    case HiPerSixSMTMemo
    case Unknown
}

extension DBFFileType: IntegerLiteralConvertible {
    init(integerLiteral value: Int) {
        switch value {
        case 0x02: self = .FoxBase
        case 0xfb: self = .FoxBase
        case 0x03: self = .FoxBaseDBase3Plus
        case 0x30: self = .VisualFoxPro
        case 0x31: self = .VisualFoxProAutoIncrement
        case 0x32: self = .VisualFoxProVarChar
        case 0x43: self = .DBase4SQLTable
        case 0x63: self = .DBase4SQLSystem
        case 0x83: self = .FoxBaseDBase3PlusMemo
        case 0x8b: self = .DBase4Memo
        case 0xcb: self = .DBase4SQLTableMemo
        case 0xf5: self = .FoxPro2WithMemo
        case 0xe5: self = .HiPerSixSMTMemo
        default: self = .Unknown
        }
    }
}

struct DBFFileHeaderFlags : OptionSetType {
    let rawValue: Int
    init(rawValue: Int) { self.rawValue = rawValue }
    
    static let HasStructuralCDX = DBFFileHeaderFlags(rawValue: 1)
    static let HasMemoField = DBFFileHeaderFlags(rawValue: 2)
    static let IsDatabaseDBC = DBFFileHeaderFlags(rawValue: 4)
}

struct DBFFileHeader {
    let fileType: DBFFileType
    let lastUpdated: NSDate
    let numRecords: Int
    let firstRecordPosition: Int
    let recordLength: Int // includes delete flag, which is the first byte in the record and ' ' if not deleted, '*' if deleted
    // todo: add file header flags
}
