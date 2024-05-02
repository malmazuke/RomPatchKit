//
//  RomPatcher.swift
//
//
//  Created by Mark Feaver on 25/4/2024.
//

import CryptoSwift
import Foundation

public protocol RomPatcher: Actor {

    func applyPatch(rom: Data, patch: Data) async throws -> Data

}

public extension RomPatcher {

    func applyPatch(romURL: URL, patchURL: URL) async throws -> Data {
        let romData = try Data(contentsOf: romURL)
        let patchData = try Data(contentsOf: patchURL)

        return try await applyPatch(rom: romData, patch: patchData)
    }

    static func extractRomDetails(romURL: URL) throws -> RomDetails {
        let romData = try Data(contentsOf: romURL)
            
        // TODO: Unarchive if necessary

        let crc32 = romData.crc32()
        let md5 = romData.md5()
        let sha1 = romData.sha1()

        return RomDetails(crc32: crc32, md5: md5, sha1: sha1)
    }

}
