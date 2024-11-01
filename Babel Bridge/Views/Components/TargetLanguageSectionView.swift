import SwiftUI

struct TargetLanguageSectionView: View {
    @Binding var selectedLanguage: String
    let availableLanguages: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("目标语言")
                .font(.headline)
            Picker("选择语言", selection: $selectedLanguage) {
                ForEach(availableLanguages, id: \.self) { language in
                    Text(language).tag(language)
                }
            }
            .pickerStyle(.menu)
        }
    }
} 
