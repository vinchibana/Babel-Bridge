import SwiftUI

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
                    Text("\(String(format: "%.2f", Double(book.fileSize)/1024/1024))MB")
                    Text("•")
                    Image(systemName: "character.book.closed")
                    Text("\(book.fileName)")
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
