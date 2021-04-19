//
//  ProjectsViewModel.swift
//  UltimatePortfolio
//
//  Created by Gary Watson on 01/03/2021.
//

import CoreData
import Foundation // we do not want swiftui here, as this file is not to contain any view code
import SwiftUI

extension ProjectsView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        let dataController: DataController
        var sortOrder = Item.SortOrder.optimized
        let showClosedProjects: Bool
        private let projectsController: NSFetchedResultsController<Project>
        @Published var projects = [Project]()

        @Published var showingUnlockView = false

        init(dataController: DataController, showClosedProjects: Bool) {
            self.dataController = dataController
            self.showClosedProjects = showClosedProjects
            let request: NSFetchRequest<Project> = Project.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.creationDate, ascending: false)]
            request.predicate = NSPredicate(format: "closed = %d", showClosedProjects)
            projectsController = NSFetchedResultsController(fetchRequest: request,
                                                            managedObjectContext: dataController.container.viewContext,
                                                            sectionNameKeyPath: nil,
                                                            cacheName: nil
            )
            super.init()
            projectsController.delegate = self
            do {
                try projectsController.performFetch()
                projects = projectsController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch our projects!")
            }
        }
        func addProject() {
            let canCreate = dataController.fullVersionUnlocked || dataController.count(for: Project.fetchRequest()) < 3
            if canCreate {
                let project = Project(context: dataController.container.viewContext)
                project.closed = false
                project.creationDate = Date()
                dataController.save()
            } else {
                showingUnlockView.toggle()
            }
        }
        func addItem(to project: Project) {
            let item = Item(context: dataController.container.viewContext)
            item.project = project
            item.creationDate = Date()
            dataController.save()
        }
        func delete(_ offsets: IndexSet, from project: Project) {
            // use the sortorder as displayed, otherwise the item in unsorted order gets deleted
            let allItems = project.projectItems(using: sortOrder)
            for offset in offsets {  // index sets are sorted by default and items will be unique
                let item = allItems[offset]
                // items in the array will not move down and renumbered
                // as they are being deleted until the save is done
                dataController.delete(item)
            }
            dataController.save()
        }
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newProjects = controller.fetchedObjects as? [Project] {
                projects = newProjects
            }
        }
    }
}
