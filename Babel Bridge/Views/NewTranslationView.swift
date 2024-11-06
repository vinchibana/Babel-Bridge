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
    @StateObject private var storeService = StoreKitService.shared
    @State private var showingPaymentError = false
    @State private var paymentErrorMessage = ""

    // 常量
    private let availableLanguages = ["英语", "日语", "韩语", "法语", "德语"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 24) {
                        ExplanationSectionView()

                        FileSelectionAndAnalysisView(
                            selectedFile: $selectedFile,
                            analysisViewModel: analysisViewModel
                        )

                        TargetLanguageSectionView(
                            selectedLanguage: $selectedLanguage,
                            availableLanguages: availableLanguages
                        )

                        TranslationModeSectionView(mode: $translationMode)

                        TranslationSpeedSectionView(speed: $translationSpeed)

                        Spacer()

                        Button(action: {
                            print("Submit button tapped")
                            print("Current file: \(String(describing: selectedFile))")
                            print("Current analysis status: \(analysisViewModel.isAnalyzing)")
                            print("Current bookInfo: \(String(describing: analysisViewModel.bookInfo))")
                            
                            Task {
                                await startTranslation()
                            }
                        }) {
                            HStack {
                                Text("提交翻译")
                                if let wordCount = analysisViewModel.bookInfo?.wordCount {
                                    Text("(\(TranslationPrice.formatPrice(TranslationPrice.calculatePrice(wordCount: wordCount, mode: translationSpeed))))")
                                }
                                Image(systemName: "arrow.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(selectedFile == nil || analysisViewModel.error != nil || analysisViewModel.isAnalyzing)
                        .alert("支付失败", isPresented: $showingPaymentError) {
                            Button("确定", role: .cancel) {}
                        } message: {
                            Text(paymentErrorMessage)
                        }
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
            wordCount: analysisViewModel.bookInfo?.wordCount ?? 0 // 添加字数信息
        )

        viewModel.addBook(newBook)
        dismiss()
    }

    private func startTranslation() async {
        print("Starting translation...")
        print("AnalysisViewModel state:")
        print("- isAnalyzing: \(analysisViewModel.isAnalyzing)")
        print("- error: \(String(describing: analysisViewModel.error))")
        print("- bookInfo: \(String(describing: analysisViewModel.bookInfo))")
        
        guard let wordCount = analysisViewModel.bookInfo?.wordCount else {
            print("Word count is nil")
            return
        }
        
        print("Word count: \(wordCount)")
        
        do {
            print("Attempting to purchase...")
            try await storeService.purchase(wordCount: wordCount, mode: translationSpeed)
            print("Purchase successful")
            submitTranslation()
        } catch StoreError.userCancelled {
            print("Purchase cancelled by user")
        } catch {
            print("Purchase failed with error: \(error)")
            paymentErrorMessage = error.localizedDescription
            showingPaymentError = true
        }
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
