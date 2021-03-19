//
//  ExtensionTests.swift
//  UltimatePortfolioTests
//
//  Created by Gary Watson on 03/02/2021.
//
import SwiftUI
import XCTest
@testable import UltimatePortfolio

class ExtensionTests: XCTestCase {

    func testSequenceKeyPathSortingSelf() {
        let items = [1, 4, 3, 2, 5]
        let sortedItems = items.sorted(by: \.self) // sort using our own keyPath method
        XCTAssertEqual(sortedItems, [1, 2, 3, 4, 5], "The sorted numbers must be ascending.")
    }
    func testSequenceKeyPathSortingCustom() {
        struct Example: Equatable {
            let value: String
        }
        let example1 = Example(value: "a")
        let example2 = Example(value: "b")
        let example3 = Example(value: "c")
        let array = [example1, example2, example3]
        let sortedItems = array.sorted(by: \.value) {
            $0 > $1 // sort into decending order
        }
        XCTAssertEqual(sortedItems, [example3, example2, example1], "Reverse sorting should yied c, b, a.")
    }
    func testBundleDecodingAwards() {
        let awards = Bundle.main.decode([Award].self, from: "Awards.json")
        XCTAssertFalse(awards.isEmpty, "Awards.json should deocde to a non-empty array.")
    }
    func testDecodingString() {
        let bundle = Bundle(for: ExtensionTests.self)
        let data = bundle.decode(String.self, from: "DecodableString.json")
        XCTAssertEqual(data,
                       "The rain in Spain falls mainly on the Spaniards.",
                       "The string must match the context of the DecadableString.json.")
    }
    func testDecodingDictionary() {
        let bundle = Bundle(for: ExtensionTests.self)
        let data = bundle.decode([String: Int].self, from: "DecodableDictionary.json")
        XCTAssertEqual(data.count, 3, "There should be 3 items decoded from DecodableDictionart.json")
        XCTAssertEqual(data["One"], 1, "The dictionary should contain Int to String mappings.")
    }
    func testBindingOnChange() {
        // Given an example binding
        var onChangeFunctionRun = false
        func exampleFunctionToCall() {
            onChangeFunctionRun = true
        }
        var storedValue = ""
        let binding = Binding(
            get: { storedValue },
            set: { storedValue = $0 }
        )
        let changedBinding = binding.onChange(exampleFunctionToCall)
        // When we set changedBinding
        changedBinding.wrappedValue = "Test"
        // Then the example function should have been called.
        XCTAssertTrue(onChangeFunctionRun, "The onChange() function must bne run when the binding is changed.")
    }

}
