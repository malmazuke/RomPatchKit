//
//  RomPatcherFactory.swift
//
//
//  Created by Mark Feaver on 2/5/2024.
//

import Foundation
import ZIPFoundation

public class RomPatcherFactory {

    public static func createPatcher(for patchURL: URL) throws -> RomPatcher {
        let fileExtension = PatchFormat(rawValue: patchURL.pathExtension)

        switch fileExtension {
        case .bps:
            return BPSPatcher()
        case .ips:
            return IPSPatcher()
        case .ups:
            return UPSPatcher()
        case .xdelta:
            return XDeltaPatcher()
        default:
            throw PatchError.unsupportedPatchFormat
        }
    }


}
