import XCTest
@testable import RomPatcher

final class UPSPatcherTests: XCTestCase {

    private let patchExtension = "ups"
    private let romExtension = "rom"

    private var testSubject: UPSPatcher!
    private var romURL: URL!
    private var patchURL: URL!
    private var expectedRomURL: URL!

    override func setUp() {
        testSubject = UPSPatcher()

        let testBundle = Bundle.module

        romURL = testBundle.url(forResource: "test", withExtension: romExtension)!
        patchURL = testBundle.url(forResource: "patch", withExtension: patchExtension)!
        expectedRomURL = testBundle.url(forResource: "expected", withExtension: romExtension)!
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

}
