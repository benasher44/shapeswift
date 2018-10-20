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
  struct Parser {
    let name: ShapeDataStringParser // note: need to account for zeros here. also it's 32 bytes
    let type: ShapeDataStringParser // only one character ASCII encoded string
    let fieldLength: ShapeDataParser<Int8, LittleEndian>
    let decimalCount: ShapeDataParser<Int8, LittleEndian>
    let productionMDXFlag: ShapeDataParser<Bool, LittleEndian>
    let nextAutoIncrementValue: ShapeDataParser<UInt32, LittleEndian>

    init(start: Int) {
      name = ShapeDataStringParser(start: start, count: 32, encoding: .ascii)
      type = ShapeDataStringParser(start: name.end, count: 1, encoding: .ascii)
      fieldLength = ShapeDataParser<Int8, LittleEndian>(start: type.end)
      decimalCount = ShapeDataParser<Int8, LittleEndian>(start: fieldLength.end)
      productionMDXFlag = ShapeDataParser<Bool, LittleEndian>(start: decimalCount.end)

      // TODO(noah): this might need to be Int32 instead of UInt32
      nextAutoIncrementValue = ShapeDataParser<UInt32, LittleEndian>(start: productionMDXFlag.end)
    }
  }
}
