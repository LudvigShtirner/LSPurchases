//
//  InAppDirector.swift
//  
//
//  Created by Алексей Филиппов on 14.03.2023.
//

// SPM
import SupportCode
// Apple
import Foundation

public typealias InAppDirector = (InAppPurchaser & InAppObserver & InAppProvider & InAppFetcher)

/// Протокол покупки/восстановления покупок
public protocol InAppPurchaser: AnyObject {
    /// Купить продукт
    /// - Parameter identifier: идентификатор продукта
    func purchaseProduct(with identifier: String)
    /// Восстановить покупки
    func restorePurchases(completionBlock: VoidBlock?)
}

public extension InAppPurchaser {
    func restorePurchases() {
        restorePurchases(completionBlock: nil)
    }
}

/// Протокол подключения/отключения получения событий покупок
public protocol InAppObserver: AnyObject {
    /// Начать отслеживать события покупок
    /// - Parameter observer: объект, осуществляющий слежение
    func subscribe(observer: InAppDirectorDelegate)
    /// Прекратить слежение за событиями покупок
    /// - Parameter observer: объект, осуществляющий слежение
    func unsubscribe(observer: InAppDirectorDelegate)
}

/// Протокол предоставления информации о покупках
public protocol InAppProvider: AnyObject {
    /// Флаг наличия активной покупки
    func isPremium() -> Bool
    /// Флаг наличия прошлых покупок у пользователя
    func hasPreviousSubscriptions() -> Bool
    /// Получить список доступных продуктов
    func obtainInAppProducts() -> [InAppProduct]
    /// Получить список транзакций пользователя
    /// - Parameter date: дата для фильтрации транзакций
    func obtainTransactions(from date: Date) -> [InAppTransaction]
    /// Получить чек пользователя
    func obtainReceiptString() -> String?
    /// Флаг разграничения тестовых пользователей
    func isSandbox() -> Bool
}

/// Протокол оповещения о работе InApp модуля
public protocol InAppDirectorDelegate: AnyObject {
    /// Оповестить о загрузке продуктов
    /// - Parameter products: список загруженных продуктов
    func productsWasLoaded(products: [InAppProduct])
    /// Оповестить об ошибке при загрузке продуктов
    /// - Parameter error: описание ошибки
    func productsWasLoaded(with error: Error)
    /// Оповестить о покупке продукта
    func paymentFinishedSuccesfully()
    /// Оповестить о ошибке при покупке продукта
    /// - Parameter error: описание ошибки
    func paymentFinished(with error: InAppError)
    /// Оповестить о восстановлении транзакций
    func purchasesRestored()
    /// Оповщает о любых изменениях статуса подписки
    func didUpdateSubscriptionStatus()
}

public extension InAppDirectorDelegate {
    func productsWasLoaded(products: [InAppProduct]) {}
    
    func productsWasLoaded(with error: Error) {}
    
    func paymentFinishedSuccesfully() {}
    
    func paymentFinished(with error: Error) {}
    
    func purchasesRestored() {}
    
    func didUpdateSubscriptionStatus() {}
}

