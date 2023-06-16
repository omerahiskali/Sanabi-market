//
//  CartManager.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 5.06.2023.
//

import Foundation
import CoreData

class CartManager {
    static let shared = CartManager()

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Sanabi")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    func addProduct(productId: Int16, productNum: Int16) {
        let managedContext = persistentContainer.viewContext
        let product = Cart(context: managedContext)
        product.productId = productId
        product.productNum = productNum

        do {
            try managedContext.save()
        } catch {
            print("Failed to create product: \(error)")
        }
    }
    
    func getProductNum(forProductId productId: Int16) -> Int16? {
        let fetchRequest: NSFetchRequest<Cart> = Cart.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "productId == %d", productId)
        
        do {
            let products = try persistentContainer.viewContext.fetch(fetchRequest)
            if let product = products.first {
                return product.productNum
            } else {
                NSLog("Product not found!")
            }
        } catch {
            NSLog("Failed to fetch product: \(error)")
        }
        
        return nil
    }

    
    func updateProduct(productId: Int16, newProductNum: Int16) {
        let fetchRequest: NSFetchRequest<Cart> = Cart.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "productId == %d", productId)
        
        do {
            let products = try persistentContainer.viewContext.fetch(fetchRequest)
            if let product = products.first {
                product.productNum = newProductNum
                try persistentContainer.viewContext.save()
                NSLog("Product updated successfully!")
            } else {
                NSLog("Product not found!")
            }
        } catch {
            NSLog("Failed to update product: \(error)")
        }
    }
    
    func deleteProduct(productId: Int16) {
        let fetchRequest: NSFetchRequest<Cart> = Cart.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "productId == %d", productId)
        
        do {
            let products = try persistentContainer.viewContext.fetch(fetchRequest)
            if let product = products.first {
                persistentContainer.viewContext.delete(product)
                try persistentContainer.viewContext.save()
                NSLog("Product deleted successfully!")
            } else {
                NSLog("Product not found!")
            }
        } catch {
            NSLog("Failed to delete product: \(error)")
        }
    }

    func deleteCart() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Cart")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: persistentContainer.viewContext)
            NSLog("All products deleted successfully!")
        } catch {
            NSLog("Failed to delete all products: \(error)")
        }
    }
    
    func hasProduct(withId productId: Int16) -> Bool {
        let fetchRequest: NSFetchRequest<Cart> = Cart.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "productId == %d", productId)
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try persistentContainer.viewContext.count(for: fetchRequest)
            return count > 0
        } catch {
            NSLog("Failed to fetch product: \(error)")
        }
        
        return false
    }
    
    func getAllProducts() -> [Cart]? {
        let fetchRequest: NSFetchRequest<Cart> = Cart.fetchRequest()
        
        do {
            let products = try persistentContainer.viewContext.fetch(fetchRequest)
            return products
        } catch {
            NSLog("Failed to fetch products: \(error)")
        }
        
        return nil
    }


}
