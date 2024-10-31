//
//  ContentView.swift
//  Babel Bridge
//
//  Created by 邱鑫 on 10/31/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BookViewModel()
    @State private var isShowingNewTranslation = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // 正在翻译部分
                VStack(alignment: .leading) {
                    Text("正在翻译")
                        .font(.title2)
                        .bold()
                    if viewModel.translatingBooks.isEmpty {
                        Text("暂无正在翻译的书籍")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(viewModel.translatingBooks) { book in
                            BookRow(book: book)
                        }
                    }
                }
                
                // 历史记录部分
                VStack(alignment: .leading) {
                    Text("历史记录")
                        .font(.title2)
                        .bold()
                    ForEach(viewModel.completedBooks) { book in
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
                NewTranslationView()
                    .environmentObject(viewModel)
            }
        }
    }
}


#Preview {
    ContentView()
}
