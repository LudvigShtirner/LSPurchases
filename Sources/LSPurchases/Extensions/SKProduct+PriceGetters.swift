//
//  SKProduct+PriceGetters.swift
//  
//
//  Created by Алексей Филиппов on 01.01.2023.
//

import StoreKit

/// Расширение для получения локализованной цены встроенного продукта
public extension SKProduct {
    /// Локализованная цена встроенного продукта
    var localizedPrice: String? {
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: price)
    }
}

