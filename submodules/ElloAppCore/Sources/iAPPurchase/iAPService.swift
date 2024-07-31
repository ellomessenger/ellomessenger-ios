//
//  iAPService.swift
//  _idx_ElloAppCore_D1CBFEF5_ios_min15.4
//
//

import Foundation
import StoreKit

public protocol ConsumableProductIds {
    var consumableProductIds: [String] { get }
}

public class iAPService {
    // Types
    // 1: text_subscription
    // 2: image_subscription
    // 3: text_pack
    // 4: image_pack
    public enum PurchaseResult {
        case success(type: Int, quantity: Int, amount: Float, payload: String, productId: String), failure
    }
    
    private(set) var subscriptionProducts = [Product]()
    public private(set) var consumableProducts = [Product]()
    private let productIds = ["ai.subscription.text.1month", "ai.subscription.image.1month", ""]
    private let consumableProductIds: [String]/* = ["ai.consumable.text.200.requests", "ai.consumable.image.120.requests"]*/
    
    public init(productIds: ConsumableProductIds) {
        consumableProductIds = productIds.consumableProductIds
        
        storeKitTaskUpdatesHandle = Task.detached {
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    print("Transaction verified in listener")
                    
                    await transaction.finish()
                    
                    // Update the user's purchases...
                case .unverified:
                    print("Transaction unverified")
                }
            }
        }
    }
    
    private let storeKitTaskUpdatesHandle: Task<Void, Error>?
    
    // TODO: Refactor, make flexible and common methods for different products
    public func retrieveSubscriptionProducts() async {
        do {
            let products = try await Product.products(for: productIds)
            self.subscriptionProducts = products.sorted(by: { $0.price < $1.price })
            for product in self.subscriptionProducts {
                debugPrint("In-App Product:: \(product.displayName) in \(product.displayPrice)")
            }
        } catch {
            debugPrint(error)
        }
    }
    
    public func retrieveConsumableProducts() async {
        do {
            let products = try await Product.products(for: consumableProductIds)
            self.consumableProducts = products.sorted(by: { $0.price < $1.price })
            for product in self.consumableProducts {
                debugPrint("In-App Product:: \(product.displayName) in \(product.displayPrice)")
            }
        } catch {
            debugPrint(error)
        }
    }
    
    public func buyProduct(_ productId: String, completion: @escaping (PurchaseResult) -> Void) {
        guard let product = consumableProducts.first(where: { $0.id == productId }) else {
            completion(.failure)
            
            return
        }
        
        buyProduct(product, completion: completion)
    }
    
    public func buyProduct(_ product: Product, completion: @escaping (PurchaseResult) -> Void) {
        Task { @MainActor in
            let result = try await product.purchase()
            switch result {
            case let .success(verified):
                switch verified {
                case .unverified(_, _):
                    completion(.failure)
                case let .verified(transaction):
                    // Successful purhcase
                    await transaction.finish()
                    
                    guard let receiptString = verified.payloadData.jsonString else {
                        completion(.failure)
                        return
                    }
                    let amount = NSDecimalNumber(decimal: product.price).floatValue
                    if transaction.productID == "ai.consumable.text.200.requests" {
                        completion(.success(
                            type: 3,
                            quantity: 150,
                            amount: amount,
                            payload: receiptString,
                            productId: transaction.productID))
                    } else if transaction.productID == "ai.consumable.image.120.requests"{
                        completion(.success(
                            type: 4,
                            quantity: 100,
                            amount: amount,
                            payload: receiptString, 
                            productId: transaction.productID))
                    } else {
                        completion(.success(
                            type: 0,
                            quantity: 0,
                            amount: 0,
                            payload: receiptString,
                            productId: transaction.productID))
                    }
                }
            case .pending:
                // Transaction waiting on SCA (Strong Customer Authentication) or
                // approval from Ask to Buy
                break
            case .userCancelled:
                completion(.failure)
            @unknown default:
                completion(.failure)
            }
        }
    }
    
    public func restorePurchases() async {
        do {
         try await AppStore.sync()
        } catch {
            debugPrint(error)
        }
        
    }
    
    deinit {
        storeKitTaskUpdatesHandle?.cancel()
    }
}

extension Data {
    var jsonString: String? {
        String(data: self, encoding: .utf8)
    }
}
