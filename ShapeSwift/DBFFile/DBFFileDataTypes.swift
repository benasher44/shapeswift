//
//  DBFFileDataTypes.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 8/25/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

/// TODO(noah): some of these data types are probably not needed
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

extension DBFFileType: ExpressibleByIntegerLiteral {
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

/**
 * Available data types of a DBF file record, from the spec. Some of these make very little sense.
 */
enum DBFFileDataType: String {
  case binary = "B" // Binary, a string - 10 digits representing a .DBT block number. The number is stored as a string, right justified and padded with blanks.
  case character = "C" // Character - All OEM code page characters - padded with blanks to the width of the field.
  case date = "D" // Date - 8 bytes - date stored as a string in the format YYYYMMDD.
  case numeric = "N" // Numeric - Number stored as a string, right justified, and padded with blanks to the width of the field.
  case logical = "L" // Logical - 1 byte - initialized to 0x20 (space) otherwise T or F.
  case memo = "M" // Memo, a string - 10 digits (bytes) representing a .DBT block number. The number is stored as a string, right justified and padded with blanks.
  case timestamp = "@" // Timestamp - 8 bytes - two longs: date, time.  The date is the number of days since  01/01/4713 BC. Time is hours * 3600000L + minutes * 60000L + Seconds * 1000L
  case long = "I" // Long - 4 bytes. Leftmost bit used to indicate sign, 0 negative.
  case autoincrement = "+" // Autoincrement - Same as a Long
  case float = "F" // Float - Number stored as a string, right justified, and padded with blanks to the width of the field.
  case double = "O" // Double - 8 bytes - no conversions, stored as a double.
  case oLE = "G" // OLE - 10 digits (bytes) representing a .DBT block number. The number is stored as a string, right justified and padded with blanks.
}
