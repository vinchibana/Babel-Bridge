import Foundation
import EPUBKit

enum EPUBServiceError: Error {
    case invalidFile
    case chapterReadError
}

class EPUBService {
    func countWordsInEPUB(at url: URL) throws -> Int {
        guard let document = EPUBDocument(url: url) else {
            throw EPUBServiceError.invalidFile
        }
        
        var totalWordCount = 0
        
        // Iterate over each spine item
        for spineItem in document.spine.items {
            // Get manifest item
            guard let manifestItem = document.manifest.items[spineItem.idref] else { continue }
            
            // Build full file path
            let fullPath = document.contentDirectory.appendingPathComponent(manifestItem.path)
            
            // Read content
            guard let data = try? Data(contentsOf: fullPath),
                  let content = String(data: data, encoding: .utf8) else {
                continue
            }
            
            let wordCount = countWords(in: content)
            totalWordCount += wordCount
        }
        
        return totalWordCount
    }
    
    private func countWords(in text: String) -> Int {
        // Count characters for Chinese text
        let chineseCount = text.unicodeScalars.filter { $0.properties.isIdeographic }.count
        let englishCount = text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .count
        
        return chineseCount + englishCount
    }
}
