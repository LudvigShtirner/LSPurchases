//
//  LSPurchasesFactory.swift
//  
//
//  Created by Алексей Филиппов on 18.03.2023.
//

// Apple
import Foundation

public final class LSPurchasesFactory {
    // MARK: - Inits
    private init() {
        
    }
    
    // MARK: - Interface methods
    public static func makeInAppDirector(productIdsProvider: InAppProductIDsProvider,
                                         apphudSDKToken: String) -> InAppDirector {
        let receiptProvider = InAppReceiptProviderBase()
        let transactionStorage = InAppTransactionStorage()
        let transactionAcquirer = InAppTransactionAcquirerBase()
        let productFetcher = InAppFetcherBase()
        return InAppDirectorApphud(apphudSDKToken: apphudSDKToken,
                                   receiptProvider: receiptProvider,
                                   transactionStorage: transactionStorage,
                                   transactionAcquirer: transactionAcquirer,
                                   productFetcher: productFetcher,
                                   productIdsProvider: productIdsProvider)
    }
}
