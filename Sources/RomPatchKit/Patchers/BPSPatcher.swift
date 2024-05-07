//
//  BPSPatcher.swift
//
//
//  Created by Mark Feaver on 29/4/2024.
//

import Foundation

public final actor BPSPatcher: ChecksumContaining {

    private struct FileDetails {
        let sourceSize: Int
        let targetSize: Int
        let metadataSize: Int
    }

    let checksumSectionSize = 12

    private let patchHeader = "BPS1".data(using: .utf8)!

}

// MARK: - RomPatcher

extension BPSPatcher: RomPatcher {

    public func applyPatch(rom: Data, patch: Data) async throws -> Data {
        guard patch.starts(with: patchHeader) else {
            throw PatchError.invalidPatchHeader
        }

        var patchData = patch.dropFirst(patchHeader.count)
        let fileDetails = try parseFileDetails(&patchData)

        guard rom.count == fileDetails.sourceSize else {
            throw PatchError.sourceSizeMismatch
        }

        // Skip metadata
        patchData = patchData.dropFirst(fileDetails.metadataSize)

        var patchedRom = Data(count: fileDetails.targetSize)

        try applyPatch(from: rom, to: &patchedRom, with: &patchData)
        try await verifyChecksums(source: rom, target: patchedRom, patch: patch)

        guard patchedRom.count == fileDetails.targetSize else {
            throw PatchError.targetSizeMismatch
        }

        return patchedRom
    }

    private func parseFileDetails(_ patch: inout Data) throws -> FileDetails {
        let sourceSize = try Data.decodeNextVLI(from: &patch)
        let targetSize = try Data.decodeNextVLI(from: &patch)
        let metadataSize = try Data.decodeNextVLI(from: &patch)

        return FileDetails(sourceSize: sourceSize, targetSize: targetSize, metadataSize: metadataSize)
    }

    private func applyPatch(from source: Data, to target: inout Data, with patchData: inout Data) throws {
        var outputOffset = 0
        var sourceRelativeOffset = 0
        var targetRelativeOffset = 0

        while patchData.count > checksumSectionSize {
            let data = try Data.decodeNextVLI(from: &patchData)
            let command = data & 3
            let length = (data >> 2) + 1

            switch command {
            case 0: // SourceRead
                for _ in 0..<length {
                    target[outputOffset] = source[outputOffset]
                    outputOffset += 1
                }
            case 1: // TargetRead
                for _ in 0..<length {
                    let byte = patchData.removeFirst()
                    target[outputOffset] = byte
                    outputOffset += 1
                }
            case 2: // SourceCopy
                let offsetData = try Data.decodeNextVLI(from: &patchData)
                let sign = offsetData & 1
                let offset = offsetData >> 1

                sourceRelativeOffset += (sign == 1 ? -offset : offset)
                for _ in 0..<length {
                    target[outputOffset] = source[sourceRelativeOffset]
                    outputOffset += 1
                    sourceRelativeOffset += 1
                }
            case 3: // TargetCopy
                let offsetData = try Data.decodeNextVLI(from: &patchData)
                let sign = offsetData & 1
                let offset = offsetData >> 1

                targetRelativeOffset += (sign == 1 ? -offset : offset)
                for _ in 0..<length {
                    target[outputOffset] = target[targetRelativeOffset]
                    outputOffset += 1
                    targetRelativeOffset += 1
                }
            default:
                throw PatchError.invalidPatchCommand
            }
        }
    }

}
