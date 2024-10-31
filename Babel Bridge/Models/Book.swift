import Foundation
struct Book: Identifiable, Codable {

    let id: UUID
    let title: String
    let author: String
    let filePath: String
    var translatedFilePath: String?
    var translationStatus: TranslationStatus
    
    enum TranslationStatus: String, Codable {
        case notStarted
        case inProgress
        case completed
        case failed
    }
    
    init(id: UUID = UUID(), title: String, author: String, filePath: String) {
        self.id = id
        self.title = title
        self.author = author
        self.filePath = filePath
        self.translationStatus = .notStarted
        self.targetFileName = ""
        self.targetLanguage = ""
        self.translationMode = .bilingual
        self.translationSpeed = .normal
    }
    
    var targetFileName: String
    var targetLanguage: String
    var translationMode: TranslationMode
    var translationSpeed: TranslationSpeed
    
    enum TranslationMode: String, Codable {
        case bilingual = "双语对照"
        case targetOnly = "仅目标语言"
    }
    
    enum TranslationSpeed: String, Codable {
        case normal = "普通"
        case fast = "快速"
    }
} 
