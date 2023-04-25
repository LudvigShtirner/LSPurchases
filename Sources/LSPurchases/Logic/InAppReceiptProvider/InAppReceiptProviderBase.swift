//
//  InAppReceiptProviderBase.swift
//  
//
//  Created by Алексей Филиппов on 07.03.2023.
//

// Apple
import Foundation

final class InAppReceiptProviderBase: InAppReceiptProvider {
    // MARK: - Data
    private let bundle = Bundle.main
    
    // MARK: - InAppReceiptProvider
    func getReceipt() -> String? {
        guard let receiptURL = bundle.appStoreReceiptURL else {
            return nil
        }
        let receiptData = try? Data(contentsOf: receiptURL)
        return receiptData?.base64EncodedString()
    }
    
    func isSandbox() -> Bool {
        guard let receiptUrl = bundle.appStoreReceiptURL else {
            return false
        }
        return receiptUrl.path.contains("sandboxReceipt")
    }
}
