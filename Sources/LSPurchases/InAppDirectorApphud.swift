//
//  InAppDirectorApphud.swift
//  
//
//  Created by Алексей Филиппов on 15.03.2023.
//

// SPM
import ApphudSDK
import SupportCode
// Apple
import Foundation
import StoreKit

final class InAppDirectorApphud: InAppDirector {
    // MARK: - Dependencies
    private let transactionStorage: InAppTransactionStorage
    private let receiptProvider: InAppReceiptProvider
    private let transactionAcquirer: InAppTransactionAcquirer
    private let productFetcher: InAppFetcher
    private let purshaseWrapper = Apphud.self
    private let productIdsProvider: InAppProductIDsProvider
    
    // MARK: - Data
    private var fetchedInAppProducts: [InAppProduct] = []
    private var delegates: [WeakBox<AnyObject>] = []
    private var observers: [InAppDirectorDelegate] {
        delegates = delegates.compactMap { ($0.unbox != nil) ? $0 : nil }
        return delegates.compactMap { $0.unbox as? InAppDirectorDelegate }
    }
    
    // MARK: - Stored Info
    @UDStored(key: "subscriptionWasMigrated", defaultValue: false)
    private var subscriptionWasMigrated: Bool
    
    // MARK: - Init
    init(apphudSDKToken: String,
         receiptProvider: InAppReceiptProvider,
         transactionStorage: InAppTransactionStorage,
         transactionAcquirer: InAppTransactionAcquirer,
         productFetcher: InAppFetcher,
         productIdsProvider: InAppProductIDsProvider) {
        self.transactionStorage = transactionStorage
        self.receiptProvider = receiptProvider
        self.transactionAcquirer = transactionAcquirer
        self.productFetcher = productFetcher
        self.productIdsProvider = productIdsProvider
        configureAndStart(apphudSDKToken: apphudSDKToken)
    }
    
    // MARK: - Interface methods
    func updateUserID(_ userID: String) {
        purshaseWrapper.updateUserID(userID)
    }
    
    func fetchInAppProducts(identifiers: [String]) {
        productFetcher.fetchInAppProducts(identifiers: identifiers)
    }
    
    // MARK: - Actions for Delegates
    private func paymentFinished(with error: Error) {
        let inAppError = InAppError(with: error)
        notify { $0.paymentFinished(with: inAppError)}
    }
    
    private func notify(operation: @escaping (InAppDirectorDelegate) -> Void) {
        for observer in observers {
            DispatchQueue.callOnMainQueue {
                operation(observer)
            }
        }
    }
}

// MARK: - ApphudDelegate
extension InAppDirectorApphud: ApphudDelegate {
    func apphudDidFetchStoreKitProducts(_ products: [SKProduct]) {
        fetchedInAppProducts = buildInAppProducts(from: products)
        notify {
            $0.productsWasLoaded(products: self.fetchedInAppProducts)
            $0.didUpdateSubscriptionStatus()
        }
    }
    
    func apphudSubscriptionsUpdated(_ subscriptions: [ApphudSubscription]) {
        notify { $0.didUpdateSubscriptionStatus() }
    }
}

// MARK: - InAppProviding
extension InAppDirectorApphud {
    func isPremium() -> Bool {
        let hasActiveSubscription = purshaseWrapper.hasActiveSubscription()
        var hasLifetimePurchase = false
        if let identifier = productIdsProvider.lifetimeIdentifier {
            hasLifetimePurchase = purshaseWrapper.isNonRenewingPurchaseActive(productIdentifier: identifier)
        }
        return hasActiveSubscription || hasLifetimePurchase
    }
    
    func hasPreviousSubscriptions() -> Bool {
        return purshaseWrapper.subscriptions()?.isEmpty == false
    }
    
    func obtainInAppProducts() -> [InAppProduct] {
        return fetchedInAppProducts
    }
    
    func obtainTransactions(from date: Date) -> [InAppTransaction] {
        return transactionStorage.obtain { $0.date > date }
    }
    
    func obtainReceiptString() -> String? {
        receiptProvider.getReceipt()
    }
    
    func isSandbox() -> Bool {
        return receiptProvider.isSandbox()
    }
    
}

