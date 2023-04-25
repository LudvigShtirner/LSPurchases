//
//  InAppProductIDsProvider.swift
//  
//
//  Created by Алексей Филиппов on 18.03.2023.
//

// Apple
import Foundation

public protocol InAppProductIDsProvider {
    func obtainInAppProductIDs() -> [String]
    
    var lifetimeIdentifier: String? { get }
}
