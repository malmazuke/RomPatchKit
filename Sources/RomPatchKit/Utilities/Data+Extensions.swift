//
//  Data+Extensions.swift
//  
//
//  Created by Mark Feaver on 30/4/2024.
//

import Foundation

extension Data {

    static func decodeNextVLI(from data: inout Data) throws -> Int {
        var result = 0, shift = 1

        while true {
            guard data.isEmpty == false else {
                throw PatchError.unexpectedPatchEOF
            }

            let x = data.removeFirst()
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
