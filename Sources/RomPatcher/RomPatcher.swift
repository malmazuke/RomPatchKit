// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public protocol RomPatcher {

    func applyPatch(romURL: URL, patchURL: URL) throws -> Data

}
