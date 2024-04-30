//
//  IPSPatcher.swift
//
//
//  Created by Mark Feaver on 25/4/2024.
//

import Foundation

public final actor IPSPatcher: RomPatcher {

    private struct BlockDetails {
        let address: Int
        let length: Int
        let nextOffset: Int
    }

    private let patchHeader = "PATCH".data(using: .utf8)!
    private let eofMarker = "EOF".data(using: .utf8)!
    private let addressSize = 3
    private let blockSize = 2

    public func applyPatch(rom: Data, patch: Data) async throws -> Data {
        guard patch.starts(with: patchHeader) else {
            throw PatchError.invalidPatchHeader
        }

        var modifiedROM = rom

        var offset = patchHeader.count

        while offset < patch.count {
            if patch.subdata(in: offset..<offset + eofMarker.count) == eofMarker {
                break
            }

            guard offset + addressSize + blockSize <= patch.count else {
                throw PatchError.unexpectedPatchEOF
            }

            let block = try parseBlockDetails(from: patch, at: offset)
            offset = block.nextOffset

            if block.length > 0 {
                modifiedROM = try applyStandardPatch(from: patch, start: offset, length: block.length, to: modifiedROM, at: block.address)
                offset += block.length
            } else {
                modifiedROM = try applyRLEPatch(from: patch, start: offset, to: modifiedROM, at: block.address)
                offset += blockSize + 1
            }
        }

        return modifiedROM
    }

    private func parseBlockDetails(from patch: Data, at offset: Int) throws -> BlockDetails {
        let addressData = patch.subdata(in: offset..<(offset + addressSize))
        let address = Int(UInt32(addressData[0]) << 16 | UInt32(addressData[1]) << 8 | UInt32(addressData[2]))
        let lengthData = patch.subdata(in: (offset + addressSize)..<(offset + addressSize + blockSize))
        let length = Int(UInt16(lengthData[0]) << 8 | UInt16(lengthData[1]))
        return BlockDetails(address: address, length: length, nextOffset: offset + addressSize + blockSize)
    }

    private func applyStandardPatch(from patch: Data, start offset: Int, length: Int, to rom: Data, at address: Int) throws -> Data {
        guard offset + length <= patch.count, address + length <= rom.count else {
            throw PatchError.patchCorrupted
        }

        var modifiedROM = rom
        let dataToPatch = patch.subdata(in: offset..<(offset + length))
        modifiedROM.replaceSubrange(address..<(address + length), with: dataToPatch)
        return modifiedROM
    }

    private func applyRLEPatch(from patch: Data, start offset: Int, to rom: Data, at address: Int) throws -> Data {
        guard offset + blockSize + 1 <= patch.count else {
            throw PatchError.rleBlockExceedsPatchSize
        }

        let rleLengthData = patch.subdata(in: offset..<(offset + blockSize))
        let rleLength = Int(UInt16(rleLengthData[0]) << 8 | UInt16(rleLengthData[1]))
        let rleValue = patch[offset + blockSize]

        guard address + rleLength <= rom.count else {
            throw PatchError.patchExceedsRomSize
        }

        var modifiedROM = rom
        let rleData = Data(repeating: rleValue, count: rleLength)
        modifiedROM.replaceSubrange(address..<(address + rleLength), with: rleData)
        return modifiedROM
    }

}
