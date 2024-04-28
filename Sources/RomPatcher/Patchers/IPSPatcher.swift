//
//  IPSPatcher.swift
//
//
//  Created by Mark Feaver on 25/4/2024.
//

import Foundation

struct NotImplementedError: Error { }

public class IPSPatcher: RomPatcher {

    private let patchHeader = "PATCH".data(using: .utf8)!
    private let eofMarker = "EOF".data(using: .utf8)!
    private let addressSize = 3
    private let blockSize = 2

    public func applyPatch(rom: Data, patch: Data) throws -> Data {
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

            let addressData = patch.subdata(in: offset..<(offset + addressSize))
            let address = Int(UInt32(addressData[0]) << 16 | UInt32(addressData[1]) << 8 | UInt32(addressData[2]))
            offset += addressSize

            let lengthData = patch.subdata(in: (offset)..<(offset + blockSize))
            let length = Int(UInt16(lengthData[0]) << 8 | UInt16(lengthData[1]))
            offset += blockSize

            if length > 0 {
                guard offset + length <= patch.count else {
                    throw PatchError.patchCorrupted
                }

                let dataToPatch = patch.subdata(in: offset..<(offset + length))

                guard address + dataToPatch.count <= modifiedROM.count else {
                    throw PatchError.patchExceedsRomSize
                }

                modifiedROM.replaceSubrange(address..<(address + dataToPatch.count), with: dataToPatch)
                offset += length
            } else {
                guard offset + blockSize + 1 <= patch.count else {
                    throw PatchError.rleBlockExceedsPatchSize
                }

                let rleLengthData = patch.subdata(in: offset..<(offset + blockSize))
                let rleLength = Int(UInt16(rleLengthData[0]) << 8 | UInt16(rleLengthData[1]))
                let rleValue = patch[offset + blockSize]

                guard address + rleLength <= modifiedROM.count else {
                    throw PatchError.patchExceedsRomSize
                }

                let rleData = Data(repeating: rleValue, count: rleLength)
                modifiedROM.replaceSubrange(address..<(address + rleLength), with: rleData)
                offset += blockSize + 1
            }
        }

        return modifiedROM
    }

}
