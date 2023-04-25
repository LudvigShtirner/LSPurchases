//
//  InAppTransactionAcquirer.swift
//  
//
//  Created by Алексей Филиппов on 07.03.2023.
//

// Apple
import StoreKit

protocol InAppTransactionAcquirer: AnyObject {
    var delegate: InAppTransactionAcquirerDelegate? { get set }
    
    func startBuyTransaction(product: InAppProduct)
    func restoreAllTransactions()
    func removeAllTransactions()
}

protocol InAppTransactionAcquirerDelegate: AnyObject {
    func transactionFinished(with result: Result<SKPaymentTransaction, InAppTransactionError>)
    func allTransactionsRestored()
    func transactionsCancelled()
}

enum InAppTransactionError: Error {
    case cantMakePayments
    case alreadyHaveTransaction
    case transactionError(Error?)
    /// Был изменен регион AppStore
    case storeFrontChanged
    case noProductWithIdentifier
}
