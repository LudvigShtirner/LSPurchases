//
//  InAppFetcher.swift
//  
//
//  Created by Алексей Филиппов on 07.03.2023.
//

// Apple
import StoreKit

public protocol InAppFetcher: AnyObject {
    func fetchInAppProducts(identifiers: [String])
}

protocol InAppFetcherDelegate: AnyObject {
    func productFetchEnded(with result: Result<[SKProduct], Error>)
}
