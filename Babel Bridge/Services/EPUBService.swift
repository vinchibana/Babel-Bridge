import Foundation
import EPUBKit
import ZIPFoundation

enum EPUBServiceError: Error {
    case invalidFile
    case chapterReadError
    case accessDenied
    case unzipError
}

class EPUBService {
    func countWordsInEPUB(at url: URL) throws -> Int {
        // 1. 确保文件可访问
        guard url.startAccessingSecurityScopedResource() else {
            throw EPUBServiceError.accessDenied
        }
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        // 2. 创建临时目录
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        
        do {
            // 3. 创建临时目录
            try FileManager.default.createDirectory(at: tempDirectory, 
                                                 withIntermediateDirectories: true)
            
            // 4. 复制文件到临时目录
            let tempEPUBPath = tempDirectory.appendingPathComponent("book.epub")
            try FileManager.default.copyItem(at: url, to: tempEPUBPath)
            
            // 5. 初始化 EPUBDocument
            guard let document = EPUBDocument(url: tempEPUBPath) else {
                throw EPUBServiceError.invalidFile
            }
            
            var totalWordCount = 0
            
            // 6. 遍历并统计字数
            for spineItem in document.spine.items {
                guard let manifestItem = document.manifest.items[spineItem.idref] else { continue }
                
                let fullPath = document.contentDirectory.appendingPathComponent(manifestItem.path)
                
                guard let data = try? Data(contentsOf: fullPath),
                      let content = String(data: data, encoding: .utf8) else {
                    continue
                }
                
                let wordCount = countWords(in: content)
                totalWordCount += wordCount
            }
            
            // 7. 清理临时文件
            try? FileManager.default.removeItem(at: tempDirectory)
            
            return totalWordCount
            
        } catch {
            // 清理临时文件
            try? FileManager.default.removeItem(at: tempDirectory)
            throw error
        }
    }
    
    private func countWords(in text: String) -> Int {
        // 移除 HTML 标签
        let cleanText = text.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        
        // 统计中文字符
        let chineseCount = cleanText.unicodeScalars.filter { 
            $0.properties.isIdeographic || 
            ($0.value >= 0x4E00 && $0.value <= 0x9FFF) // CJK 统一汉字
        }.count
        
        // 统计英文单词
        let englishCount = cleanText.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty && $0.rangeOfCharacter(from: .letters) != nil }
            .count
        
        return chineseCount + englishCount
    }
}
