import SwiftUI

struct NewTranslationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: BookViewModel
    
    // 状态变量
    @State private var selectedFile: URL?
    @State private var selectedLanguage: String = "英语"
    @State private var translationMode: TranslationMode = .standard
    @State private var translationSpeed: TranslationSpeed = .standard
    @StateObject private var analysisViewModel = FileAnalysisViewModel()
    
    // 常量
    private let availableLanguages = ["英语", "日语", "韩语", "法语", "德语"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 24) {
                        ExplanationSectionView()
                        
                        FileUploadSectionView(selectedFile: $selectedFile)
                        
                        if let url = selectedFile {
                            // 添加文件分析视图
                            FileAnalysisView(viewModel: analysisViewModel, url: url)
                                .padding(.vertical, 8)
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                        }
                        
                        TargetLanguageSectionView(
                            selectedLanguage: $selectedLanguage,
                            availableLanguages: availableLanguages
                        )
                        
                        TranslationModeSectionView(mode: $translationMode)
                        
                        TranslationSpeedSectionView(speed: $translationSpeed)
                        
                        Spacer()
                        
                        Button(action: submitTranslation) {
                            HStack {
                                Text("提交翻译")
                                Image(systemName: "arrow.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(selectedFile == nil || analysisViewModel.error != nil || analysisViewModel.isAnalyzing)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 16)
            }
            .navigationTitle("新增翻译")
            .navigationBarItems(
                leading: Button("取消") {
                    dismiss()
                },
                trailing: Button("帮助") {
                    // TODO: 显示帮助信息
                }
            )
        }
    }
    
    private func submitTranslation() {
        guard let url = selectedFile else { return }
        
        let newBook = Book(
            fileName: url.lastPathComponent,
            filePath: url.path,
            targetLanguage: selectedLanguage,
            translationMode: translationMode,
            translationSpeed: translationSpeed,
            translationStatus: .inProgress,
            wordCount: analysisViewModel.wordCount ?? 0 // 添加字数信息
        )
        
        viewModel.addBook(newBook)
        dismiss()
    }
}

// 枚举定义
enum TranslationMode: String, CaseIterable {
    case standard = "标准模式"
    case professional = "专业模式"
    case literary = "文学模式"
}

enum TranslationSpeed: String, CaseIterable {
    case fast = "快速"
    case standard = "标准"
}

// 预览
#Preview {
    NewTranslationView()
        .environmentObject(BookViewModel())
} 
