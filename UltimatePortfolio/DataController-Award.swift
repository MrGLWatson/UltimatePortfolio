//
//  DataController-Award.swift
//  UltimatePortfolio
//
//  Created by Gary Watson on 06/07/2021.
//

import Foundation
import CoreData


extension DataController {
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
