import XCTest
@testable import RomPatchKit

final class RomPatcherFactoryTests: XCTestCase {

    func testUPS() throws {
        do {
            let patchURL = patchURL(forFileExtension: "ups")
            let patcher = try RomPatcherFactory.createPatcher(for: patchURL)

            XCTAssertTrue(type(of: patcher) == UPSPatcher.self)
        } catch {
            XCTFail("Unexpected Error: \(error)")
        }
    }

    func testIPS() throws {
        do {
            let patchURL = patchURL(forFileExtension: "ips")
            let patcher = try RomPatcherFactory.createPatcher(for: patchURL)

            XCTAssertTrue(type(of: patcher) == IPSPatcher.self)
        } catch {
            XCTFail("Unexpected Error: \(error)")
        }
    }

    func testBPS() throws {
        do {
            let patchURL = patchURL(forFileExtension: "bps")
            let patcher = try RomPatcherFactory.createPatcher(for: patchURL)

            XCTAssertTrue(type(of: patcher) == BPSPatcher.self)
        } catch {
            XCTFail("Unexpected Error: \(error)")
        }
    }

    func testXDelta() throws {
        do {
            let patchURL = patchURL(forFileExtension: "xdelta")
            let patcher = try RomPatcherFactory.createPatcher(for: patchURL)

            XCTAssertTrue(type(of: patcher) == XDeltaPatcher.self)
        } catch {
            XCTFail("Unexpected Error: \(error)")
        }
    }

    func testUnsupportedPatchFormat() throws {
        do {
            let patchURL = URL(string: "file:///patch.txt")!
            _ = try RomPatcherFactory.createPatcher(for: patchURL)

            XCTFail("Error was not thrown")
        } catch PatchError.unsupportedPatchFormat {
            // Do nothing
        } catch {
            XCTFail("Unexpected Error: \(error)")
        }
    }

    private func patchURL(forFileExtension fileExtension: String) -> URL {
        Bundle.module.url(forResource: "patch", withExtension: fileExtension.lowercased())!
    }
}
