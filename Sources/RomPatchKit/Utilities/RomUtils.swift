//
//  RomUtils.swift
//
//
//  Created by Mark Feaver on 2/5/2024.
//

import CRC
import CryptoKit
import Foundation

public struct RomUtils: Sendable {

    public static func extractRomDetails(romURL: URL) async throws -> RomDetails {
        let romData = try Data(contentsOf: romURL)

        // TODO: Unarchive if necessary

        async let crc32 = romData.crc32()
        async let md5 = Data(Insecure.MD5.hash(data: romData))
        async let sha1 = Data(Insecure.SHA1.hash(data: romData))

        return await RomDetails(crc32: crc32, md5: md5, sha1: sha1)
    }

}

extension Data {

    func crc32() -> String {
        CRC32(hashing: self).description
    }

    func toHexString() -> String {
        self.map { String(format: "%02x", $0) }.joined()
    }

}
