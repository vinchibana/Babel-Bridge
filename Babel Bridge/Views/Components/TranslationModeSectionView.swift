import SwiftUI

struct TranslationModeSectionView: View {
    @Binding var mode: TranslationMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("翻译模式")
                .font(.headline)
            
            ForEach(TranslationMode.allCases, id: \.self) { translationMode in
                Button(action: { mode = translationMode }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(translationMode.rawValue)
                                .font(.subheadline)
                                .foregroundColor(mode == translationMode ? .white : .primary)
                            
                            Text(translationMode.description)
                                .font(.caption)
                                .foregroundColor(mode == translationMode ? .white.opacity(0.8) : .gray)
                        }
                        Spacer()
                        if mode == translationMode {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(mode == translationMode ? Color.blue : Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal)
    }
} 
