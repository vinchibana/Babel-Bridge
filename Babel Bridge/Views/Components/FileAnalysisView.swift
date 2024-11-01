import SwiftUI

struct FileAnalysisView: View {
    @ObservedObject var viewModel: FileAnalysisViewModel
    let url: URL
    
    var body: some View {
        Group {
            if viewModel.isAnalyzing {
                ProgressView("正在统计字数...")
            } else if let error = viewModel.error {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("分析失败")
                        .font(.headline)
                        .padding(.top)
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else if let wordCount = viewModel.wordCount {
                List {
                    Section("统计信息") {
                        InfoRow(title: "文件名", value: url.lastPathComponent)
                        InfoRow(title: "总字数", value: formatNumber(wordCount))
                    }
                }
            }
        }
        .onAppear {
            viewModel.analyzeFile(url)
        }
    }
    
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: number)) ?? String(number)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
}

// 预览
struct FileAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 加载中状态
            FileAnalysisView(
                viewModel: {
                    let vm = FileAnalysisViewModel()
                    vm.isAnalyzing = true
                    return vm
                }(),
                url: URL(fileURLWithPath: "example.epub")
            )
            
            // 显示结果状态
            FileAnalysisView(
                viewModel: {
                    let vm = FileAnalysisViewModel()
                    vm.wordCount = 100000
                    return vm
                }(),
                url: URL(fileURLWithPath: "example.epub")
            )
            
            // 错误状态
            FileAnalysisView(
                viewModel: {
                    let vm = FileAnalysisViewModel()
                    vm.error = EPUBServiceError.invalidFile
                    return vm
                }(),
                url: URL(fileURLWithPath: "example.epub")
            )
        }
    }
} 
