//
//  DBFFileHeader.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 7/29/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

// TODO(noah): Bytes 32 and onward are different in each spec. We need to figure out how to differentiate
// them and parse them.

// http://www.dbf2002.com/dbf-file-format.html
// http://www.dbase.com/KnowledgeBase/int/db7_file_fmt.htm

extension DBFFileHeader {
  private struct Parser {
    // note: everything in the header is little endian
    let fileInfo: ByteParser<Byte, LittleEndian>

    // Date of last update; in YYMMDD format.  Each byte contains the number as a binary.  YY is added to a base of 1900 decimal to determine the actual year. Therefore, YY has possible values from 0x00-0xFF, which allows for a range from 1900-2155.
    let dateYear: ByteParser<Byte, LittleEndian>
    let dateMonth: ByteParser<Byte, LittleEndian>
    let dateDay: ByteParser<Byte, LittleEndian>

    let numRecords: ByteParser<Int32, LittleEndian>
    let length: ByteParser<Int16, LittleEndian>
    let recordLength: ByteParser<Int16, LittleEndian>

    let firstRecordPosition: ByteParser<Int16, LittleEndian>

    // Flag indicating incomplete dBASE IV transaction.
    let transactionFlag: ByteParser<Byte, LittleEndian>
    // dBASE IV encryption flag.
    let encryptionFlag: ByteParser<Byte, LittleEndian>
    let productionMDXFlag: ByteParser<Byte, LittleEndian>

    let driverIdentifier: ByteParser<Byte, LittleEndian>
    let driverName: StringDataParser

    init(start: Int) {
      self.fileInfo = ByteParser<Byte, LittleEndian>(start: start)
      self.dateYear = ByteParser<Byte, LittleEndian>(start: fileInfo.end)
      self.dateMonth = ByteParser<Byte, LittleEndian>(start: dateYear.end)
      self.dateDay = ByteParser<Byte, LittleEndian>(start: dateMonth.end)

      self.numRecords = ByteParser<Int32, LittleEndian>(start: dateDay.end)
      self.length = ByteParser<Int16, LittleEndian>(start: numRecords.end)
      self.recordLength = ByteParser<Int16, LittleEndian>(start: length.end)

      self.firstRecordPosition = ByteParser<Int16, LittleEndian>(start: recordLength.end)
      self.transactionFlag = ByteParser<Byte, LittleEndian>(start: firstRecordPosition.end + 2)
      self.encryptionFlag = ByteParser<Byte, LittleEndian>(start: transactionFlag.end)
      self.productionMDXFlag = ByteParser<Byte, LittleEndian>(start: encryptionFlag.end + 12)
      self.driverIdentifier = ByteParser<Byte, LittleEndian>(start: productionMDXFlag.end)

      // TODO(noah): do we need a different encoding? probably ascii, everything else is ascii
      // TODO(noah): this "driver name" might not even exist, based on test data
      self.driverName = StringDataParser(start: driverIdentifier.end + 2, count: 32)
    }
  }
}

/// Header record of a DBF file. Every DBF file regardless of version should have this.
struct DBFFileHeader {
  let fileInfo: Byte
  let lastUpdated: Date
  let numRecords: Int
  let length: Int // header length in bytes
  let firstRecordPosition: Int
  let recordLength: Int // includes delete flag, which is the first byte in the record and ' ' if not deleted, '*' if deleted
  let transactionFlag: Byte // "Flag indicating incomplete dBASE IV transaction."
  let encryptionFlag: Byte // "dBASE IV encryption flag."

  // this is in the specification but it's undocumented. One format spec calls it "code page mark" while
  // another calls it "Language driver ID". We probably don't care about it, but keep it here for good measure.
  let driverIdentifier: Byte
  let driverName: String

  init(data: Data, start: Int) throws {
    let parser = Parser(start: start)
    self.fileInfo = try parser.fileInfo.parse(data)

    let dateComponents = DateComponents(
      // From the spec: "YY is added to a base of 1900 decimal to determine the actual year."
      year: 1900 + Int(try parser.dateYear.parse(data)),
      month: Int(try parser.dateMonth.parse(data)),
      day: Int(try parser.dateDay.parse(data))
    )
    let calendar = Calendar(identifier: .gregorian)
    guard let updatedDate = calendar.date(from: dateComponents) else {
      throw DBFFileParseError.invalidDate(dateComponents: dateComponents)
    }
    self.lastUpdated = updatedDate

    self.numRecords = Int(try parser.numRecords.parse(data))
    self.length = Int(try parser.length.parse(data))
    self.recordLength = Int(try parser.recordLength.parse(data))

    self.firstRecordPosition = Int(try parser.firstRecordPosition.parse(data))
    self.transactionFlag = try parser.transactionFlag.parse(data)
    self.encryptionFlag = try parser.encryptionFlag.parse(data)
    self.driverIdentifier = try parser.driverIdentifier.parse(data)
    self.driverName = try parser.driverName.parseAsciiString(data)
  }
}
