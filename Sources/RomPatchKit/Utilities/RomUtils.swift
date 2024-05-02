//
//  RomUtils.swift
//
//
//  Created by Mark Feaver on 2/5/2024.
//

import CryptoSwift
import Foundation

public struct RomUtils: Sendable {

    static func extractRomDetails(romURL: URL) throws -> RomDetails {
        let romData = try Data(contentsOf: romURL)

        // TODO: Unarchive if necessary

        let crc32 = romData.crc32()
        let md5 = romData.md5()
        let sha1 = romData.sha1()

        return RomDetails(crc32: crc32, md5: md5, sha1: sha1)
    }

}
