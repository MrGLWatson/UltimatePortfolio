//
//  Sequence-Sorting.swift
//  UltimatePortfolio
//
//  Created by Gary Watson on 03/02/2021.
//

import Foundation

extension Sequence {
    func sorted<Value>(
        by keyPath: KeyPath<Element, Value>,
        using areInCreasingOrder: (Value, Value) throws -> Bool ) rethrows -> [Element] {
        try self.sorted {
            try areInCreasingOrder($0[keyPath: keyPath], $1[keyPath: keyPath])
        }
    }
    func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>) -> [Element] {
    self.sorted(by: keyPath, using: <)
    }
}
