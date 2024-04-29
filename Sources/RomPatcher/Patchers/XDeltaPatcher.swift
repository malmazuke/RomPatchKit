//
//  XDeltaPatcher.swift
//
//
//  Created by Mark Feaver on 29/4/2024.
//

import AblyDeltaCodec
import Foundation

public final actor XDeltaPatcher: RomPatcher {

    private let baseId = "m1"
    private let deltaId = "m2"

    public func applyPatch(rom: Data, patch: Data) async throws -> Data {
        let codec = ARTDeltaCodec()
        codec.setBase(rom, withId: baseId)

        return try codec.applyDelta(patch, deltaId: deltaId, baseId: baseId)
    }

}
