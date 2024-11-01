import Foundation

class FileAnalysisViewModel: ObservableObject {
    @Published var wordCount: Int?
    @Published var isAnalyzing = false
    @Published var error: Error?
    
    private let epubService = EPUBService()
    
    func analyzeFile(_ url: URL) {
        isAnalyzing = true
        error = nil
        wordCount = nil
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let count = try self.epubService.countWordsInEPUB(at: url)
                DispatchQueue.main.async {
                    self.wordCount = count
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
