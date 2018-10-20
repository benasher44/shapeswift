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
    let fileInfo: ShapeDataParser<Byte, LittleEndian>

    // Date of last update; in YYMMDD format.  Each byte contains the number as a binary.  YY is added to a base of 1900 decimal to determine the actual year. Therefore, YY has possible values from 0x00-0xFF, which allows for a range from 1900-2155.
    let dateYear: ShapeDataParser<Byte, LittleEndian>
    let dateMonth: ShapeDataParser<Byte, LittleEndian>
    let dateDay: ShapeDataParser<Byte, LittleEndian>

    let numRecords: ShapeDataParser<Int32, LittleEndian>
    let length: ShapeDataParser<Int16, LittleEndian>
    let recordLength: ShapeDataParser<Int16, LittleEndian>

    let firstRecordPosition: ShapeDataParser<Int16, LittleEndian>

    // Flag indicating incomplete dBASE IV transaction.
    let transactionFlag: ShapeDataParser<Byte, LittleEndian>
    // dBASE IV encryption flag.
    let encryptionFlag: ShapeDataParser<Byte, LittleEndian>
    let productionMDXFlag: ShapeDataParser<Byte, LittleEndian>

    let driverIdentifier: ShapeDataParser<Byte, LittleEndian>
    let driverName: ShapeDataStringParser

    init(start: Int) {
      fileInfo = ShapeDataParser<Byte, LittleEndian>(start: start)
      dateYear = ShapeDataParser<Byte, LittleEndian>(start: fileInfo.end)
      dateMonth = ShapeDataParser<Byte, LittleEndian>(start: dateYear.end)
      dateDay = ShapeDataParser<Byte, LittleEndian>(start: dateMonth.end)

      numRecords = ShapeDataParser<Int32, LittleEndian>(start: dateDay.end)
      length = ShapeDataParser<Int16, LittleEndian>(start: numRecords.end)
      recordLength = ShapeDataParser<Int16, LittleEndian>(start: length.end)

      firstRecordPosition = ShapeDataParser<Int16, LittleEndian>(start: recordLength.end)
      transactionFlag = ShapeDataParser<Byte, LittleEndian>(start: firstRecordPosition.end + 2)
      encryptionFlag = ShapeDataParser<Byte, LittleEndian>(start: transactionFlag.end)
      productionMDXFlag = ShapeDataParser<Byte, LittleEndian>(start: encryptionFlag.end + 12)
      driverIdentifier = ShapeDataParser<Byte, LittleEndian>(start: productionMDXFlag.end)

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
