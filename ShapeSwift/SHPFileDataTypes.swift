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

extension BoundingBoxXY: ByteParseable {
  static let sizeBytes = Double.sizeBytes * 4
}

extension BoundingBoxXY: LittleEndianByteParseable {
  static func makeFromLittleEndian(data: NSData, start: Int) -> BoundingBoxXY? {
    return BoundingBoxXY(x: CoordinateBounds(min: Double.makeFromLittleEndian(data, start: start)!,
                                             max: Double.makeFromLittleEndian(data, start: start + Double.sizeBytes * 2)!),
                         y: CoordinateBounds(min: Double.makeFromLittleEndian(data, start: start + Double.sizeBytes)!,
                                             max: Double.makeFromLittleEndian(data, start: start + 3 * Double.sizeBytes)!))
  }
}

extension BoundingBoxXYZM: ByteParseable {
  static let sizeBytes = Double.sizeBytes * 8
}

extension BoundingBoxXYZM: LittleEndianByteParseable {
  static func makeFromLittleEndian(data: NSData, start: Int) -> BoundingBoxXYZM? {
    return BoundingBoxXYZM(x: CoordinateBounds(min: Double.makeFromLittleEndian(data, start: start)!,
                                               max: Double.makeFromLittleEndian(data, start: start + 2 * Double.sizeBytes)!),
                           y: CoordinateBounds(min: Double.makeFromLittleEndian(data, start: start + Double.sizeBytes)!,
                                               max: Double.makeFromLittleEndian(data, start: start + 3 * Double.sizeBytes)!),
                           z: CoordinateBounds(min: Double.makeFromLittleEndian(data, start: start + 4 * Double.sizeBytes)!,
                                               max: Double.makeFromLittleEndian(data, start: start + 5 * Double.sizeBytes)!),
                           m: CoordinateBounds(min: Double.makeFromLittleEndian(data, start: start + 6 * Double.sizeBytes)!,
                                               max: Double.makeFromLittleEndian(data, start: start + 7 * Double.sizeBytes)!))
  }
}

extension Coordinate: ByteParseable {
  static let sizeBytes = Double.sizeBytes * 2
}

extension Coordinate: LittleEndianByteParseable {
  static func makeFromLittleEndian(data: NSData, start: Int) -> Coordinate? {
    return Coordinate(x: Double.makeFromLittleEndian(data, start: start)!,
                      y: Double.makeFromLittleEndian(data, start: start + Double.sizeBytes)!)
  }
}

extension CoordinateBounds: ByteParseable {
  static let sizeBytes = Double.sizeBytes * 2
}

extension CoordinateBounds: LittleEndianByteParseable {
  static func makeFromLittleEndian(data: NSData, start: Int) -> CoordinateBounds? {
    return CoordinateBounds(min: Double.makeFromLittleEndian(data, start: start)!,
                            max: Double.makeFromLittleEndian(data, start: start + Double.sizeBytes)!)
  }
}

extension MultiPatchPartType: ByteParseable {
  static let sizeBytes = Int32.sizeBytes
}

extension MultiPatchPartType: LittleEndianByteParseable {
  static func makeFromLittleEndian(data: NSData, start: Int) -> MultiPatchPartType? {
    return MultiPatchPartType(rawValue: Int(Int32.makeFromLittleEndian(data, start: start)!))
  }
}

extension ShapeType: ByteParseable {
  static let sizeBytes = Int32.sizeBytes
}

extension ShapeType: LittleEndianByteParseable {
  static func makeFromLittleEndian(data: NSData, start: Int) -> ShapeType? {
    return ShapeType(rawValue: Int(Int32.makeFromLittleEndian(data, start: start)!))
  }
}
