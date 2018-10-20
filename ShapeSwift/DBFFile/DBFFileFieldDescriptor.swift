//
//  DBFFileFieldDescriptor.swift
//  ShapeSwift
//
//  Created by Noah Gilmore on 11/17/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

struct DBFFileFieldDescriptor {
  let name: String
  let type: DBFFileDataType
  let fieldLength: Int8
  let decimalCount: Int8
  let productionMDXFlag: Bool // Production MDX flag; 0x01 if a production .MDX file exists for this table; 0x00 if no .MDX file exists. Not sure what this means.
  let nextAutoIncrementValue: Int32
}

extension DBFFileFieldDescriptor {
  private struct Parser {
    let name: StringDataParser // note: need to account for zeros here. also it's 32 bytes
    let type: StringDataParser // only one character ASCII encoded string
    let fieldLength: ByteParseableDataParser<Int8, LittleEndian>
    let decimalCount: ByteParseableDataParser<Int8, LittleEndian>
    //TODO(noah): is this little endian or big endian?
    let productionMDXFlag: ByteParseableDataParser<Bool, LittleEndian>
    let nextAutoIncrementValue: ByteParseableDataParser<UInt32, LittleEndian>

    init(start: Int) {
      name = StringDataParser(start: start, count: 32, encoding: .ascii)
      type = StringDataParser(start: name.end, count: 1, encoding: .ascii)
      fieldLength = ByteParseableDataParser<Int8, LittleEndian>(start: type.end)
      decimalCount = ByteParseableDataParser<Int8, LittleEndian>(start: fieldLength.end)
      productionMDXFlag = ByteParseableDataParser<Bool, LittleEndian>(start: decimalCount.end)

      // TODO(noah): this might need to be Int32 instead of UInt32
      nextAutoIncrementValue = ByteParseableDataParser<UInt32, LittleEndian>(start: productionMDXFlag.end)
    }
  }
}
