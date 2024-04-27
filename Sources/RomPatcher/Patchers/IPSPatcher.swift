//
//  IPSPatcher.swift
//
//
//  Created by Mark Feaver on 25/4/2024.
//

import Foundation

struct NotImplementedError: Error { }

public class IPSPatcher: RomPatcher {

    public func applyPatch(romURL: URL, patchURL: URL) throws -> Data {
        throw NotImplementedError()
    }

}
