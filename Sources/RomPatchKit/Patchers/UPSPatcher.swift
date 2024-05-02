//
//  UPSPatcher.swift
//
//
//  Created by Mark Feaver on 29/4/2024.
//

import CryptoSwift
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

        let fileSizes = parseFileSizes(&patchData)

        guard rom.count == fileSizes.targetSize else {
            throw PatchError.sizeMismatch
        }

        var patchedRom = rom

        try applyDifferences(to: &patchedRom, with: &patchData)
        try verifyChecksums(original: rom, patched: patchedRom, patch: patch)

        return patchedRom
    }

    private func parseFileSizes(_ patch: inout Data) -> FileSizes {
        let sourceSize = Data.readVLI(from: &patch)
        let targetSize = Data.readVLI(from: &patch)

        return FileSizes(sourceSize: sourceSize, targetSize: targetSize)
    }

    private func applyDifferences(to rom: inout Data, with patchData: inout Data) throws {
        var index = 0

        while patchData.count > checksumSectionSize {
            let offset = Data.readVLI(from: &patchData)
            index += offset

            while let byte = patchData.first, byte != 0x00 {
                patchData.removeFirst()  // Remove the byte from patch data as it's going to be used.

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
            patchData.removeFirst()  // Remove the terminating 0x00 byte.
        }
    }

    private func verifyChecksums(original: Data, patched: Data, patch: Data) throws {
        // Assume the last 12 bytes of the patch are the three CRC32 values (each 4 bytes).
        guard patch.count >= checksumSectionSize else {
            throw PatchError.invalidPatchData
        }

        let originalCRC = original.crc32()
        let patchedCRC = patched.crc32()
        let patchCRC = patch.subdata(in: 0..<(patch.endIndex - 4)).crc32() // Exclude the checksum section from the data we're checking

        let expectedOriginalCRC = extractChecksum(patch: patch, offset: 0)
        let expectedPatchedCRC = extractChecksum(patch: patch, offset: 4)
        let expectedPatchCRC = extractChecksum(patch: patch, offset: 8)

        guard originalCRC == expectedOriginalCRC else {
            throw PatchError.checksumMismatch(type: "original", expected: expectedOriginalCRC.toHexString(), actual: originalCRC.toHexString())
        }
        guard patchedCRC == expectedPatchedCRC else {
            throw PatchError.checksumMismatch(type: "patched", expected: expectedPatchedCRC.toHexString(), actual: patchedCRC.toHexString())
        }
        guard patchCRC == expectedPatchCRC else {
            throw PatchError.checksumMismatch(type: "patch", expected: expectedPatchCRC.toHexString(), actual: patchCRC.toHexString())
        }
    }

    private func extractChecksum(patch: Data, offset: Int) -> Data {
        let sectionIndex = patch.index(patch.endIndex, offsetBy: -checksumSectionSize)
        let checksumIndex = sectionIndex + offset
        return Data(patch.subdata(in: checksumIndex..<(checksumIndex + 4)).reversed())
    }

}
