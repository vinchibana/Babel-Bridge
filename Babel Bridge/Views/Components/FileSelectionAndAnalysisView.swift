import SwiftUI

struct FileSelectionAndAnalysisView: View {
    @Binding var selectedFile: URL?
    @StateObject private var analysisViewModel = FileAnalysisViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if selectedFile == nil {
                // 未选择文件时显示文件选择视图
                FileUploadSectionView(selectedFile: $selectedFile)
            } else if selectedFile != nil {
                // 已选择文件，显示分析结果或书籍信息
                VStack(alignment: .leading, spacing: 16) {
                    // 标题栏
                    HStack {
                        Text("文件信息")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            selectedFile = nil
                            analysisViewModel.reset()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }

                    if analysisViewModel.isAnalyzing {
                        // 分析中状态
                        ProgressView("正在解析文件...")
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else if let error = analysisViewModel.error {
                        // 错误状态
                        FileAnalysisErrorView(error: error)
                    } else if analysisViewModel.bookInfo != nil {
                        // 显示书籍信息
                        BookDetailView(bookInfo: analysisViewModel.bookInfo!)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
        }
        .onChange(of: selectedFile) { newValue in
            if let url = newValue {
                analysisViewModel.analyzeFile(url)
            }
        }
    }
}

// 错误视图
struct FileAnalysisErrorView: View {
    let error: Error

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("文件解析失败")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// 书籍信息视图
struct BookDetailView: View {
    let bookInfo: BookInfo

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: number)) ?? String(number)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // 左侧图书封面占位图
            Image(systemName: "book.closed.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 140)
                .foregroundColor(.gray)
                .background(Color(.systemGray6))
                .cornerRadius(8)

            // 右侧信息
            VStack(alignment: .leading, spacing: 12) {
                BookInfoRow(title: "标题", value: bookInfo.title)
                if let author = bookInfo.author {
                    BookInfoRow(title: "作者", value: author)
                }
                BookInfoRow(title: "字数", value: formatNumber(bookInfo.wordCount))
                if let language = bookInfo.language {
                    BookInfoRow(title: "语言", value: language)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color(.systemGray4).opacity(0.5), radius: 5, x: 0, y: 2)
    }
}

// 信息行视图
struct BookInfoRow: View {
    let title: String
    let value: String

    private var icon: String {
        switch title {
        case "标题": return "book"
        case "作者": return "person"
        case "字数": return "number.rectangle"
        case "语言": return "globe"
        default: return "doc"
        }
    }

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
    }
}
