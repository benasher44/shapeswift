//
//  SHPFileParser.swift
//  ShapeSwift
//
//  Created by Benjamin Asher on 3/30/16.
//  Copyright © 2016 Benjamin Asher. All rights reserved.
//

enum SHPFile {
    static let headerRange = 0..<100
}

final class SHPFileParser {
    let data: Data
    let header: SHPFileHeader

    init(fileURL: URL) throws {
        self.data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
        self.header = try SHPFileHeader(data: data)
    }
}
