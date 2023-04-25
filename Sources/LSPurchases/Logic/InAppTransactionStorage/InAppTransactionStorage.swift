//
//  InAppTransactionStorage.swift
//  
//
//  Created by Алексей Филиппов on 08.03.2023.
//

// SPM
import CoreObjects
import SupportCode
// Apple
import CoreData

final class InAppTransactionStorage: EntriesStorage {
    // MARK: - Data
    private let context = InAppTransactionStorage.managedObjectContext
    
    // MARK: - EntriesStorage
    typealias StoredType = InAppTransaction
    
    func obtainAll() -> [InAppTransaction] {
        let transactions = obtainAllCD()
        let models = transactions.map {
            InAppTransaction(date: $0.date,
                             productIdentifier: $0.productID,
                             transactionIdentifier: $0.transactionID)
        }
        return models
    }
    
    
    func obtain(with predicate: @escaping (InAppTransaction) -> Bool) -> [InAppTransaction] {
        obtainAll().filter { predicate($0) }
    }
    
    func store(_ model: InAppTransaction) {
        context.performChanges { [weak self] in
            guard let self = self else { return }
            let accountCD = InAppTransactionCD.findOrCreate(in: self.context,
                                                            matching: self.searchPredicate(for: model))
            accountCD.update(in: self.context, with: model)
        }
    }
    
    func clear() {
        let transactions = obtainAllCD()
        if transactions.isEmpty {
            return
        }
        context.performChanges { [weak self] in
            transactions.forEach {
                self?.context.delete($0)
            }
        }
    }
    
    // MARK: - Private methods
    private func searchPredicate(for transaction: InAppTransaction) -> NSPredicate {
        NSPredicate(format: "transactionID == %@", transaction.transactionIdentifier)
    }
    
    private func obtainAllCD() -> [InAppTransactionCD] {
        return try! context.fetch(InAppTransactionCD.sortedFetchRequest) as [InAppTransactionCD]
    }
}

extension InAppTransactionStorage {
    static var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        return managedObjectContext
    }()
    static var managedObjectModel: NSManagedObjectModel = {
        var entities: [NSEntityDescription] = [InAppTransactionCD.entityDescription]
        let model = NSManagedObjectModel()
        model.entities = entities
        return model
    }()
    static var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent("\(String(describing: InAppTransactionStorage.self)).sqlite")

        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                              configurationName: nil,
                                                              at: persistentStoreURL,
                                                              options: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
        return persistentStoreCoordinator
    }()
}
