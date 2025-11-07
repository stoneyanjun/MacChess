//
//  GameView.swift
//  MacChess
//
//  Created by stone on 2025/11/7.
//

import SwiftUI
import ComposableArchitecture

struct GameView: View {
    let store: StoreOf<GameFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(spacing: 20) {
                VStack(spacing: 12) {
                    Text("Turn: \(viewStore.currentTurn == .white ? "White" : "Black")")
                        .font(.headline)

                    Spacer()

                    HStack {
                        Spacer()
                        BoardView(store: store)
                            .frame(width: 800, height: 800)
                        Spacer()
                    }

                    Spacer()

                    Button("Reset Game") {
                        viewStore.send(.reset)
                    }
                    .keyboardShortcut("r", modifiers: [.command])
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .windowBackgroundColor))
                .padding()

                // 🆕 Move history on right side
                MoveHistoryView(store: store)
            }
        }
    }
}
