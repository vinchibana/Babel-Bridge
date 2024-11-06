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

    enum PurchaseState {
        case notStarted
        case purchasing
        case completed
        case failed(Error)
    }

    private init() {
        print("StoreKitService initialized")
        Task {
            await loadProducts()
        }
    }

    // 添加加载产品的方法
    func loadProducts() async {
        print("Loading products...")
        let productIds = Set(TranslationSpeed.allCases.flatMap { speed in
            ["100k", "200k", "300k", "400k", "500k", "600k", "unlimited"].map { tier in
                "translation.\(speed.rawValue.lowercased()).\(tier)"
            }
        })

        print("Product IDs to load: \(productIds)")

        do {
            products = try await Product.products(for: productIds)
            print("Successfully loaded \(products.count) products")
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    func purchase(wordCount: Int, mode: TranslationSpeed) async throws {
        print("Purchase called with wordCount: \(wordCount), mode: \(mode)")
        purchaseState = .purchasing

        // 构建产品 ID，例如: "translation.standard.100k"
        let productId = buildProductId(wordCount: wordCount, mode: mode)
        print("Built product ID: \(productId)")
        print("Currently loaded products: \(products.map { $0.id })")
        // 从已加载的产品中查找
        guard products.first(where: { $0.id == productId }) != nil else {
            print("Product not found: \(productId)")

            throw StoreError.notAllowed
        }
        do {
            // 获取产品信息
            let products = try await Product.products(for: [productId])
            guard let product = products.first else {
                throw StoreError.notAllowed
            }
            print("get")
            // 发起购买
            let result = try await product.purchase()

            switch result {
            case let .success(verification):
                // 验证购买
                switch verification {
                case .verified:
                    purchaseState = .completed
                case .unverified:
                    throw StoreError.paymentFailed
                }
            case .userCancelled:
                throw StoreError.userCancelled
            case .pending:
                purchaseState = .purchasing
            @unknown default:
                throw StoreError.paymentFailed
            }
        } catch {
            purchaseState = .failed(error)
            throw error
        }
    }

    private func buildProductId(wordCount: Int, mode: TranslationSpeed) -> String {
        let tier: String

        switch wordCount {
        case ..<100_000:
            tier = "100k"
        case 100_000 ..< 200_000:
            tier = "200k"
        case 200_000 ..< 300_000:
            tier = "300k"
        case 300_000 ..< 400_000:
            tier = "400k"
        case 400_000 ..< 500_000:
            tier = "500k"
        case 500_000 ..< 600_000:
            tier = "600k"
        default:
            tier = "unlimited"
        }

        return "translation.\(mode.rawValue.lowercased()).\(tier)"
    }
}
