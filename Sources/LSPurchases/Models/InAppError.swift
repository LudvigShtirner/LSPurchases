//
//  InAppError.swift
//  
//
//  Created by Алексей Филиппов on 08.03.2023.
//

// Apple
import StoreKit

public enum InAppError: Error {
    case unknown(Error?)
    case clientInvalid
    case paymentCancelled
    case paymentInvalid
    case paymentNotAllowed
    case storeProductNotAvailable
    case cloudServicePermissionDenied
    case cloudServiceNetworkConnectionFailed
    case cloudServiceRevoked
    case privacyAcknowledgementRequired
    case unauthorizedRequestData
    case invalidOfferIdentifier
    case invalidSignature
    case missingOfferParams
    case invalidOfferPrice
    
    case overlayCancelled
    case overlayInvalidConfiguration
    case overlayTimeout
    case ineligibleForOffer
    case unsupportedPlatform
    case overlayPresentedInBackgroundScene
    
    case forceError
    
    init(with error: Error?) {
        if let err = error as? SKError {
            switch err.code {
            case .unknown: self = .unknown(error)
            case .clientInvalid: self = .clientInvalid
            case .paymentCancelled: self = .paymentCancelled
            case .paymentInvalid: self = .paymentInvalid
            case .paymentNotAllowed: self = .paymentNotAllowed
            case .storeProductNotAvailable: self = .storeProductNotAvailable
            case .cloudServicePermissionDenied: self = .cloudServicePermissionDenied
            case .cloudServiceNetworkConnectionFailed: self = .cloudServiceNetworkConnectionFailed
            case .cloudServiceRevoked: self = .cloudServiceRevoked
            case .privacyAcknowledgementRequired: self = .privacyAcknowledgementRequired
            case .unauthorizedRequestData: self = .unauthorizedRequestData
            case .invalidOfferIdentifier: self = .invalidOfferIdentifier
            case .invalidSignature: self = .invalidSignature
            case .missingOfferParams: self = .missingOfferParams
            case .invalidOfferPrice: self = .invalidOfferPrice
            case .overlayCancelled: self = .overlayCancelled
            case .overlayInvalidConfiguration: self = .overlayInvalidConfiguration
            case .overlayTimeout: self = .overlayTimeout
            case .ineligibleForOffer: self = .ineligibleForOffer
            case .unsupportedPlatform: self = .unsupportedPlatform
            case .overlayPresentedInBackgroundScene: self = .overlayPresentedInBackgroundScene
            @unknown default: fatalError("Unrecognized inApp error code")
            }
        } else {
            self = .unknown(error)
        }
    }
    
    var domain: String {
        return "LSPurchases"
    }
    
    var errorCode: Int {
        self.asSKErrorCode.rawValue
    }
    
    var description: String {
        SKError(self.asSKErrorCode).localizedDescription
    }
    
    var asSKErrorCode: SKError.Code {
        let customErrorCode = SKError.Code(rawValue: -1)!
        switch self {
        case .unknown: return SKError.unknown
        case .clientInvalid: return SKError.clientInvalid
        case .paymentCancelled: return SKError.paymentCancelled
        case .paymentInvalid: return SKError.paymentInvalid
        case .paymentNotAllowed: return SKError.paymentNotAllowed
        case .storeProductNotAvailable: return SKError.storeProductNotAvailable
        case .cloudServicePermissionDenied: return SKError.cloudServicePermissionDenied
        case .cloudServiceNetworkConnectionFailed: return SKError.cloudServiceNetworkConnectionFailed
        case .cloudServiceRevoked: return SKError.cloudServiceRevoked
        case .privacyAcknowledgementRequired: return SKError.privacyAcknowledgementRequired
        case .unauthorizedRequestData: return SKError.unauthorizedRequestData
        case .invalidOfferIdentifier: return SKError.invalidOfferIdentifier
        case .invalidSignature: return SKError.invalidSignature
        case .missingOfferParams: return SKError.missingOfferParams
        case .invalidOfferPrice: return SKError.invalidOfferPrice
        case .forceError: return customErrorCode
        case .overlayCancelled: return SKError.overlayCancelled
        case .overlayInvalidConfiguration:
            if #available(iOS 14.0, *) { return SKError.overlayInvalidConfiguration } else { return customErrorCode }
        case .overlayTimeout:
            if #available(iOS 14.0, *) { return SKError.overlayTimeout } else { return customErrorCode }
        case .ineligibleForOffer:
            if #available(iOS 14.0, *) { return SKError.ineligibleForOffer } else { return customErrorCode }
        case .unsupportedPlatform:
            if #available(iOS 14.0, *) { return SKError.unsupportedPlatform } else { return customErrorCode }
        case .overlayPresentedInBackgroundScene:
            if #available(iOS 14.5, *) { return SKError.overlayPresentedInBackgroundScene } else { return customErrorCode }
        }
    }
    
    var foundationError: NSError {
        return NSError(domain: domain, code: errorCode, userInfo: [
            NSLocalizedDescriptionKey: description
        ])
    }
}
