//
//  PatchError.swift
//
//
//  Created by Mark Feaver on 25/4/2024.
//

// TODO: Split these into different error types
public enum PatchError: Error {
    case unsupportedPatchFormat
    case invalidROMData
    case invalidPatchHeader
    case invalidPatchData
    case unexpectedPatchEOF
    case patchCorrupted
    case patchExceedsRomSize
    case rleBlockExceedsPatchSize
    case sourceSizeMismatch
    case targetSizeMismatch
    case checksumMismatch(type: String, expected: String, actual: String)
    case dataProcessingError(String)
    case invalidPatchCommand
    case unknown
}
