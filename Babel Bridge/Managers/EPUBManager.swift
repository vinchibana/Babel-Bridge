import Foundation

class EPUBManager: ObservableObject {
    // 单例模式
    static let shared = EPUBManager()
    private init() {}
    
    // 状态管理
    @Published var isProcessing = false
    @Published var progress: Double = 0
    
    // 翻译一本书
    func translateBook(url: URL, 
                      targetLanguage: String, 
                      mode: TranslationMode,
                      speed: TranslationSpeed) async throws -> Book {
        isProcessing = true
        progress = 0
        
        guard url.startAccessingSecurityScopedResource() else {
            throw EPUBError.invalidFile
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        do {
            // 获取文件信息
            let bookInfo = try await EPUBService().analyzeEPUB(at: url)
            
            print("Starting translation request for: \(url.lastPathComponent)")
            // 调用翻译服务
            let translatedURL = try await TranslationService.shared.translateBook(
                url: url,
                mode: mode,
                speed: speed,
                wordCount: bookInfo.wordCount
            )
            print("Translation completed, saved to: \(translatedURL.path)")
            
            // 创建新的 Book 对象
            let book = Book(
                title: bookInfo.title,
                author: bookInfo.author ?? "未知作者",
                fileName: url.lastPathComponent,
                filePath: translatedURL.path,
                fileSize: (try? FileManager.default.attributesOfItem(atPath: translatedURL.path)[.size] as? Int64) ?? 0,
                targetLanguage: targetLanguage,
                translationMode: mode,
                translationSpeed: speed,
                translationStatus: .completed,
                wordCount: bookInfo.wordCount
            )
            
            isProcessing = false
            progress = 1.0
            
            return book
            
        } catch {
            isProcessing = false
            progress = 0
            print("Translation error: \(error)")
            throw error
        }
    }
    
    private func getTranslationConfig(mode: TranslationMode, speed: TranslationSpeed) -> TranslationConfig {
        var config = TranslationConfig()
        
        // 根据翻译模式设置参数
        switch mode {
        case .standard:
            config.temperature = 0.7
            config.maxTokens = 1000
        case .professional:
            config.temperature = 0.3
            config.maxTokens = 1500
            config.useSpecializedModel = true
        case .literary:
            config.temperature = 0.9
            config.maxTokens = 2000
            config.preserveStyle = true
        }
        
        // 根据翻译速度设置参数
        switch speed {
        case .fast:
            config.batchSize = 5000
            config.qualityCheck = false
        case .standard:
            config.batchSize = 2000
            config.qualityCheck = true
        }
        
        return config
    }
    
    private func parseEPUB(url: URL) async throws -> EPUBParser.EPUBContent {
        return try await EPUBParser.shared.parseEPUB(url: url)
    }
    
    private func translate(content: EPUBParser.EPUBContent,
                         to targetLanguage: String,
                         config: TranslationConfig) async throws -> EPUBParser.EPUBContent {
        // 实现翻译逻辑
        // 这里需要调用翻译 API
        return content // 临时返回原内容
    }
    
    private func saveTranslation(book: Book, content: EPUBParser.EPUBContent) async throws {
        // 实现保存逻辑
        // 将翻译后的内容保存为新的 EPUB 文件
    }
}

// 翻译配置结构体
struct TranslationConfig {
    var temperature: Double = 0.7
    var maxTokens: Int = 1000
    var batchSize: Int = 2000
    var qualityCheck: Bool = true
    var doubleCheck: Bool = false
    var useSpecializedModel: Bool = false
    var preserveStyle: Bool = false
}

// 错误处理
enum EPUBError: Error {
    case invalidFile
    case parseError
    case translationError
    case saveError
} 
