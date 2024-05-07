//
//  RomUtils.swift
//
//
//  Created by Mark Feaver on 2/5/2024.
//

import CryptoKit
import Foundation
import zlib

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
        let crc = self.withUnsafeBytes { buffer -> UInt32 in
            guard let baseAddress = buffer.baseAddress else { return 0 }
            return UInt32(zlib.crc32(0, baseAddress.assumingMemoryBound(to: Bytef.self), uInt(buffer.count)))
        }
        return String(format: "%08x", crc)
    }

    func toHexString() -> String {
        self.map { String(format: "%02x", $0) }.joined()
    }

}
