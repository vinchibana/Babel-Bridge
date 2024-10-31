import Foundation
import ZIPFoundation
import SWXMLHash

class EPUBParser {
    static let shared = EPUBParser()
    private init() {}
    
    struct EPUBContent {
        var title: String
        var author: String?
        var chapters: [Chapter]
        
        struct Chapter {
            var title: String
            var content: String
        }
    }
    
    func parseEPUB(url: URL) async throws -> EPUBContent {
        // 1. 创建临时目录
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        
        do {
            // 2. 解压 EPUB 文件
            try FileManager.default.createDirectory(at: tempDirectory, 
                                                 withIntermediateDirectories: true)
            try await unzipEPUB(from: url, to: tempDirectory)
            
            // 3. 解析 OPF 文件
            let opfURL = try findOPFFile(in: tempDirectory)
            let metadata = try parseOPFFile(at: opfURL)
            
            // 4. 解析内容文件
            let chapters = try await parseChapters(from: opfURL)
            
            // 5. 清理临时文件
            try? FileManager.default.removeItem(at: tempDirectory)
            
            return EPUBContent(
                title: metadata.title,
                author: metadata.author,
                chapters: chapters
            )
            
        } catch {
            // 确保清理临时文件
            try? FileManager.default.removeItem(at: tempDirectory)
            throw EPUBError.parseError
        }
    }
    
    private func unzipEPUB(from sourceURL: URL, to destinationURL: URL) async throws {
        let fileManager = FileManager.default
        
        do {
            try fileManager.unzipItem(at: sourceURL, to: destinationURL)
        } catch {
            throw EPUBError.parseError
        }
    }
    
    private struct EPUBMetadata {
        var title: String
        var author: String?
    }
    
    private func findOPFFile(in directory: URL) throws -> URL {
        let containerURL = directory.appendingPathComponent("META-INF/container.xml")
        
        guard let containerData = try? Data(contentsOf: containerURL) else {
            throw EPUBError.parseError
        }
        
        let xml = XMLHash.parse(containerData)
        
        guard let opfPath = xml["container"]["rootfiles"]["rootfile"]
            .element?.attribute(by: "full-path")?.text else {
            throw EPUBError.parseError
        }
        
        return directory.appendingPathComponent(opfPath)
    }
    
    private func parseOPFFile(at url: URL) throws -> EPUBMetadata {
        guard let data = try? Data(contentsOf: url) else {
            throw EPUBError.parseError
        }
        
        let xml = XMLHash.parse(data)
        
        let title = xml["package"]["metadata"]["dc:title"].element?.text ?? "未知标题"
        let author = xml["package"]["metadata"]["dc:creator"].element?.text
        
        return EPUBMetadata(title: title, author: author)
    }
    
    private func parseChapters(from opfURL: URL) async throws -> [EPUBContent.Chapter] {
        // 解析 spine 和 manifest 获取章节顺序和文件路径
        // 这里需要具体实现解析逻辑
        // 为了示例，返回空数组
        return []
    }
} 
