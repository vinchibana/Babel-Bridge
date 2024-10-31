import SwiftUI

struct FileNameSectionView: View {
    let fileName: String?
    
    var body: some View {
        if let name = fileName {
            HStack {
                Image(systemName: "doc.fill")
                Text(name)
                    .lineLimit(1)
            }
            .padding(.horizontal)
        }
    }
} 
