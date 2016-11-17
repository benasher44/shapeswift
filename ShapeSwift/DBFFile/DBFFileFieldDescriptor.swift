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
    let fieldLength: ShapeDataParser<EndianAgnostic<Int8>>
    let decimalCount: ShapeDataParser<EndianAgnostic<Int8>>
    let productionMDXFlag: ShapeDataParser<EndianAgnostic<Bool>>
    let nextAutoIncrementValue: ShapeDataParser<LittleEndian<UInt32>>

    init(start: Int) {
      name = ShapeDataStringParser(start: start, count: 32, encoding: .ascii)
      type = ShapeDataStringParser(start: name.end, count: 1, encoding: .ascii)
      fieldLength = ShapeDataParser<EndianAgnostic<Int8>>(start: type.end)
      decimalCount = ShapeDataParser<EndianAgnostic<Int8>>(start: fieldLength.end)
      productionMDXFlag = ShapeDataParser<EndianAgnostic<Bool>>(start: decimalCount.end)

      // TODO(noah): this might need to be Int32 instead of UInt32
      nextAutoIncrementValue = ShapeDataParser<LittleEndian<UInt32>>(start: productionMDXFlag.end)
    }
  }
}
