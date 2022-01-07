import XCTest

@testable import SwiftHelpers

final class SequenceTests: XCTestCase {
    func testCountWhere() throws {
        enum TestError: Error {
            case fail
        }

        let arr = [1, 2, 3, 4, 2, 4]
        XCTAssertEqual(arr.count(where: { $0 > 2 }), 3)
        try XCTAssertThrowsError(arr.count(where: { _ in throw TestError.fail }))
    }

    func testCountOf() {
        let arr = [1, 2, 3, 4, 2, 4]
        XCTAssertEqual(arr.count(of: 1), 1)
        XCTAssertEqual(arr.count(of: 2), 2)
        XCTAssertEqual(arr.count(of: 3), 1)
        XCTAssertEqual(arr.count(of: 4), 2)
    }
}
