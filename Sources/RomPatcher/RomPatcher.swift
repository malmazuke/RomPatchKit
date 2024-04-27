//
//  RomPatcher.swift
//
//
//  Created by Mark Feaver on 25/4/2024.
//

import Foundation

public protocol RomPatcher {

    func applyPatch(romData: Data, patchData: Data) throws -> Data

}

extension RomPatcher {

    public func applyPatch(romURL: URL, patchURL: URL) throws -> Data {
        let romData = try Data(contentsOf: romURL)
        let patchData = try Data(contentsOf: patchURL)

        return try applyPatch(romData: romData, patchData: patchData)
    }

}
