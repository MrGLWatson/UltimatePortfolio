//
//  DataController.swift
//  UltimatePortfolio
//
//  Created by Gary Watson on 24/10/2020.
//

import CoreData
import CoreSpotlight
import SwiftUI
import WidgetKit

/// A class to handle reading or writing to the database.
/// An environment singleton responsible for managing our Core Data stack, including handing saving,
/// counting fetch requests, tracking awards, and dealing with sample data.
class DataController: ObservableObject {
    /// The lone cloudkit container used to store all our data.
    let container: NSPersistentCloudKitContainer
    /// Initialises a data controller either in memory (for temporary use such as testing and previewing).
    /// or on permanent storage (for use in regular app runs.)

    /// The UserDefaults suite where we're saving user data
    let defaults: UserDefaults

    /// loads and saves whether our premium unlock has been purchased
    var fullVersionUnlocked: Bool {
        get {
            defaults.bool(forKey: "fullVersionUnlocked")
        }

        set {
            defaults.set(newValue, forKey: "fullVersionUnlocked")
        }
    }
    ///
    /// Defaults to permanent storage
    /// - Parameter inMemory: Whether to store this data in temporary memory or not.
    /// - Parameter defaults: The UserDefaults suite where user data should be stored.
    init(inMemory: Bool = false, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)
        // For testing and previewing purposes, we create a temporary,
        // in-memory database by writing to /dev/null so our data is destroyed
        // after the app finishes running.
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            let groupID = "group.Watson.Gary.UltimatePortfolio"

            if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) {
                container.persistentStoreDescriptions.first?.url = url.appendingPathComponent("Main.sqlite")
            }
        }
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
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
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    func delete(_ object: Project) {
        let id = object.objectID.uriRepresentation().absoluteString
        CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [id])
        container.viewContext.delete(object)
    }
    func delete(_ object: Item) {
        let id = object.objectID.uriRepresentation().absoluteString
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [id])
        container.viewContext.delete(object)
    }
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }

    func update(_ item: Item) {
        let itemID = item.objectID.uriRepresentation().absoluteString
        let projectID = item.project?.objectID.uriRepresentation().absoluteString

        let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
        attributeSet.title = item.itemTitle
        attributeSet.contentDescription = item.detail

        let searchableItem = CSSearchableItem(uniqueIdentifier: itemID,
                                              domainIdentifier: projectID,
                                              attributeSet: attributeSet
        )
        CSSearchableIndex.default().indexSearchableItems([searchableItem])
        save()  // update coredata
    }

    func item(with uniqueIdentifier: String) -> Item? {
        guard let url = URL(string: uniqueIdentifier) else {
            return nil
        }

        guard let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url) else {
            return nil
        }
        return try? container.viewContext.existingObject(with: id) as? Item
    }

    @discardableResult func addProject() -> Bool {
        let canCreate = fullVersionUnlocked || count(for: Project.fetchRequest()) < 3
        if canCreate {
            let project = Project(context: container.viewContext)
            project.closed = false
            project.creationDate = Date()
            save()
            return true
        } else {
            return false
        }
    }

    func fetchRequestForTopItems(count: Int) -> NSFetchRequest<Item> {
        let itemRequest: NSFetchRequest<Item> = Item.fetchRequest()
        let completedPredicate = NSPredicate(format: "completed = false")
        let openPredicate = NSPredicate(format: "project.closed = false")
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [completedPredicate, openPredicate])
        itemRequest.predicate = compoundPredicate
        itemRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Item.priority, ascending: false)
        ]
        itemRequest.fetchLimit = count
        return itemRequest
    }

    func results<T: NSManagedObject>(for fetchRequest: NSFetchRequest<T>) -> [T] {
        return (try? container.viewContext.fetch(fetchRequest)) ?? []
    }
}
