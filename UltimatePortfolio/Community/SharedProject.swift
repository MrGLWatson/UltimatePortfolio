//
//  SharedProject.swift
//  UltimatePortfolio
//
//  Created by Gary Watson on 06/09/2021.
//

import Foundation

struct SharedProject: Identifiable {
    let id: String
    let title: String
    let detail: String
    let owner: String
    let closed: Bool

    static let example = SharedProject(id: "1",
                                       title: "example",
                                       detail: "Detail",
                                       owner: "GaryWatson",
                                       closed: false)
}
