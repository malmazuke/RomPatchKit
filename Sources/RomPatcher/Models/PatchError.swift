//
//  PatchError.swift
//
//
//  Created by Mark Feaver on 25/4/2024.
//

public enum PatchError: Error {
    case invalidROMData
    case invalidPatchHeader
    case invalidPatchData
    case unexpectedPatchEOF
    case patchCorrupted
    case patchExceedsRomSize
    case rleBlockExceedsPatchSize
    case sizeMismatch
    case checksumMismatch
    case unknown
}
