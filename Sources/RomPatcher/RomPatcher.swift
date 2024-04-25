// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public protocol RomPatcher {

    func applyPatch(romData: Data, patchData: Data) throws -> Data

}
