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
            // 🧩 Compute orientation-dependent labels
            let files = viewStore.isBoardFlipped
                ? ["h","g","f","e","d","c","b","a"]
                : ["a","b","c","d","e","f","g","h"]

            let ranks = viewStore.isBoardFlipped
                ? Array(1...8)   // bottom→top = 1→8 when flipped
                : Array((1...8).reversed()) // bottom→top = 8→1 normally

            HStack(spacing: 20) {
                VStack(spacing: 12) {
                    Text("Turn: \(viewStore.currentTurn == .white ? "White" : "Black")")
                        .font(.headline)

                    Spacer()

                    HStack {
                        Spacer()
                        BoardView(store: store, files: files, ranks: ranks)
                            .frame(width: 640, height: 640)
                        Spacer()
                    }

                    Spacer()

                    HStack(spacing: 20) {
                        Button("Reset Game") {
                            viewStore.send(.reset)
                        }
                        .keyboardShortcut("r", modifiers: [.command])

                        Button("Flip Board") {
                            viewStore.send(.toggleBoardFlip(!viewStore.isBoardFlipped))
                        }
                        .disabled(viewStore.hasStarted)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .windowBackgroundColor))
                .padding()

                MoveHistoryView(store: store)
            }
            .padding()
        }
    }
}
