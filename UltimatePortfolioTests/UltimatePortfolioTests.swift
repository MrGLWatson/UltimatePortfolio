//
//  UltimatePortfolioTests.swift
//  UltimatePortfolioTests
//
//  Created by Gary Watson on 13/01/2021.
//
import CoreData
import XCTest
@testable import UltimatePortfolio // allows us to look at all the objects in the app even if they are not public

class BaseTestCase: XCTestCase {
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}
