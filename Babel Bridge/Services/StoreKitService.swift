import Foundation
import StoreKit

enum StoreError: Error {
    case paymentFailed
    case userCancelled
    case notAllowed
}

@MainActor
class StoreKitService: ObservableObject {
    static let shared = StoreKitService()

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchaseState: PurchaseState = .notStarted

    enum PurchaseState: Equatable {
        case notStarted
        case purchasing
        case completed
        case failed(Error)
        
        static func == (lhs: PurchaseState, rhs: PurchaseState) -> Bool {
            switch (lhs, rhs) {
            case (.notStarted, .notStarted):
                return true
            case (.purchasing, .purchasing):
                return true
            case (.completed, .completed):
                return true
            case (.failed(let lhsError), .failed(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }

    private init() {
        print("StoreKitService initialized")
        Task {
            await loadProducts()
        }
    }
    
    func loadProducts() async {
        print("Loading products...")
        let productIds: Set<String> = [
            "sxk90xow58sg", // 10万字以下（标准）
            "sxk90xow58sa", // 10万字以下（快速）
            "sxk90xow58sb", // 10-20万字（标准）
            "sxk90xow58sc", // 10-20万字（快速）
            "sxk90xow58sd", // 20-30万字（标准）
            "sxk90xow58se", // 20-30万字（快速）
            "sxk90xow58f",  // 30万字以上（标准）
            "sxk90xow58sh"  // 30万字以上（快速）
        ]

        print("Product IDs to load: \(productIds)")
        
        do {
            products = try await Product.products(for: productIds)
            print("Successfully loaded \(products.count) products")
            for product in products {
                print("Loaded product: \(product.id) - \(product.displayName)")
            }
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    func purchase(wordCount: Int, mode: TranslationSpeed) async throws {
        print("Purchase called with wordCount: \(wordCount), mode: \(mode)")
        purchaseState = .purchasing

        let productId = buildProductId(wordCount: wordCount, mode: mode)
        print("Built product ID: \(productId)")
        print("Currently loaded products: \(products.map { $0.id })")
        
        guard products.first(where: { $0.id == productId }) != nil else {
            print("Product not found: \(productId)")
            print("Available product IDs: \(products.map { $0.id })")
            throw StoreError.notAllowed
        }
        
        do {
            let products = try await Product.products(for: [productId])
            guard let product = products.first else {
                throw StoreError.notAllowed
            }
            
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                switch verification {
                case .verified(_):
                    purchaseState = .completed
                case .unverified(_, _):
                    throw StoreError.paymentFailed
                }
            case .pending:
                purchaseState = .purchasing
            case .userCancelled:
                throw StoreError.userCancelled
            @unknown default:
                throw StoreError.paymentFailed
            }
        } catch {
            purchaseState = .failed(error)
            throw error
        }
    }

    private func buildProductId(wordCount: Int, mode: TranslationSpeed) -> String {
        switch (wordCount, mode) {
        case (..<100_000, .standard):
            return "sxk90xow58sg"
        case (..<100_000, .fast):
            return "sxk90xow58sa"
        case (100_000..<200_000, .standard):
            return "sxk90xow58sb"
        case (100_000..<200_000, .fast):
            return "sxk90xow58sc"
        case (200_000..<300_000, .standard):
            return "sxk90xow58sd"
        case (200_000..<300_000, .fast):
            return "sxk90xow58se"
        case (300_000..., .standard):
            return "sxk90xow58f"
        case (300_000..., .fast):
            return "sxk90xow58sh"
        default:
                fatalError("Unsupported translation speed or word count")
        }
        
    }
}
