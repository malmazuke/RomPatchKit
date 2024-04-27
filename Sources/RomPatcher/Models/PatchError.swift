//
//  PatchError.swift
//
//
//  Created by Mark Feaver on 25/4/2024.
//

public enum PatchError: Error {
    // TODO: Add more cases once I know what I'm actually doing
    case invalidROMData
    case invalidPatchHeader
    case invalidPatchData
    case unexpectedPatchEOF
    case patchCorrupted
    case patchExceedsRomSize
    case rleBlockExceedsPatchSize
    case unknown
}
