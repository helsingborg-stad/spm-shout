import XCTest
import Combine
@testable import Shout


var cancellables = Set<AnyCancellable>()
final class ShoutTests: XCTestCase {
    func testExample() {
        let expectation = XCTestExpectation(description: "testDatabase")
        let s = Shout("Testing")
        s.publisher.sink { event in
            expectation.fulfill()
        }.store(in: &cancellables)
        s.info("test")
        wait(for: [expectation], timeout: 4)
    }
}
