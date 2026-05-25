import XCTest
@testable import FlagsConsumer

final class FlagsConsumerTests: XCTestCase {

    func testGreetingUsesFlagsIOS() {
        let g = FlagsConsumer.greeting()
        XCTAssertTrue(g.contains("hello"))
        XCTAssertTrue(g.contains("FlagsIOS"))
    }

    func testIsNonEmpty() {
        XCTAssertTrue(FlagsConsumer.isNonEmpty("x"))
        XCTAssertFalse(FlagsConsumer.isNonEmpty("   "))
        XCTAssertFalse(FlagsConsumer.isNonEmpty(nil))
    }
}
