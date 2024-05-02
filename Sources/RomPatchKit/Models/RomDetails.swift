//
//  RomDetails.swift
//
//
//  Created by Mark Feaver on 25/4/2024.
//

import Foundation

public struct RomDetails {

    var crc32: Data?
    var md5: Data?
    var sha1: Data?

}

public extension RomDetails {

    var crc32String: String? {
        crc32?.toHexString()
    }

    var md5String: String? {
        md5?.toHexString()
    }

    var sha1String: String? {
        sha1?.toHexString()
    }

}
