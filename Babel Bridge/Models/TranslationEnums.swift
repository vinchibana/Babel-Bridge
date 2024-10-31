extension TranslationMode {
    var description: String {
        switch self {
        case .standard:
            return "适合一般性文档翻译，平衡质量和成本"
        case .professional:
            return "适合专业文献翻译，注重专业术语准确性"
        case .literary:
            return "适合文学作品翻译，注重文学性和可读性"
        }
    }
}

extension TranslationSpeed {
    var description: String {
        switch self {
        case .fast:
            return "更快的翻译速度，适合时间紧迫的场景"
        case .normal:
            return "平衡的翻译速度，适合一般性需求"
        case .careful:
            return "更谨慎的翻译速度，适合需要高质量的场景"
        }
    }
} 
