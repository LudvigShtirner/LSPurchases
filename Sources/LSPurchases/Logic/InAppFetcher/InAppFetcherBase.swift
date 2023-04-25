//
//  InAppFetcherBase.swift
//  
//
//  Created by Алексей Филиппов on 07.03.2023.
//

// Apple
import StoreKit

final class InAppFetcherBase: NSObject, InAppFetcher {
    // MARK: - Dependencies
    weak var delegate: InAppFetcherDelegate?
    
    // MARK: - Data
    private var requests: Set<SKRequest> = []
    
    // MARK: - Inits
    deinit {
        requests.forEach {
            $0.delegate = nil
            $0.cancel()
        }
    }
    
    // MARK: - InAppFetcher
    func fetchInAppProducts(identifiers: [String]) {
        let productRequest = SKProductsRequest(productIdentifiers: Set(identifiers))
        productRequest.delegate = self
        productRequest.start()
        requests.insert(productRequest)
    }
}

extension InAppFetcherBase: SKProductsRequestDelegate {
    func requestDidFinish(_ request: SKRequest) {
        requests.remove(request)
    }
    
    func productsRequest(_ request: SKProductsRequest,
                         didReceive response: SKProductsResponse) {
        delegate?.productFetchEnded(with: .success(response.products))
    }
    
    func request(_ request: SKRequest,
                 didFailWithError error: Error) {
        delegate?.productFetchEnded(with: .failure(error))
    }
}
