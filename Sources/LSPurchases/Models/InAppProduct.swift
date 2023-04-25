//
//  InAppProduct.swift
//  
//
//  Created by Алексей Филиппов on 07.03.2023.
//

// Apple
import StoreKit

public final class InAppProduct: NSObject {
    // MARK: - Info
    let skProduct: SKProduct
    let productIdentifier: String
    let productPrice: NSDecimalNumber
    let productName: String
    let productLocalizedPrice: String
    let productDescription: String
    let trialPeriod: String
    
    // MARK: - Inits
    public init(skProduct: SKProduct,
                trialPeriod: String) {
        self.skProduct = skProduct
        self.productIdentifier = skProduct.productIdentifier
        self.productPrice = skProduct.price
        self.productName = skProduct.localizedTitle
        self.productDescription = skProduct.localizedDescription
        self.trialPeriod = trialPeriod
        
        self.productLocalizedPrice = skProduct.localizedPrice ?? ""
    }
    
    // MARK: - Overrides
    public override var description: String {
        return """
        Identifier: \(productIdentifier)
        Name: \(productName)
        Description: \(productDescription)
        Price: \(productPrice)
        LocalizedPrice: \(String(describing: productLocalizedPrice))
        TrialPeriod: \(trialPeriod)
        """
    }
}
