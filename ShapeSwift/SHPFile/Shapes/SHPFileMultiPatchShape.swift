//
//  SHPFileMultiPatchShape.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 10/20/18.
//  Copyright © 2018 Benjamin Asher. All rights reserved.
//

struct SHPFileMultiPatchShape {
  let bounds: BoundingBoxXY
  let zBounds: Coordinate2DBounds
  let mBounds: Coordinate2DBounds?

  let patches: [Patch]
}

extension SHPFileMultiPatchShape {
  struct Ring {
    typealias Ring = ShapeSwift.Ring<Coordinate4D>

    enum RingType {
      case outerRing
      case innerRing
      case firstRing
      case ring
    }

    let ring: Ring
    let ringType: RingType
  }

  enum Patch {
    case triangleStrip(points: [Coordinate4D])
    case triangleFan(points: [Coordinate4D])
    case ring(Ring)
    case ringSequence([Ring])
  }
}

extension SHPFileMultiPatchShape: SHPFileShape {
  typealias Record = SHPFileMultiPatchRecord
}

extension SHPFileMultiPatchRecord: SHPFileShapeConvertible {
  typealias Shape = SHPFileMultiPatchShape

  func makeShape() -> SHPFileMultiPatchShape {
    return SHPFileMultiPatchShape(
      bounds: self.box,
      zBounds: self.zBounds,
      mBounds: self.mBounds,
      patches: self.makePatches()
    )
  }

  private func makePatches() -> [SHPFileMultiPatchShape.Patch] {

    // collect the ranges of points for each patch
    var ranges = zip(self.parts, self.parts.dropFirst()).map {
      $0.0..<$0.1
    }
    // collect the range of points for the last patch
    if let last = self.parts.last {
      ranges.append(last..<self.points.count)
    }

    // keep track of the current ring sequence, as we collect patches (appending
    // each sequence as a patch, when we detect that the sequence has ended)
    var currentRingSequence: [SHPFileMultiPatchShape.Ring]?

    // helper typealias for initializing a ShapeSwift.Ring
    typealias Ring = ShapeSwift.Ring<Coordinate4D>

    // helper that adds to the current ring sequence or sets up a new one
    let addToRingSequence = { (ring: Ring, type: SHPFileMultiPatchShape.Ring.RingType) in
      currentRingSequence = currentRingSequence ?? [SHPFileMultiPatchShape.Ring]()
      currentRingSequence?.append(
        SHPFileMultiPatchShape.Ring(ring: ring, ringType: type)
      )
    }

    // patches to be collected from parts
    var patches = [SHPFileMultiPatchShape.Patch]()
    patches.reserveCapacity(self.partTypes.count)

    // helper that appends the ring sequence as a patch, if there was one in
    // progress
    let clearRingSequence = {
      if let currentRingSequence = currentRingSequence {
        if currentRingSequence.count == 1 {
          // if there's only one ring in the sequence, it's not a sequence
          patches.append(.ring(currentRingSequence[0]))
        } else {
          patches.append(.ringSequence(currentRingSequence))
        }
      }
      currentRingSequence = nil
    }

    let measures: [Double]? = self.measures.isEmpty ? nil : self.measures

    for (range, partType) in zip(ranges, self.partTypes) {
      let points: [Coordinate4D] = range.map {
        let point = self.points[$0]
        return Coordinate4D(
          x: point.x,
          y: point.y,
          z: self.zValues[$0],
          m: measures?[$0]
        )
      }

      switch partType {
      case .firstRing:
        addToRingSequence(Ring(points: points), .firstRing)
      case .innerRing:
        addToRingSequence(Ring(points: points), .innerRing)
      case .outerRing:
        addToRingSequence(Ring(points: points), .outerRing)
      case .ring:
        addToRingSequence(Ring(points: points), .ring)
      case .triangleFan:
        clearRingSequence()
        patches.append(.triangleFan(points: points))
      case .triangleStrip:
        clearRingSequence()
        patches.append(.triangleStrip(points: points))
      }
    }
    clearRingSequence()
    return patches
  }
}

