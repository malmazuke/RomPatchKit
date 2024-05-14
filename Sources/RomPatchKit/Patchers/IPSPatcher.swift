//
//  IPSPatcher.swift
//
//
//  Created by Mark Feaver on 14/5/2024.
//

import Foundation

/// An IPS file starts with the magic number "PATCH" (50 41 54 43 48), followed by a series of hunks
/// and an end-of-file marker "EOF" (45 4f 46). All numerical values are unsigned and stored big-endian.
///
/// Regular hunks consist of a three-byte offset followed by a two-byte length of the payload and
/// the payload itself. Applying the hunk is done by writing the payload at the specified offset.
///
/// RLE hunks have their length field set to zero; in place of a payload there is a two-byte length of the run
/// followed by a single byte indicating the value to be written. Applying the RLE hunk is done by writing
/// this byte the specified number of times at the specified offset.
///
/// As an extension, the end-of-file marker may be followed by a three-byte length to which the
/// resulting file should be truncated. Not every patching program will implement this extension, however.
///
/// Source: http://justsolve.archiveteam.org/wiki/IPS_(binary_patch_format)
///
public final actor IPSPatcher: RomPatcher {

    /// IPS patches are small enough to warrant parsing the entire patch file before actually processing the patches
    ///
    private struct IPSPatch {
        
        struct Hunk {
            let offset: Int
            let type: HunkFormat

            enum HunkFormat {
                case regular(payloadLength: Int, payload: Data)
                case rle(runLength: Int, value: UInt8)
            }
            
            init(patch: Data, pointer: inout Int) throws {
                self.offset = try Hunk.readOffset(patch: patch, pointer: &pointer)

                let length = Int(try Hunk.readUInt16(patch: patch, pointer: &pointer))

                if length == 0 {
                    let runLength = Int(try Hunk.readUInt16(patch: patch, pointer: &pointer))

                    let value = patch[pointer]
                    pointer += 1
                    
                    self.type = .rle(runLength: runLength, value: value)
                } else {
                    guard pointer + length < patch.count else {
                        throw PatchError.unexpectedPatchEOF
                    }

                    let data = patch.subdata(in: pointer..<(pointer + length))
                    pointer += length

                    self.type = .regular(payloadLength: length, payload: data)
                }
            }

            private static func readOffset(patch: Data, pointer: inout Int) throws -> Int {
                guard pointer + 3 < patch.count else {
                    throw PatchError.unexpectedPatchEOF
                }

                // Bytes are in BigEndian
                let first = UInt32(patch[pointer]) << (2 * 8)
                pointer += 1

                let second = UInt32(patch[pointer]) << (1 * 8)
                pointer += 1

                let third = UInt32(patch[pointer]) << (0 * 8)
                pointer += 1

                return Int(first|second|third)
            }

            private static func readUInt16(patch: Data, pointer: inout Int) throws -> UInt16 {
                guard pointer + 2 < patch.count else {
                    throw PatchError.unexpectedPatchEOF
                }

                let first = UInt16(patch[pointer]) << (1 * 8)
                pointer += 1

                let second = UInt16(patch[pointer]) << (0 * 8)
                pointer += 1

                return UInt16(first|second)
            }

        }

        private(set) var hunks: [Hunk] = []

        private let header = "PATCH".data(using: .utf8)!
        private let eofMarker = "EOF".data(using: .utf8)!

        init(patch: Data) throws {
            guard patch.starts(with: header) else {
                throw PatchError.invalidPatchHeader
            }

            var pointer = patch.startIndex + header.count

            while pointer < patch.count {
                if patch.subdata(in: pointer..<(pointer + eofMarker.count)) == eofMarker {
                    break
                }

                let hunk = try Hunk(patch: patch, pointer: &pointer)
                self.hunks.append(hunk)
            }
        }
    }

    public func applyPatch(rom: Data, patch: Data) async throws -> Data {
        let ipsPatch = try IPSPatch(patch: patch)
        var modifiedROM = rom

        for hunk in ipsPatch.hunks {
            let payload: Data
            let length: Int
            switch hunk.type {
            case let .regular(payloadLength, regularPayload):
                payload = regularPayload
                length = payloadLength
            case let .rle(runLength, value):
                length = runLength
                payload = Data(repeating: value, count: runLength)
            }

            // If the patch data is bigger than the original ROM, resize the modified ROM
            if (hunk.offset + length) >= modifiedROM.count {
                modifiedROM.append(Data(count: hunk.offset + length - modifiedROM.count))
            }

            modifiedROM.replaceSubrange(hunk.offset..<(hunk.offset + length), with: payload)
        }

        return modifiedROM
    }

}
