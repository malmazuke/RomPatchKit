import XCTest
@testable import RomPatchKit

final class BPSPatcherTests: XCTestCase {

    private let patchExtension = "bps"
    private let romExtension = "rom"

    private var testSubject: BPSPatcher!
    private var romURL: URL!
    private var patchURL: URL!
    private var expectedRomURL: URL!

    private var largePatchURL: URL!
    private var expectedLargeROMURL: URL!

    override func setUp() {
        testSubject = BPSPatcher()

        let testBundle = Bundle.module

        romURL = testBundle.url(forResource: "test", withExtension: romExtension)!
        patchURL = testBundle.url(forResource: "patch", withExtension: patchExtension)!
        expectedRomURL = testBundle.url(forResource: "expected", withExtension: romExtension)!

        largePatchURL = testBundle.url(forResource: "patch-large", withExtension: patchExtension)!
        expectedLargeROMURL = testBundle.url(forResource: "expected-large", withExtension: romExtension)!
    }

    func testRomIsCorrectlyPatched() async throws {
        do {
            let patchedData = try await testSubject.applyPatch(romURL: romURL, patchURL: patchURL)
            let expectedData = try Data(contentsOf: expectedRomURL)

            let patchedContent = String(data: patchedData, encoding: .utf8)
            let expectedContent = String(data: expectedData, encoding: .utf8)
            XCTAssertEqual(patchedContent, expectedContent)
        } catch {
            XCTFail("Failed to apply patch: \(error)")
        }
    }

    func testLargerROMIsCorrectlyPatched() async throws {
        do {
            let patchedData = try await testSubject.applyPatch(romURL: romURL, patchURL: largePatchURL)
            let expectedData = try Data(contentsOf: expectedLargeROMURL)

            let patchedContent = String(data: patchedData, encoding: .utf8)
            let expectedContent = String(data: expectedData, encoding: .utf8)
            XCTAssertEqual(patchedContent, expectedContent)
        } catch {
            XCTFail("Failed to apply patch: \(error)")
        }
    }

}
