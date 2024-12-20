import SwiftUI

struct FileAnalysisView: View {
    @ObservedObject var viewModel: FileAnalysisViewModel
    let url: URL

    var body: some View {
        ScrollView {
            if viewModel.isAnalyzing {
                ProgressView("正在解析文件并评估价格...")
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
            } else if let wordCount = viewModel.bookInfo?.wordCount { // 修改这里
                // ... existing code ...
                List {
                    Section {
                        BookInfoView(title: "文件名", value: url.lastPathComponent)
                        BookInfoView(title: "总字数", value: formatNumber(wordCount))
                    } header: {
                        Text("统计信息")
                    }
                    Section {
                        BookInfoView(
                            title: "标准模式价格",
                            value: TranslationPrice.formatPrice(TranslationPrice.calculatePrice(wordCount: wordCount, mode: .standard))
                        )
                        BookInfoView(
                            title: "快速模式价格",
                            value: TranslationPrice.formatPrice(TranslationPrice.calculatePrice(wordCount: wordCount, mode: .fast))
                        )
                    } header: {
                        Text("价格")
                    }
                }.listStyle(.plain)
            }
        }
        .onAppear {
            Task {
                await viewModel.analyzeFile(url)
            }
        }
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: number)) ?? String(number)
    }
}

struct BookInfoView: View {
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
        ScrollView {
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
                    vm.bookInfo = BookInfo(
                        title: "示例书籍",
                        author: "作者名",
                        wordCount: 100_000,
                        language: "中文"
                    )
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
