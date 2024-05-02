//
//  Data+Extensions.swift
//  
//
//  Created by Mark Feaver on 30/4/2024.
//

import Foundation

extension Data {

    static func readVLI(from data: inout Data) -> Int {
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

}
