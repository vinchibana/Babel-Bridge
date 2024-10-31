//
//  ContentView.swift
//  Babel Bridge
//
//  Created by 邱鑫 on 10/31/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var books: [Book] = []
    @State private var isShowingNewTranslation = false
    
    var translatingBooks: [Book] {
        books.filter { $0.translationStatus == .inProgress }
    }
    
    var completedBooks: [Book] {
        books.filter { $0.translationStatus == .completed }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // 正在翻译部分
                VStack(alignment: .leading) {
                    Text("正在翻译")
                        .font(.title2)
                        .bold()
                    if translatingBooks.isEmpty {
                        Text("暂无正在翻译的书籍")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(translatingBooks) { book in
                            BookRow(book: book)
                        }
                    }
                }
                
                // 历史记录部分
                VStack(alignment: .leading) {
                    Text("历史记录")
                        .font(.title2)
                        .bold()
                    ForEach(completedBooks) { book in
                        BookRow(book: book)
                    }
                }
                
                Spacer()
                
                // 新增翻译按钮
                Button(action: { isShowingNewTranslation = true }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("新增翻译")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("书译")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: Text("设置")) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $isShowingNewTranslation) {
                NewTranslationView(isPresented: $isShowingNewTranslation, onSubmit: { book in
                    books.append(book)
                })
            }
        }
    }
}

struct BookRow: View {
    let book: Book
    
    var body: some View {
        HStack {
            Image(systemName: "book.closed")
                .resizable()
                .frame(width: 60, height: 80)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Image(systemName: "doc.text")
                    Text("\(String(format: "%.2f", Double(book.filePath.count)/1024/1024))MB")
                    Text("•")
                    Image(systemName: "character.book.closed")
                    Text("\(book.filePath.count)")
                }
                .font(.caption)
                .foregroundColor(.gray)
                
                if book.translationStatus == .completed {
                    Text("翻译完成")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            // 更多操作按钮
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

// 新建翻译视图
struct NewTranslationView: View {
    @Binding var isPresented: Bool
    let onSubmit: (Book) -> Void
    
    @State private var selectedFile: URL?
    @State private var targetFileName: String = ""
    @State private var targetLanguage: String = "简体中文"
    @State private var translationMode: TranslationMode = .bilingual
    @State private var translationSpeed: TranslationSpeed = .normal
    @State private var isImporting = false
    
    enum TranslationMode: String {
        case bilingual = "双语对照"
        case targetOnly = "仅目标语言"
    }
    
    enum TranslationSpeed: String {
        case normal = "普通"
        case fast = "快速"
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("从设备中选择需要翻译的书籍文件。我们根据原文 token 用量来确定翻译价格，在你提交后，再进行翻译。翻译完成时，你将收到我们的通知提醒。")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                // 文件上传区域
                Button(action: { isImporting = true }) {
                    VStack {
                        Image(systemName: "icloud.and.arrow.up")
                            .font(.largeTitle)
                            .padding()
                        Text("点击上传待翻译的书籍文件，支持 EPUB 格式，文件大小不超过 30 MB")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                            .foregroundColor(.gray)
                    )
                }
                .padding(.horizontal)
                
                // 目标文件名
                VStack(alignment: .leading) {
                    Text("目标文件名")
                        .font(.headline)
                    TextField("请输入文件名...", text: $targetFileName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                // 目标语言
                VStack(alignment: .leading) {
                    Text("目标语言")
                        .font(.headline)
                    Menu {
                        Button("简体中文") { targetLanguage = "简体中文" }
                        Button("繁体中文") { targetLanguage = "繁体中文" }
                    } label: {
                        HStack {
                            Text("🇨🇳 \(targetLanguage)")
                            Spacer()
                            Image(systemName: "chevron.down")
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2))
                        )
                    }
                }
                .padding(.horizontal)
                
                // 翻译模式
                VStack(alignment: .leading) {
                    Text("翻译模式")
                        .font(.headline)
                    HStack {
                        ForEach([TranslationMode.bilingual, .targetOnly], id: \.self) { mode in
                            Button(action: { translationMode = mode }) {
                                Text(mode.rawValue)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(translationMode == mode ? Color.blue : Color.clear)
                                    .foregroundColor(translationMode == mode ? .white : .primary)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.2))
                                    )
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // 翻译速度
                VStack(alignment: .leading) {
                    Text("翻译速度")
                        .font(.headline)
                    HStack {
                        ForEach([TranslationSpeed.normal, .fast], id: \.self) { speed in
                            Button(action: { translationSpeed = speed }) {
                                VStack {
                                    Image(systemName: speed == .normal ? "tortoise" : "hare")
                                    Text(speed.rawValue)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(translationSpeed == speed ? Color.blue.opacity(0.1) : Color.clear)
                                .foregroundColor(translationSpeed == speed ? .blue : .primary)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.2))
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 提交按钮
                Button(action: submitTranslation) {
                    Text("提交并翻译")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(selectedFile == nil || targetFileName.isEmpty)
            }
            .padding(.vertical)
            .navigationTitle("新增翻译")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        isPresented = false
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [UTType.epub],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                selectedFile = urls.first
                if let fileName = urls.first?.lastPathComponent {
                    targetFileName = fileName
                }
            case .failure(let error):
                print("文件选择失败: \(error)")
            }
        }
    }
    
    private func submitTranslation() {
        guard let url = selectedFile else { return }
        do {
            let book = try EPUBManager.shared.importEPUB(from: url)
            onSubmit(book)
            isPresented = false
        } catch {
            print("导入失败: \(error)")
        }
    }
}


#Preview {
    ContentView()
}
