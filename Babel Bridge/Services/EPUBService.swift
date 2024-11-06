import EPUBKit
import Foundation
import ZIPFoundation

enum EPUBServiceError: Error {
    case invalidFile
    case chapterReadError
    case accessDenied
    case unzipError
}

class EPUBService {
    struct EPUBAnalysis {
        let title: String
        let author: String?
        let wordCount: Int
        let language: String?
    }

    func analyzeEPUB(at url: URL) throws -> EPUBAnalysis {
        guard url.startAccessingSecurityScopedResource() else {
            throw EPUBServiceError.accessDenied
        }
        defer {
            url.stopAccessingSecurityScopedResource()
        }

        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)

        do {
            try FileManager.default.createDirectory(at: tempDirectory,
                                                    withIntermediateDirectories: true)

            let tempEPUBPath = tempDirectory.appendingPathComponent("book.epub")
            try FileManager.default.copyItem(at: url, to: tempEPUBPath)

            guard let document = EPUBDocument(url: tempEPUBPath) else {
                throw EPUBServiceError.invalidFile
            }

            let title = document.title ?? url.lastPathComponent
            let author = document.author
            let language = document.metadata.language

            var totalWordCount = 0
            for spineItem in document.spine.items {
                guard let manifestItem = document.manifest.items[spineItem.idref] else { continue }
                let fullPath = document.contentDirectory.appendingPathComponent(manifestItem.path)

                guard let data = try? Data(contentsOf: fullPath),
                      let content = String(data: data, encoding: .utf8)
                else {
                    continue
                }

                totalWordCount += countWords(in: content)
            }

            try? FileManager.default.removeItem(at: tempDirectory)

            return EPUBAnalysis(
                title: title,
                author: author,
                wordCount: totalWordCount,
                language: language
            )

        } catch {
            try? FileManager.default.removeItem(at: tempDirectory)
            throw error
        }
    }

    private func countWords(in text: String) -> Int {
        let cleanText = text.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)

        let chineseCount = cleanText.unicodeScalars.filter {
            $0.properties.isIdeographic ||
                ($0.value >= 0x4E00 && $0.value <= 0x9FFF) // CJK 统一汉字
        }.count

        let englishCount = cleanText.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty && $0.rangeOfCharacter(from: .letters) != nil }
            .count

        return chineseCount + englishCount
    }
}
