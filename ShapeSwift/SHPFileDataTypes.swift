//
//  SHPFileDataTypes.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 4/30/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

import Foundation

struct BoundingBoxXY {
  let x: CoordinateBounds
  let y: CoordinateBounds
}

struct BoundingBoxXYZM {
  let x: CoordinateBounds
  let y: CoordinateBounds
  let z: CoordinateBounds
  let m: CoordinateBounds
}

struct Coordinate {
  let x: Double
  let y: Double
}

struct CoordinateBounds {
  let min: Double
  let max: Double
}

enum MultiPatchPartType: Int {
  case triangleStrip = 0
  case triangleFan = 1
  case outerRing = 2
  case innerRing = 3
  case firstRing = 4
  case ring = 5
}

enum ShapeType: Int {
  case nullShape = 0
  case point = 1
  case polyLine = 3
  case polygon = 5
  case multiPoint = 8
  case pointZ = 11
  case polyLineZ = 13
  case polygonZ = 15
  case multiPointZ = 18
  case pointM = 21
  case polyLineM = 23
  case polygonM = 25
  case multiPointM = 28
  case multiPatch = 31
}


extension BoundingBoxXY: LittleEndianByteParseable {
  static func makeFromLittleEndian(data: NSData, range: Range<Int>) -> BoundingBoxXY? {
    let byteRange = (range.startIndex)..<(range.startIndex + 8)
    return BoundingBoxXY(x: CoordinateBounds(min: Double.makeFromLittleEndian(data, range: byteRange)!,
                                             max: Double.makeFromLittleEndian(data, range: byteRange.shifted(16))!),
                         y: CoordinateBounds(min: Double.makeFromLittleEndian(data, range: byteRange.shifted(8))!,
                                             max: Double.makeFromLittleEndian(data, range: byteRange.shifted(24))!))
  }
}

extension BoundingBoxXYZM: LittleEndianByteParseable {
  static func makeFromLittleEndian(data: NSData, range: Range<Int>) -> BoundingBoxXYZM? {
    let byteRange = (range.startIndex)..<(range.startIndex + 8)
    return BoundingBoxXYZM(x: CoordinateBounds(min: Double.makeFromLittleEndian(data, range: byteRange)!,
                                               max: Double.makeFromLittleEndian(data, range: byteRange.shifted(16))!),
                           y: CoordinateBounds(min: Double.makeFromLittleEndian(data, range: byteRange.shifted(8))!,
                                               max: Double.makeFromLittleEndian(data, range: byteRange.shifted(24))!),
                           z: CoordinateBounds(min: Double.makeFromLittleEndian(data, range: byteRange.shifted(32))!,
                                               max: Double.makeFromLittleEndian(data, range: byteRange.shifted(40))!),
                           m: CoordinateBounds(min: Double.makeFromLittleEndian(data, range: byteRange.shifted(48))!,
                                               max: Double.makeFromLittleEndian(data, range: byteRange.shifted(56))!))
  }
}

extension Coordinate: LittleEndianByteParseable {
  static func makeFromLittleEndian(data: NSData, range: Range<Int>) -> Coordinate? {
    let byteRange = (range.startIndex)..<(range.startIndex + 8)
    return Coordinate(x: Double.makeFromLittleEndian(data, range: byteRange)!,
                      y: Double.makeFromLittleEndian(data, range: byteRange.shifted(8))!)
  }
}

extension MultiPatchPartType: LittleEndianByteParseable {
  static func makeFromLittleEndian(data: NSData, range: Range<Int>) -> MultiPatchPartType? {
    return MultiPatchPartType(rawValue: Int(Int32.makeFromLittleEndian(data, range: range)!))
  }
}

extension ShapeType: LittleEndianByteParseable {
  static func makeFromLittleEndian(data: NSData, range: Range<Int>) -> ShapeType? {
    return ShapeType(rawValue: Int(Int32.makeFromLittleEndian(data, range: range)!))
  }
}
