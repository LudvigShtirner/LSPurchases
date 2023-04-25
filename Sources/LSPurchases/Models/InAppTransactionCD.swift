//
//  InAppTransactionCD.swift
//  
//
//  Created by Алексей Филиппов on 09.03.2023.
//

// Subprojects
import SupportCode
// Apple
import CoreData

@objc(InAppTransactionCD)
final class InAppTransactionCD: NSManagedObject, ManagedByCode {
    // MARK: - Data
    @NSManaged fileprivate(set) var date: Date
    @NSManaged fileprivate(set) var productID: String
    @NSManaged fileprivate(set) var transactionID: String
    
    // MARK: - ManagedByCode
    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(date), ascending: false)]
    }
    
    static var entityDescription: NSEntityDescription {
        let entity = NSEntityDescription(from: InAppTransactionCD.self)
        entity.addProperty(NSAttributeDescription(name: #keyPath(date),
                                                  ofType: .dateAttributeType))
        entity.addProperty(NSAttributeDescription(name: #keyPath(productID),
                                                  ofType: .stringAttributeType))
        entity.addProperty(NSAttributeDescription(name: #keyPath(transactionID),
                                                  ofType: .stringAttributeType))
        return entity
    }
    
    // MARK: - Interface methods
    static func insert(into context: NSManagedObjectContext,
                       transaction: InAppTransaction) -> InAppTransactionCD {
        let transactionCD: InAppTransactionCD = context.insertObject()
        transactionCD.update(in: context, with: transaction)
        return transactionCD
    }
    
    func update(in context: NSManagedObjectContext,
                       with transaction: InAppTransaction) {
        date = transaction.date
        productID = transaction.productIdentifier
        transactionID = transaction.transactionIdentifier
    }
}
