//
//  RomPatcher.swift
//
//
//  Created by Mark Feaver on 25/4/2024.
//

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

}
