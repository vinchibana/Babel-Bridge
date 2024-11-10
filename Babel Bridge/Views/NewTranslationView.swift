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
    @State private var connectionTestMessage: String = ""
    @State private var showingConnectionTest = false

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

                        Button("测试服务器连接") {
                            Task {
                                do {
                                    connectionTestMessage = "正在测试连接..."
                                    showingConnectionTest = true
                                    let isConnected = try await TranslationService.shared.testConnection()
                                    connectionTestMessage = isConnected ? "连接成功" : "连接失败"
                                } catch {
                                    connectionTestMessage = "连接错误: \(error.localizedDescription)"
                                }
                            }
                        }
                        .alert("连接测试", isPresented: $showingConnectionTest) {
                            Button("确定", role: .cancel) {}
                        } message: {
                            Text(connectionTestMessage)
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
        print("Starting translation process...")
        guard let url = selectedFile,
              let wordCount = analysisViewModel.bookInfo?.wordCount else {
            print("Missing required information")
            return
        }
        
        do {
            // 1. 检查支付状态
            if storeService.purchaseState == .notStarted {
                // 2. 尝试购买
                print("Attempting to purchase...")
                try await storeService.purchase(wordCount: wordCount, mode: translationSpeed)
            }
            
            // 3. 确认购买完成
            guard storeService.purchaseState == .completed else {
                print("Purchase not completed. Current state: \(storeService.purchaseState)")
                if case .failed(let error) = storeService.purchaseState {
                    throw error
                }
                return
            }
            
            print("Purchase successful, proceeding with translation...")
            
            // 4. 开始翻译
            print("Starting translation...")
            let translatedBook = try await EPUBManager.shared.translateBook(
                url: url,
                targetLanguage: selectedLanguage,
                mode: translationMode,
                speed: translationSpeed
            )
            
            // 5. 添加到书籍列表
            print("Adding translated book to library...")
            await MainActor.run {
                viewModel.addBook(translatedBook)
                dismiss()
            }
            
        } catch {
            await MainActor.run {
                print("Error during process: \(error)")
                paymentErrorMessage = error.localizedDescription
                showingPaymentError = true
            }
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
