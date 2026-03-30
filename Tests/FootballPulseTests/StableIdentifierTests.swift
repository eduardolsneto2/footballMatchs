import XCTest
@testable import FootballPulse

final class StableIdentifierTests: XCTestCase {
    func testFNV1aWrappingMultiplyDoesNotTrapOnLongInput() {
        let slug = String(repeating: "x", count: 20_000)
        XCTAssertEqual(stableIdentifier(for: slug), stableIdentifier(for: slug))
    }

    func testSlugCRBIsDeterministic() {
        XCTAssertEqual(stableIdentifier(for: "crb"), stableIdentifier(for: "crb"))
    }
}
