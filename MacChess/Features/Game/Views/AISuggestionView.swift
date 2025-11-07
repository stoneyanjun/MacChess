//
//  AISuggestionView.swift
//  MacChess
//
//  Created by stone on 2025/11/7.
//

import ComposableArchitecture
import SwiftUI

struct AISuggestionView: View {
//    @ObservedObject var engine = GameFeature.State.sharedEngine

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("AI Suggestion")
                .font(.headline)
//            Text(engine.suggestion)
//                .font(.system(size: 14))
//                .padding(8)
//                .frame(maxWidth: 200, alignment: .leading)
//                .background(Color.orange.opacity(0.15))
//                .cornerRadius(6)
            Spacer()
        }
        .padding()
        .frame(width: 220)
        .border(Color.gray.opacity(0.4))
    }
}
