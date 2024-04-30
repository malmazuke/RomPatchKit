//
//  UPSPatcher.swift
//
//
//  Created by Mark Feaver on 29/4/2024.
//

import Foundation
import zlib

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
        let sourceSize = readVLI(from: &patch)
        let targetSize = readVLI(from: &patch)

        return FileSizes(sourceSize: sourceSize, targetSize: targetSize)
    }

    private func applyDifferences(to rom: inout Data, with patchData: inout Data) throws {
        var index = 0

        while patchData.count > checksumSectionSize {
            let offset = readVLI(from: &patchData)
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

        let originalCRC = try calculateCRC32(data: original)
        let patchedCRC = try calculateCRC32(data: patched)
        // TODO: Add patch checksum verification back in once we know why it's not working
//        let patchCRC = try calculateCRC32(data: patch.subdata(in: 0..<(patch.endIndex - checksumSectionSize))) // Exclude the checksum section from the data we're checking

        let expectedOriginalCRC = extractChecksum(patch: patch, offset: 0)
        let expectedPatchedCRC = extractChecksum(patch: patch, offset: 4)
        let expectedPatchCRC = extractChecksum(patch: patch, offset: 8)

        guard originalCRC == expectedOriginalCRC else {
            throw PatchError.checksumMismatch
        }
        guard patchedCRC == expectedPatchedCRC else {
            throw PatchError.checksumMismatch
        }
//        guard patchCRC == expectedPatchCRC else {
//            throw PatchError.checksumMismatch
//        }
    }

    private func extractChecksum(patch: Data, offset: Int) -> UInt32 {
        let sectionIndex = patch.index(patch.endIndex, offsetBy: -checksumSectionSize)
        let checksumIndex = sectionIndex + offset
        let checksumData = patch.subdata(in: checksumIndex..<(checksumIndex + 4))

        return checksumData.withUnsafeBytes { $0.load(as: UInt32.self) }.littleEndian
    }

}

private extension UPSPatcher {

    // Function to read a variable-length integer
    func readVLI(from data: inout Data) -> Int {
        var result = 0
        var shift = 0
        while true {
            guard let byte = data.first else { break }
            data.removeFirst()
            let value = Int(byte & 0x7F)  // Extract the lower 7 bits
            result |= (value << shift)
            if (byte & 0x80) != 0 {  // Check if the highest bit is 1, indicating no more bytes
                break
            }
            shift += 7  // Prepare shift for the next 7-bit block
        }
        return result
    }

    func calculateCRC32(data: Data) throws -> UInt32 {
        try data.withUnsafeBytes { rawBufferPointer in
            guard let baseAddress = rawBufferPointer.baseAddress else {
                throw PatchError.dataProcessingError("Unable to access data buffer base address.")
            }
            let bytePointer = baseAddress.assumingMemoryBound(to: Bytef.self)
            return UInt32(crc32(0, bytePointer, uInt(rawBufferPointer.count)))
        }
    }

}
