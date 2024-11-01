import SwiftUI

struct FileUploadSectionView: View {
    @Binding var selectedFile: URL?
    @State private var isFilePickerPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("选择文件")
                .font(.headline)

            Button(action: {
                isFilePickerPresented = true
            }) {
                HStack {
                    Image(systemName: "doc")
                    Text(selectedFile?.lastPathComponent ?? "点击选择文件")
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
        }
        .fileImporter(
            isPresented: $isFilePickerPresented,
            allowedContentTypes: [
                .text,
                .init(filenameExtension: "epub")!,
            ],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case let .success(urls):
                if let url = urls.first {
                    selectedFile = url
                    print("Selected file: \(url.path)")
                }
            case let .failure(error):
                print("File selection error: \(error.localizedDescription)")
            }
        }
    }
}
