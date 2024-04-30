//
//  Data+calculateCRC32.swift
//  
//
//  Created by Mark Feaver on 30/4/2024.
//

import Foundation
import zlib

extension Data {

    static func calculateCRC32(data: Data) throws -> UInt32 {
        try data.withUnsafeBytes { rawBufferPointer in
            guard let baseAddress = rawBufferPointer.baseAddress else {
                throw PatchError.dataProcessingError("Unable to access data buffer base address.")
            }
            let bytePointer = baseAddress.assumingMemoryBound(to: Bytef.self)
            return UInt32(crc32(0, bytePointer, uInt(rawBufferPointer.count)))
        }
    }

}
