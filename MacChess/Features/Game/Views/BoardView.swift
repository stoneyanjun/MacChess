//
//  BoardView.swift
//  MacChess
//
//  Created by stone on 2025/11/07.
//

import SwiftUI
import ComposableArchitecture

/// Displays all 64 squares in correct chess orientation.
/// White pieces at bottom, a1 is dark.
struct BoardView: View {
    let store: StoreOf<GameFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                // Draw ranks top (8) → bottom (1)
                ForEach((0..<8).reversed(), id: \.self) { rank in
                    HStack(spacing: 0) {
                        // Draw files a → h
                        ForEach(0..<8, id: \.self) { file in
                            let square = Square(file: file, rank: rank)
                            SquareView(
                                store: store,
                                square: square,
                                piece: viewStore.gameStatus.board.piece(at: square)
                            )
                            .frame(width: 80, height: 80)
                        }
                    }
                }
            }
            .frame(width: 640, height: 640)
            .border(Color(NSColor.separatorColor), width: 1)
        }
    }
}
