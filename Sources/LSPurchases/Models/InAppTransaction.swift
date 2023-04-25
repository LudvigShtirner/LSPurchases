//
//  InAppTransaction.swift
//  
//
//  Created by Алексей Филиппов on 08.03.2023.
//

// Apple
import Foundation

public struct InAppTransaction {
    // MARK: - Data
    public let date: Date
    public let productIdentifier: String
    public let transactionIdentifier: String
    
    // MARK: - Inits
    public init(date: Date,
                productIdentifier: String,
                transactionIdentifier: String) {
        self.date = date
        self.productIdentifier = productIdentifier
        self.transactionIdentifier = transactionIdentifier
    }
}
