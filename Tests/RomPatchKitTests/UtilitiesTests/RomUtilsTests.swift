import XCTest
@testable import RomPatchKit

final class RomUtilsTests: XCTestCase {

    private let expectedCRC32 = "ec4ac3d0"
    private let expectedMD5 = "65a8e27d8879283831b664bd8b7f0ad4"
    private let expectedSHA1 = "0a0a9f2a6772942557ab5355d76af442f8f65e01"

    func testRomDetailsAreCorrectlyExtracted() async {
        let romURL = Bundle.module.url(forResource: "test", withExtension: "rom")!

        let details = try! await RomUtils.extractRomDetails(romURL: romURL)

        XCTAssertEqual(details.crc32, expectedCRC32)
        XCTAssertEqual(details.md5String, expectedMD5)
        XCTAssertEqual(details.sha1String, expectedSHA1)
    }

}
