//
//  DataController.swift
//  UltimatePortfolio
//
//  Created by Gary Watson on 24/10/2020.
//

import CoreData
import SwiftUI

/// A class to handle reading or writing to the database.
/// An environment singleton responsible for managing our Core Data stack, including handing saving,
/// counting fetch requests, tracking awards, and dealing with sample data.
class DataController: ObservableObject {
    
    /// The lone cloudkit container used to store all our data.
    let container: NSPersistentCloudKitContainer
    
    /// Initialises a data controller either in memory (for temporary use such as testing and previewing).
    /// or on permanent storage (for use in regular app runs.)
    ///
    /// Defaults to permanent storage
    /// - Parameter inMemory: Whether to store this data in temporary memory or not.
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)
        // For testing and previewing purposes, we create a temporary,
        // in-memory database by writing to /dev/null so our data is destroyed
        // after the app finishes running.
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
            
            #if DEBUG
            if CommandLine.arguments.contains("enable-testing") {
                try?self.deleteAll()
                UIView.setAnimationsEnabled(false)
            }
            #endif
        }
    }
    
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        do {
            try dataController.createSampleData()
        } catch {
            fatalError("Fatal error creating preview: \(error.localizedDescription)")
        }
        return dataController
    }()
    
    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("Failed to locate model file")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }
        
        return managedObjectModel
    }()
    
    
    /// Creates example projects and items to make testing easier.
    /// - Throws: An NSError sent from calling save() on the NSManagedObjectContext
    func createSampleData() throws {
        let viewContext = container.viewContext  // pool of data from disk
        for projectCounter in 1...5 {
            let project = Project(context: viewContext)
            project.title = "Project \(projectCounter)"
            project.items = []
            project.creationDate = Date()
            project.closed = Bool.random()
            for itemCounter in 1...10 {
                let item = Item(context: viewContext)
                item.title = "Item \(itemCounter)"
                item.creationDate = Date()
                item.completed = Bool.random()
                item.project = project
                item.priority = Int16.random(in: 1...3)
            }
        }
        try viewContext.save()
    }
    
    /// Saves our Core Data context iff there are changes.  This silently ignores
    /// any errors caused by saving, but this should be fine because our
    /// attributes are optional.
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    func delete(_ object: NSManagedObject) {
        container.viewContext.delete(object)
    }
    func deleteAll() throws {
        let viewContext = container.viewContext  // pool of data from disk

        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
        let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        _ = try? container.viewContext.execute(batchDeleteRequest1)

        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Project.fetchRequest()
        let batchDeleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
        _ = try? container.viewContext.execute(batchDeleteRequest2)
        try viewContext.save()
    }
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }
    func hasEarned(award: Award) -> Bool {
        switch award.criterion {
        case "items":
            // retuns true if they added a certain numvber of items
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
        case "complete":
            // returns true if they completed a certain number of items
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            fetchRequest.predicate = NSPredicate(format: "completed = true")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
        default:
            // an unknown award criterion; this should never be allowed
 //           fatalError("Unknown award criterion: \(award.criterion)")
        return false // program is incomplete at the moment, remove this line and un comment above when complete
        }
    }
}
