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
  struct Parser {
    // note: everything in the header is little endian
    let fileInfo: ShapeDataParser<EndianAgnostic<Byte>>

    // Date of last update; in YYMMDD format.  Each byte contains the number as a binary.  YY is added to a base of 1900 decimal to determine the actual year. Therefore, YY has possible values from 0x00-0xFF, which allows for a range from 1900-2155.
    let dateYear: ShapeDataParser<EndianAgnostic<Byte>>
    let dateMonth: ShapeDataParser<EndianAgnostic<Byte>>
    let dateDay: ShapeDataParser<EndianAgnostic<Byte>>

    let numRecords: ShapeDataParser<LittleEndian<Int32>>
    let length: ShapeDataParser<LittleEndian<Int16>>
    let recordLength: ShapeDataParser<LittleEndian<Int16>>

    let firstRecordPosition: ShapeDataParser<LittleEndian<Int16>>

    // Flag indicating incomplete dBASE IV transaction.
    let transactionFlag: ShapeDataParser<EndianAgnostic<Byte>>
    // dBASE IV encryption flag.
    let encryptionFlag: ShapeDataParser<EndianAgnostic<Byte>>
    let productionMDXFlag: ShapeDataParser<EndianAgnostic<Byte>>

    let driverIdentifier: ShapeDataParser<EndianAgnostic<Byte>>
    let driverName: ShapeDataStringParser

    init(start: Int) {
      fileInfo = ShapeDataParser<EndianAgnostic<Byte>>(start: start)
      dateYear = ShapeDataParser<EndianAgnostic<Byte>>(start: fileInfo.end)
      dateMonth = ShapeDataParser<EndianAgnostic<Byte>>(start: dateYear.end)
      dateDay = ShapeDataParser<EndianAgnostic<Byte>>(start: dateMonth.end)

      numRecords = ShapeDataParser<LittleEndian<Int32>>(start: dateDay.end)
      length = ShapeDataParser<LittleEndian<Int16>>(start: numRecords.end)
      recordLength = ShapeDataParser<LittleEndian<Int16>>(start: length.end)

      firstRecordPosition = ShapeDataParser<LittleEndian<Int16>>(start: recordLength.end)
      transactionFlag = ShapeDataParser<EndianAgnostic<Byte>>(start: firstRecordPosition.end + 2)
      encryptionFlag = ShapeDataParser<EndianAgnostic<Byte>>(start: transactionFlag.end)
      productionMDXFlag = ShapeDataParser<EndianAgnostic<Byte>>(start: encryptionFlag.end + 12)
      driverIdentifier = ShapeDataParser<EndianAgnostic<Byte>>(start: productionMDXFlag.end)

      // TODO(noah): do we need a different encoding? probably ascii, everything else is ascii
      // TODO(noah): this "driver name" might not even exist, based on test data
      driverName = ShapeDataStringParser(start: driverIdentifier.end + 2, count: 32, encoding: .ascii)
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
    fileInfo = try parser.fileInfo.parse(data)

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
    lastUpdated = updatedDate

    numRecords = Int(try parser.numRecords.parse(data))
    length = Int(try parser.length.parse(data))
    recordLength = Int(try parser.recordLength.parse(data))

    firstRecordPosition = Int(try parser.firstRecordPosition.parse(data))
    transactionFlag = try parser.transactionFlag.parse(data)
    encryptionFlag = try parser.encryptionFlag.parse(data)
    driverIdentifier = try parser.driverIdentifier.parse(data)
    driverName = try parser.driverName.parse(data).nullStripped()
  }
}
