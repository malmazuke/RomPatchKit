//
//  Data+Extensions.swift
//  
//
//  Created by Mark Feaver on 30/4/2024.
//

import Foundation

extension Data {

    static func from(potentiallyZippedURL url: URL) async throws -> Data {
        let romData: Data

        if url.isZIP {
            romData = try await RomUtils.extractROMFromArchive(archiveURL: url)
        } else {
            romData = try Data(contentsOf: url)
        }

        return romData
    }

    static func decodeNextVLI(from data: inout Data) throws -> Int {
        var result = 0, shift = 1

        while true {
            guard let x = data.popFirst() else {
                throw PatchError.unexpectedPatchEOF
            }
            result += Int(x & 0x7f) * shift

            if x & 0x80 != 0 {
                break
            }

            shift <<= 7
            result += shift
        }

        return result
    }

}
