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
    
    func analyzeFile(_ url: URL) {
        isAnalyzing = true
        error = nil
        bookInfo = nil
        
        Task {
            do {
                let analysis = try epubService.analyzeEPUB(at: url)
                
                DispatchQueue.main.async {
                    self.bookInfo = BookInfo(
                        title: analysis.title,
                        author: analysis.author,
                        wordCount: analysis.wordCount,
                        language: analysis.language
                    )
                    self.isAnalyzing = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error
                    self.isAnalyzing = false
                }
            }
        }
    }
}

struct BookInfo {
    let title: String
    let author: String?
    let wordCount: Int
    let language: String?
} 
