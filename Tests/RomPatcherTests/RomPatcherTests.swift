import XCTest
@testable import RomPatcher

final class RomPatcherTests: XCTestCase {

    var testSubject: RomPatcher!

    override func setUp() {
        testSubject = RomPatcher()
    }

    func testExample() throws {
        let aString = testSubject.giveMeAForest()
        XCTAssertEqual(aString, "This is a forest with a tree: This is a tree.")
    }
}
