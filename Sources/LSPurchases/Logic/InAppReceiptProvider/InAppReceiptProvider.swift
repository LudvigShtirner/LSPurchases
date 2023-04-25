//
//  InAppReceiptProvider.swift
//  
//
//  Created by Алексей Филиппов on 07.03.2023.
//

// Apple
import Foundation

protocol InAppReceiptProvider: AnyObject {
    func getReceipt() -> String?
    func isSandbox() -> Bool
}
