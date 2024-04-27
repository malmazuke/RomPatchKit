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

    public func applyPatch(romData: Data, patchData: Data) throws -> Data {
        guard patchData.starts(with: patchHeader) else {
            throw PatchError.invalidPatchHeader
        }

        var modifiedRomData = romData

        var offset = patchHeader.count

        while offset < patchData.count {
            // If next bytes at patch_offset match "EOF"
            if patchData.subdata(in: offset..<offset + eofMarker.count) == eofMarker {
                break
            }

            guard offset + addressSize + blockSize <= patchData.count else {
                throw PatchError.unexpectedPatchEOF
            }

            let addressData = patchData.subdata(in: offset..<(offset + addressSize))
            let address = Int(UInt32(addressData[0]) << 16 | UInt32(addressData[1]) << 8 | UInt32(addressData[2]))
            offset += addressSize

            let lengthData = patchData.subdata(in: (offset)..<(offset + blockSize))
            let length = Int(UInt16(lengthData[0]) << 8 | UInt16(lengthData[1]))
            offset += blockSize

            if length > 0 {
                guard offset + length <= patchData.count else {
                    throw PatchError.patchCorrupted
                }

                let dataToPatch = patchData.subdata(in: offset..<(offset + length))

                guard address + dataToPatch.count <= modifiedRomData.count else {
                    throw PatchError.patchExceedsRomSize
                }

                modifiedRomData.replaceSubrange(address..<(address + dataToPatch.count), with: dataToPatch)
                offset += length
            } else {
                guard offset + blockSize + 1 <= patchData.count else {
                    throw PatchError.rleBlockExceedsPatchSize
                }

                let rleLengthData = patchData.subdata(in: offset..<(offset + blockSize))
                let rleLength = Int(UInt16(rleLengthData[0]) << 8 | UInt16(rleLengthData[1]))
                let rleValue = patchData[offset + blockSize]

                guard address + rleLength <= modifiedRomData.count else {
                    throw PatchError.patchExceedsRomSize
                }

                let rleData = Data(repeating: rleValue, count: rleLength)
                modifiedRomData.replaceSubrange(address..<(address + rleLength), with: rleData)
                offset += blockSize + 1
            }
        }

        return modifiedRomData
    }

}
