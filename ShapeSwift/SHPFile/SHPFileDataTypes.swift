//
//  SHPFileDataTypes.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 4/30/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

struct BoundingBoxXY {
  let x: Coordinate2DBounds
  let y: Coordinate2DBounds
}

func == (lhs: BoundingBoxXY, rhs: BoundingBoxXY) -> Bool {
  return lhs.x == rhs.x && lhs.y == rhs.y
}

extension BoundingBoxXY: Equatable {}

struct BoundingBoxXYZM {
  let x: Coordinate2DBounds
  let y: Coordinate2DBounds
  let z: Coordinate2DBounds
  let m: Coordinate2DBounds
}

struct Coordinate2D {
  let x: Double
  let y: Double
}

struct Coordinate3D {
  let x: Double
  let y: Double
  let z: Double
}

func == (lhs: Coordinate2D, rhs: Coordinate2D) -> Bool {
  return lhs.x == rhs.x && lhs.y == rhs.y
}

extension Coordinate2D: Equatable {}

func == (lhs: Coordinate3D, rhs: Coordinate3D) -> Bool {
  return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
}

extension Coordinate3D: Equatable {}

struct Coordinate2DBounds {
  let min: Double
  let max: Double
}

func == (lhs: Coordinate2DBounds, rhs: Coordinate2DBounds) -> Bool {
  return lhs.min == rhs.min && lhs.max == rhs.max
}

extension Coordinate2DBounds: Equatable {}

enum MultiPatchPartType: Int {
  case triangleStrip = 0
  case triangleFan = 1
  case outerRing = 2
  case innerRing = 3
  case firstRing = 4
  case ring = 5
}

enum ShapeType: Int {
  case null = 0
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

extension BoundingBoxXY: ByteParseable {
  static let byteWidth = Double.byteWidth * 4
}

extension BoundingBoxXY: LittleEndianByteParseable {
  init?(littleEndianData data: Data, start: Int) {
    self = BoundingBoxXY(x: Coordinate2DBounds(min: Double(littleEndianData: data, start: start)!,
                                             max: Double(littleEndianData: data, start: start + Double.byteWidth * 2)!),
                         y: Coordinate2DBounds(min: Double(littleEndianData: data, start: start + Double.byteWidth)!,
                                             max: Double(littleEndianData: data, start: start + 3 * Double.byteWidth)!))
  }
}

extension BoundingBoxXYZM: ByteParseable {
  static let byteWidth = Double.byteWidth * 8
}

extension BoundingBoxXYZM: LittleEndianByteParseable {
  init?(littleEndianData data: Data, start: Int) {
    self = BoundingBoxXYZM(x: Coordinate2DBounds(min: Double(littleEndianData: data, start: start)!,
                                               max: Double(littleEndianData: data, start: start + 2 * Double.byteWidth)!),
                           y: Coordinate2DBounds(min: Double(littleEndianData: data, start: start + Double.byteWidth)!,
                                               max: Double(littleEndianData: data, start: start + 3 * Double.byteWidth)!),
                           z: Coordinate2DBounds(min: Double(littleEndianData: data, start: start + 4 * Double.byteWidth)!,
                                               max: Double(littleEndianData: data, start: start + 5 * Double.byteWidth)!),
                           m: Coordinate2DBounds(min: Double(littleEndianData: data, start: start + 6 * Double.byteWidth)!,
                                               max: Double(littleEndianData: data, start: start + 7 * Double.byteWidth)!))
  }
}

extension Coordinate2D: ByteParseable {
  static let byteWidth = Double.byteWidth * 2
}

extension Coordinate2D: LittleEndianByteParseable {
  init?(littleEndianData data: Data, start: Int) {
    self = Coordinate2D(x: Double(littleEndianData: data, start: start)!,
                      y: Double(littleEndianData: data, start: start + Double.byteWidth)!)
  }
}

extension Coordinate2DBounds: ByteParseable {
  static let byteWidth = Double.byteWidth * 2
}

extension Coordinate2DBounds: LittleEndianByteParseable {
  init?(littleEndianData data: Data, start: Int) {
    self = Coordinate2DBounds(min: Double(littleEndianData: data, start: start)!,
                            max: Double(littleEndianData: data, start: start + Double.byteWidth)!)
  }
}

extension MultiPatchPartType: ByteParseable {
  static let byteWidth = Int32.byteWidth
}

extension MultiPatchPartType: LittleEndianByteParseable {
  init?(littleEndianData data: Data, start: Int) {
    if let type = MultiPatchPartType(rawValue: Int(Int32(littleEndianData: data, start: start)!)) {
      self = type
    } else {
      return nil
    }
  }
}

extension ShapeType: ByteParseable {
  static let byteWidth = Int32.byteWidth
}

extension ShapeType: LittleEndianByteParseable {
  init?(littleEndianData data: Data, start: Int) {
    if let type = ShapeType(rawValue: Int(Int32(littleEndianData: data, start: start)!)) {
      self = type
    } else {
      return nil
    }
  }
}
