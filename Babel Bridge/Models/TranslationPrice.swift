import Foundation

struct TranslationPrice {
    static func calculatePrice(wordCount: Int, mode: TranslationSpeed) -> Decimal {
        let isStandard = mode == .standard
        
        switch wordCount {
        case ..<100_000:
            return isStandard ? 0.89 : 0.99
        case 100_000..<200_000:
            return isStandard ? 1.69 : 1.89
        case 200_000..<300_000:
            return isStandard ? 2.89 : 3.29
        default: // 300_000 及以上
            return isStandard ? 3.99 : 5.99
        }
    }
    
    static func formatPrice(_ price: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: price as NSDecimalNumber) ?? "$0.00"
    }
} 
