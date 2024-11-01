import SwiftUI

struct ExplanationSectionView: View {
    var body: some View {
        Text("从设备中选择需要翻译的书籍文件。我们根据原文 token 用量来确定翻译价格，在你提交后，再进行翻译。翻译完成时，你将收到我们的通知提醒。")
            .font(.subheadline)
            .foregroundColor(.gray)
    }
} 
