//
//  UPSPatcher.swift
//
//
//  Created by Mark Feaver on 29/4/2024.
//

import Foundation

public final actor UPSPatcher: ChecksumContaining {

    private struct FileSizes {
        let sourceSize: Int
        let targetSize: Int
    }

    public let checksumSectionSize = 12

    private let patchHeader = "UPS1".data(using: .utf8)!

}

// MARK: - RomPatcher

extension UPSPatcher: RomPatcher {

    public func applyPatch(rom: Data, patch: Data) async throws -> Data {
        guard patch.starts(with: patchHeader) else {
            throw PatchError.invalidPatchHeader
        }

        var patchPointer = patch.startIndex + patchHeader.count
        let fileSizes = try parseFileSizes(patch, pointer: &patchPointer)

        guard rom.count == fileSizes.sourceSize else {
            throw PatchError.sourceSizeMismatch
        }

        let patchedRom = try applyDifferences(rom: rom, patch: patch, pointer: &patchPointer, targetSize: fileSizes.targetSize)

        try await verifyChecksums(source: rom, target: patchedRom, patch: patch)

        guard patchedRom.count == fileSizes.targetSize else {
            throw PatchError.targetSizeMismatch
        }

        return patchedRom
    }

    private func parseFileSizes(_ patch: Data, pointer: inout Int) throws -> FileSizes {
        let sourceSize = try Data.decodeVLI(from: patch, offset: &pointer)
        let targetSize = try Data.decodeVLI(from: patch, offset: &pointer)

        return FileSizes(sourceSize: sourceSize, targetSize: targetSize)
    }

    /// Each hunk consists of a variable-width integer indicating the number of bytes which should be skipped (copied verbatim from the source file),
    /// followed by a block of bytes which should be XORed with the source file to obtain a corresponding block of bytes in the destination file.
    /// The XOR block is terminated with a zero byte; the zero byte also counts against the file pointer.
    /// If the source and destination file sizes differ, the source file is treated as if it had an infinite number of zero bytes after its actual last byte.
    /// Source: http://fileformats.archiveteam.org/wiki/UPS_(binary_patch_format)
    /// 
    private func applyDifferences(rom: Data, patch: Data, pointer: inout Int, targetSize: Int) throws -> Data {
        var patchedRom = rom
        if rom.count < targetSize {
            patchedRom.append(contentsOf: repeatElement(UInt8(0), count: targetSize - rom.count))
        }
        var romIndex = rom.startIndex

        while pointer < patch.count - checksumSectionSize {
            let offset = try Data.decodeVLI(from: patch, offset: &pointer)
            romIndex += offset

            while patch[pointer] != 0x00 {
                let byte = patch[pointer]
                if romIndex < rom.count {
                    patchedRom[romIndex] ^= byte
                } else {
                    patchedRom[romIndex] = byte
                }
                pointer += 1
                romIndex += 1
            }

            pointer += 1
            romIndex += 1
        }

        return patchedRom
    }

}
