//
//  RomPatcher.swift
//
//
//  Created by Mark Feaver on 25/4/2024.
//

import Foundation

public protocol RomPatcher {

    func applyPatch(romURL: URL, patchURL: URL) throws -> Data

}
