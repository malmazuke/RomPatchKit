//
//  ChecksumContaining.swift
//
//
//  Created by Mark Feaver on 7/5/2024.
//

import Foundation

public protocol ChecksumContaining<ChecksumSection>: Actor {

    associatedtype ChecksumSection

    var checksumSectionSize: Int { get }

    func getChecksums(from patch: Data) throws -> ChecksumSection

}

// MARK: - UPS/BPS Checksums

extension ChecksumContaining where ChecksumSection == UPSBPSPatchChecksums {

    public func getChecksums(from patch: Data) throws -> UPSBPSPatchChecksums {
        guard patch.count > checksumSectionSize else {
            throw PatchError.unexpectedPatchEOF
        }

        let expectedSourceCRC = extractChecksum(patch: patch, offset: 0).toHexString()
        let expectedTargetCRC = extractChecksum(patch: patch, offset: 4).toHexString()
        let expectedPatchCRC = extractChecksum(patch: patch, offset: 8).toHexString()

        return UPSBPSPatchChecksums(sourceCRC32: expectedSourceCRC, targetCRC32: expectedTargetCRC, patchCRC32: expectedPatchCRC)
    }

    func verifyChecksums(source: Data, target: Data, patch: Data) async throws {
        // Ensure the patch data includes the checksum section
        let expectedChecksums = try getChecksums(from: patch)

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
