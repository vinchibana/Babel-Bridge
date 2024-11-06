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
        case 300_000..<400_000:
            return isStandard ? 3.49 : 4.19
        case 400_000..<500_000:
            return isStandard ? 4.19 : 4.89
        case 500_000..<600_000:
            return isStandard ? 5.09 : 5.89
        default: // 600_000 及以上
            return isStandard ? 8.39 : 9.99
        }
    }
    
    static func formatPrice(_ price: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: price as NSDecimalNumber) ?? "$0.00"
    }
} 
