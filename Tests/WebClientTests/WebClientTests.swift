import XCTest
@testable import WebClient

final class WebClientTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(WebClient().text, "Hello, World!")
    }
}
