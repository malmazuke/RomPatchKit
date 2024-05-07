//
//  UPSPatcher.swift
//
//
//  Created by Mark Feaver on 29/4/2024.
//

import Foundation

public final actor UPSPatcher: RomPatcher {

    private struct FileSizes {
        let sourceSize: Int
        let targetSize: Int
    }

    private let patchHeader = "UPS1".data(using: .utf8)!
    private let checksumSectionSize = 12

    public func applyPatch(rom: Data, patch: Data) async throws -> Data {
        guard patch.starts(with: patchHeader) else {
            throw PatchError.invalidPatchHeader
        }

        var patchData = patch.dropFirst(patchHeader.count)

        let fileSizes = try parseFileSizes(&patchData)

        guard rom.count == fileSizes.sourceSize else {
            throw PatchError.sourceSizeMismatch
        }

        var patchedRom = rom

        try applyDifferences(to: &patchedRom, with: &patchData)
        try await verifyChecksums(source: rom, target: patchedRom, patch: patch)

        guard patchedRom.count == fileSizes.targetSize else {
            throw PatchError.targetSizeMismatch
        }

        return patchedRom
    }

    public func getChecksums(from patch: Data) throws -> PatchChecksums? {
        guard patch.count > checksumSectionSize else {
            throw PatchError.unexpectedPatchEOF
        }

        let expectedSourceCRC = extractChecksum(patch: patch, offset: 0).toHexString()
        let expectedTargetCRC = extractChecksum(patch: patch, offset: 4).toHexString()
        let expectedPatchCRC = extractChecksum(patch: patch, offset: 8).toHexString()

        return PatchChecksums(sourceCRC32: expectedSourceCRC, targetCRC32: expectedTargetCRC, patchCRC32: expectedPatchCRC)
    }

    private func parseFileSizes(_ patch: inout Data) throws -> FileSizes {
        let sourceSize = try Data.decodeNextVLI(from: &patch)
        let targetSize = try Data.decodeNextVLI(from: &patch)

        return FileSizes(sourceSize: sourceSize, targetSize: targetSize)
    }

    private func applyDifferences(to rom: inout Data, with patchData: inout Data) throws {
        var index = 0

        while patchData.count > checksumSectionSize {
            let offset = try Data.decodeNextVLI(from: &patchData)
            index += offset

            while let byte = patchData.popFirst(), byte != 0x00 {
                // Ensure we do not write past the end of the original ROM.
                if index < rom.count {
                    rom[index] = rom[index] ^ byte // Apply the XOR operation.
                } else {
                    // If index is beyond the end of the ROM, XOR with 0x00.
                    rom.append(byte ^ 0x00) // Equivalent to just appending byte.
                }

                index += 1 // Move to the next position in the ROM.
            }

            guard patchData.isEmpty == false else {
                throw PatchError.unexpectedPatchEOF
            }
        }
    }

    private func verifyChecksums(source: Data, target: Data, patch: Data) async throws {
        // Ensure the patch data includes the checksum section
        let expectedChecksums = try getChecksums(from: patch)

        guard let expectedChecksums else {
            throw PatchError.invalidPatchData
        }

        async let sourceCRCTask = source.crc32()
        async let targetCRCTask = target.crc32()
        async let patchCRCTask = patch.subdata(in: 0..<(patch.count - 4)).crc32()

        let (sourceCRC, targetCRC, patchCRC) = await (sourceCRCTask, targetCRCTask, patchCRCTask)

        guard sourceCRC == expectedChecksums.sourceCRC32 else {
            throw PatchError.checksumMismatch(type: "original", expected: expectedChecksums.sourceCRC32, actual: sourceCRC)
        }
        guard targetCRC == expectedChecksums.targetCRC32 else {
            throw PatchError.checksumMismatch(type: "patched", expected: expectedChecksums.targetCRC32, actual: targetCRC)
        }
        guard patchCRC == expectedChecksums.patchCRC32 else {
            throw PatchError.checksumMismatch(type: "patch", expected: expectedChecksums.patchCRC32, actual: patchCRC)
        }
    }

    private func extractChecksum(patch: Data, offset: Int) -> Data {
        let sectionIndex = patch.index(patch.endIndex, offsetBy: -checksumSectionSize)
        let checksumIndex = sectionIndex + offset
        return Data(patch.subdata(in: checksumIndex..<(checksumIndex + 4)).reversed())
    }

}
