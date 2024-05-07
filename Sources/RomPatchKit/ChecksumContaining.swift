//
//  ChecksumContaining.swift
//
//
//  Created by Mark Feaver on 7/5/2024.
//

import Foundation

protocol ChecksumContaining<ChecksumSection>: Actor {

    associatedtype ChecksumSection

    var checksumSectionSize: Int { get }

    func getChecksums(from patch: Data) throws -> ChecksumSection

}

// MARK: - UPS/BPS Checksums

extension ChecksumContaining {

    func getChecksums(from patch: Data) throws -> UPSBPSPatchChecksums {
        guard patch.count > checksumSectionSize else {
            throw PatchError.unexpectedPatchEOF
        }

        let expectedSourceCRC = extractChecksum(patch: patch, offset: 0).toHexString()
        let expectedTargetCRC = extractChecksum(patch: patch, offset: 4).toHexString()
        let expectedPatchCRC = extractChecksum(patch: patch, offset: 8).toHexString()

        return UPSBPSPatchChecksums(sourceCRC32: expectedSourceCRC, targetCRC32: expectedTargetCRC, patchCRC32: expectedPatchCRC)
    }

    private func extractChecksum(patch: Data, offset: Int) -> Data {
        let sectionIndex = patch.index(patch.endIndex, offsetBy: -checksumSectionSize)
        let checksumIndex = sectionIndex + offset
        return Data(patch.subdata(in: checksumIndex..<(checksumIndex + 4)).reversed())
    }

}
