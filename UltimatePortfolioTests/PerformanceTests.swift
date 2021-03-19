//
//  PerformanceTests.swift
//  UltimatePortfolioTests
//
//  Created by Gary Watson on 11/02/2021.
//

import XCTest
@testable import UltimatePortfolio

class PerformanceTests: BaseTestCase {
    func testAwardCalculationPerformance() throws {
        // crerate a significant amount of test data
        for _ in 1...100 {
            try dataController.createSampleData()
        }
        // Simulate lots of awards to check
        let awards = Array(repeating: Award.allAwards, count: 25).joined()
        // the joined makes this array of arrays into a single array
        XCTAssertEqual(awards.count, 500, "This checks the awards count is constant.  Change this if you add awards.")
        measure {
            _ = awards.filter(dataController.hasEarned)
        }
    }
}
