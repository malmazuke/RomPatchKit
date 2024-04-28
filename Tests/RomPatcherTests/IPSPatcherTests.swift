import XCTest
@testable import RomPatcher

final class IPSPatcherTests: XCTestCase {

    private let patchExtension = "ips"
    private let romExtension = "rom"

    private var testSubject: IPSPatcher!
    private var romURL: URL!
    private var patchURL: URL!
    private var expectedRomURL: URL!

    override func setUp() {
        testSubject = IPSPatcher()

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
