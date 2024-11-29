import Foundation

enum TranslationError: Error {
    case uploadFailed
    case serverError(String)
    case invalidResponse
    case invalidURL(String)
}

class TranslationService {
    static let shared = TranslationService()
    #if DEBUG
    private let baseURL = "http://127.0.0.1:8000"  // 本地开发
    #else
    private let baseURL = "https://your-production-server.com"  // 生产环境
    #endif
    
    private init() {}
    
    func translateBook(url: URL, mode: TranslationMode, speed: TranslationSpeed, wordCount: Int) async throws -> URL {
        print("TranslationService: Starting translation for \(url.lastPathComponent)")
        let boundary = UUID().uuidString
        
        guard let requestURL = URL(string: "\(baseURL)/translate") else {
            throw TranslationError.invalidURL("\(baseURL)/translate")
        }
        
        print("TranslationService: Preparing request to \(requestURL)")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // 构建 multipart/form-data 请求体
        var data = Data()
        
        print("TranslationService: Reading file data...")
        let fileData = try Data(contentsOf: url)
        print("TranslationService: File size: \(fileData.count) bytes")
        
        // 添加文件
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(url.lastPathComponent)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: application/epub+zip\r\n\r\n".data(using: .utf8)!)
        data.append(fileData)
        
        // 添加其他参数
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"translation_speed\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(speed.rawValue)".data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"translation_mode\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(mode.rawValue)".data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"word_count\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(wordCount)".data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        // 设置请求体
        request.httpBody = data
        
        print("TranslationService: Sending request with body size: \(data.count) bytes")
        let (responseData, response) = try await URLSession.shared.data(for: request)
        print("TranslationService: Received response with size: \(responseData.count) bytes")
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TranslationError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorMessage = String(data: responseData, encoding: .utf8) {
                throw TranslationError.serverError(errorMessage)
            }
            throw TranslationError.serverError("Unknown error")
        }
        
        // 保存翻译后的文件到临时目录
        let tempDir = FileManager.default.temporaryDirectory
        let savedURL = tempDir.appendingPathComponent("\(url.deletingPathExtension().lastPathComponent)_translated.epub")
        try responseData.write(to: savedURL)
        
        return savedURL
    }
    
    // 可以临时添加这个测试函数到 TranslationService
    func testConnection() async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/health") else {
            print("Invalid URL: \(baseURL)/health")
            throw TranslationError.invalidResponse
        }
        
        print("Attempting to connect to: \(url)")
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                throw TranslationError.invalidResponse
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }
            
            print("Status code: \(httpResponse.statusCode)")
            return httpResponse.statusCode == 200
        } catch {
            print("Connection test failed with detailed error: \(error)")
            throw error
        }
    }
}