// MARK: - InAppPurchasing
extension InAppDirectorApphud {
    func purchaseProduct(with identifier: String) {
        if SKPaymentQueue.canMakePayments() == false {
            paymentFinished(with: SKError(.paymentNotAllowed))
            return
        }
        guard let product = fetchedInAppProducts.first(where: { $0.productIdentifier == identifier }) else {
            return
        }
        
        purshaseWrapper.purchase(product.skProduct.productIdentifier) { [weak self] (result) in
            guard let self = self else { return }
            if let error = result.error {
                self.paymentFinished(with: error)
                return
            }
            self.notify {
                $0.paymentFinishedSuccesfully()
                $0.didUpdateSubscriptionStatus()
            }
        }
    }
    
    func restorePurchases(completionBlock: VoidBlock?) {
        purshaseWrapper.restorePurchases(callback: { [weak self] _, _, error in
            if error != nil {
                completionBlock?()
                return
            }
            self?.notify {
                $0.purchasesRestored()
                $0.didUpdateSubscriptionStatus()
            }
            completionBlock?()
        })
    }
}

// MARK: - InAppFetching
extension InAppDirectorApphud {
    private func configureAndStart(apphudSDKToken: String) {
        purshaseWrapper.setDelegate(self)
        purshaseWrapper.start(apiKey: apphudSDKToken)
        migrateSubscriptions()
        transactionAcquirer.delegate = self
    }
    
    func fetchInAppProducts() {
        if let products = Apphud.products {
            fetchedInAppProducts = buildInAppProducts(from: products)
        } else {
            let productIDs = productIdsProvider.obtainInAppProductIDs()
            productFetcher.fetchInAppProducts(identifiers: productIDs)
        }
    }
    
    private func migrateSubscriptions() {
        if subscriptionWasMigrated { return }
        let hasSubscriptionTransaction = transactionStorage.obtainAll().isEmpty == false
        if hasSubscriptionTransaction {
            purshaseWrapper.migratePurchasesIfNeeded(callback: { [weak self] _, _, _  in
                self?.subscriptionWasMigrated = true
            })
        } else {
            subscriptionWasMigrated = true
        }
    }
    
    private func buildInAppProducts(from skProducts: [SKProduct]) -> [InAppProduct] {
        return skProducts.compactMap {
            InAppProduct(skProduct: $0, trialPeriod: "")
        }
    }
}

// MARK: - InAppObserving
extension InAppDirectorApphud {
    func subscribe(observer: InAppDirectorDelegate) {
        delegates.append(WeakBox(observer))
    }
    
    func unsubscribe(observer: InAppDirectorDelegate) {
        let index = delegates.firstIndex { box in
            guard let delegate = box.unbox as? InAppDirectorDelegate else { return false }
            return delegate === observer
        }
        guard let idx = index else { return }
        delegates.remove(at: idx)
    }
}

// MARK: - InAppTransactionAcquirerDelegate
extension InAppDirectorApphud: InAppTransactionAcquirerDelegate {
    func allTransactionsRestored() {
        print("allTransactionsRestored")
    }
    
    func transactionsCancelled() {
        print("transactionsCancelled")
    }
    
    func transactionRestoredSuccessfully(transaction: SKPaymentTransaction) {
        guard let transactionId = transaction.original?.transactionIdentifier else { return }
        let model = InAppTransaction(date: transaction.transactionDate ?? Date(),
                                     productIdentifier: transaction.payment.productIdentifier,
                                     transactionIdentifier: transactionId)
        transactionStorage.store(model)
    }
    
    func transactionFinished(with result: Result<SKPaymentTransaction, InAppTransactionError>) {
        switch result {
        case .success(let transaction):
            guard let transactionId = transaction.original?.transactionIdentifier ?? transaction.transactionIdentifier else {
                return
            }
            let model = InAppTransaction(date: transaction.transactionDate ?? Date(),
                                         productIdentifier: transaction.payment.productIdentifier,
                                         transactionIdentifier: transactionId)
            transactionStorage.store(model)
        case .failure(let error):
            notify { $0.paymentFinished(with: error) }
        }
    }
}

// MARK: - InAppProductFetcherDelegate
extension InAppDirectorApphud: InAppFetcherDelegate {
    func productFetchEnded(with result: Result<[SKProduct], Error>) {
        switch result {
        case .success(let products):
            fetchedInAppProducts = buildInAppProducts(from: products)
            notify {
                $0.productsWasLoaded(products: self.fetchedInAppProducts)
                $0.didUpdateSubscriptionStatus()
            }
        case .failure(let error):
            notify { $0.productsWasLoaded(with: error) }
//            Analytics.eventInput.logEvent(.inAppProductLoadingFailed,
//                                          propertiesModel: .make(error: error))
//            Errors.input.registerError(.inAppProductLoadingFailed,
//                                       parameters: .make(error: error))
        }
    }
}
