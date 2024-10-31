//
//  TranslationSpeedSectionView.swift
//  Babel Bridge
//
//  Created by 邱鑫 on 10/31/24.
//
import SwiftUI

struct TranslationSpeedSectionView: View {
    @Binding var speed: TranslationSpeed
    
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                Text("翻译速度")
                    .font(.headline)
                
                Picker("翻译速度", selection: $speed) {
                    ForEach([TranslationSpeed.fast, TranslationSpeed.standard], id: \.self) { speed in
                        Text(speed.rawValue).tag(speed)
                    }
                }
                .pickerStyle(.segmented)
                .frame(height: 62) // 添加固定高度
            }
            .padding(.vertical, 8)
        }
    }
}
