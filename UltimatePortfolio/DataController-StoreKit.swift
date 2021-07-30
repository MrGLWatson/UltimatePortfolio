//
//  DataController-StoreKit.swift
//  UltimatePortfolio
//
//  Created by Gary Watson on 16/07/2021.
//

import Foundation
import StoreKit

extension DataController {
    func appLaunched() {
        guard count(for: Project.fetchRequest()) >= 5 else { return }
//        let allScenes = UIApplication.shared.connectedScenes
//        let scene = allScenes.first { $0.activationState == .foregroundActive }
//
//        if let windowScene = scene as? UIWindowScene {
//            SKStoreReviewController.requestReview(in: windowScene)
//        }
    }

}
