import Foundation

struct Book: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let fileName: String
    let filePath: String
    let fileSize: Int64
    let targetLanguage: String
    let translationMode: TranslationMode
    let translationSpeed: TranslationSpeed
    var translationStatus: TranslationStatus
    
    init(
        title: String = "未知标题",
        author: String = "未知作者",
        fileName: String,
        filePath: String,
        fileSize: Int64 = 0,
        targetLanguage: String,
        translationMode: TranslationMode,
        translationSpeed: TranslationSpeed,
        translationStatus: TranslationStatus
    ) {
        self.title = title
        self.author = author
        self.fileName = fileName
        self.filePath = filePath
        self.fileSize = fileSize
        self.targetLanguage = targetLanguage
        self.translationMode = translationMode
        self.translationSpeed = translationSpeed
        self.translationStatus = translationStatus
    }
}

enum TranslationStatus {
    case inProgress
    case completed
} 
