import SwiftUI

struct FileUploadSectionView: View {
    @Binding var selectedFile: URL?
    
    var body: some View {
        Button(action: {
            // 文件选择逻辑
        }) {
            HStack {
                Image(systemName: "doc.badge.plus")
                Text("选择文件")
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
    }
} 
