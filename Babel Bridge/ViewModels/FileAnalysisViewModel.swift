import Foundation

class FileAnalysisViewModel: ObservableObject {
    @Published var isAnalyzing = false
    @Published var error: Error?
    @Published var bookInfo: BookInfo?
    
    private let epubService = EPUBService()
    
    func reset() {
        isAnalyzing = false
        error = nil
        bookInfo = nil
    }
    
    @MainActor
    func analyzeFile(_ url: URL) async {
        isAnalyzing = true
        error = nil
        bookInfo = nil
        
        do {
            let analysis = try await epubService.analyzeEPUB(at: url)
            self.bookInfo = BookInfo(
                title: analysis.title,
                author: analysis.author,
                wordCount: analysis.wordCount,
                language: analysis.language
            )
            self.isAnalyzing = false
        } catch {
            self.error = error
            self.isAnalyzing = false
        }
    }
}

struct BookInfo {
    let title: String
    let author: String?
    let wordCount: Int
    let language: String?
}
