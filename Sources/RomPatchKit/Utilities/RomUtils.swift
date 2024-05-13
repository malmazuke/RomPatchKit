//
//  RomUtils.swift
//
//
//  Created by Mark Feaver on 2/5/2024.
//

import CryptoKit
import Foundation
import ZIPFoundation
import zlib

public struct RomUtils: Sendable {

    /// Extracts a `RomDetails` object from a ROM at a given URL.
    ///
    /// The returned `RomDetails` object contains checksum details for verifying correct ROM/Patch matches.
    ///
    public static func extractRomDetails(romURL: URL) async throws -> RomDetails {
        let romData = try await Data.from(potentiallyZippedURL: romURL)

        async let crc32 = romData.crc32()
        async let md5 = Data(Insecure.MD5.hash(data: romData))
        async let sha1 = Data(Insecure.SHA1.hash(data: romData))

        return await RomDetails(crc32: crc32, md5: md5, sha1: sha1)
    }

    /// Extracts a ROM from a given `zip` file.
    ///
    /// Assumes that the name of the ROM matches the name of the archive (minus the extension).
    ///
    static func extractROMFromArchive(archiveURL: URL) async throws -> Data {
        let archive = try Archive(url: archiveURL, accessMode: .read)

        let rom = archive.first { entry in
            entry.path.contains(archiveURL.deletingPathExtension().lastPathComponent)
        }

        guard let rom else {
            throw PatchError.romNotFoundInArchive
        }

        return try await withCheckedThrowingContinuation { continuation in
            do {
                var romData = Data()
                _ = try archive.extract(rom, skipCRC32: true) { chunk in
                    romData.append(chunk)
                }
                continuation.resume(returning: romData)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

}

extension URL {

    var isZIP: Bool {
        self.pathExtension == "zip"
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
