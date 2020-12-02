import XCTest
@testable import LSAnimator
@testable import LSAnimatorCore

final class LSAnimatorTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        let view = UIView()
        let animator = CoreAnimator(view: view)
        animator.make(width: 0.3, height: 0.5).animate(t: 0.3)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
