//
//  InAppTransactionAcquirerBase.swift
//  
//
//  Created by Алексей Филиппов on 07.03.2023.
//

// Apple
import StoreKit

final class InAppTransactionAcquirerBase: NSObject, InAppTransactionAcquirer {
    // MARK: - Dependencies
    weak var delegate: InAppTransactionAcquirerDelegate?
    
    // MARK: - Info
    private let paymentQueue = SKPaymentQueue.default()
    private var canMakePayments: Bool { SKPaymentQueue.canMakePayments() }
    private var hasTransactions: Bool { !paymentQueue.transactions.isEmpty }
    
    // MARK: - Inits
    override init() {
        super.init()
        paymentQueue.add(self)
    }
    
    deinit {
        removeAllTransactions()
        paymentQueue.remove(self)
    }
    
    // MARK: - InAppTransactionAcquiring
    func startBuyTransaction(product: InAppProduct) {
        if !canMakePayments {
            delegate?.transactionFinished(with: .failure(.cantMakePayments))
            return
        }
        if hasTransactions {
            delegate?.transactionFinished(with: .failure(.alreadyHaveTransaction))
            return
        }
        let payment = SKPayment(product: product.skProduct)
        paymentQueue.add(payment)
    }
    
    func restoreAllTransactions() {
        if !canMakePayments {
            delegate?.transactionFinished(with: .failure(.cantMakePayments))
            return
        }
        if hasTransactions {
            delegate?.transactionFinished(with: .failure(.alreadyHaveTransaction))
            return
        }
        paymentQueue.restoreCompletedTransactions()
    }
    
    func removeAllTransactions() {
        for transaction in paymentQueue.transactions
            where transaction.transactionState != .purchasing {
                paymentQueue.finishTransaction(transaction)
        }
    }
}

// MARK: - SKPaymentTransactionObserver
extension InAppTransactionAcquirerBase: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue,
                      updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            paymentQueue.finishTransaction(transaction)
            switch transaction.transactionState {
            case .purchased, .restored:
                delegate?.transactionFinished(with: .success(transaction))
            case .failed:
                delegate?.transactionFinished(with: .failure(.transactionError(transaction.error)))
            default: break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        delegate?.allTransactionsRestored()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue,
                      restoreCompletedTransactionsFailedWithError error: Error) {
        if hasTransactions {
            removeAllTransactions()
        }
        delegate?.transactionFinished(with: .failure(.transactionError(error)))
    }
    
    func paymentQueueDidChangeStorefront(_ queue: SKPaymentQueue) {
        if hasTransactions {
            removeAllTransactions()
        }
        delegate?.transactionFinished(with: .failure(.storeFrontChanged))
    }
}

