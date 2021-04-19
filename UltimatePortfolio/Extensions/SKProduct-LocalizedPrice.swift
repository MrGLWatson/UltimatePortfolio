//
//  SKProduct-LocalizedPrice.swift
//  UltimatePortfolio
//
//  Created by Gary Watson on 19/04/2021.
//

import StoreKit

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
