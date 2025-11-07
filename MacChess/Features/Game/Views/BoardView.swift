//
//  BoardView.swift
//  MacChess
//
//  Created by stone on 2025/11/07.
//

import SwiftUI
import ComposableArchitecture

/// Displays the 8×8 chessboard grid with all squares and pieces.
/// Stage Two: now passes the TCA store to each SquareView for interactivity.
struct BoardView: View {
    let store: StoreOf<GameFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                // Render ranks from top (8) → bottom (1)
                ForEach((0..<8).reversed(), id: \.self) { rank in
                    HStack(spacing: 0) {
                        // Render files left → right (a → h)
                        ForEach(0..<8, id: \.self) { file in
                            let square = Square(file: file, rank: rank)
                            SquareView(
                                store: store,
                                square: square,
                                piece: viewStore.gameStatus.board.grid[rank][file]
                            )
                            .frame(width: 80, height: 80)  // Each square fixed 80×80 (total 640×640)
                        }
                    }
                }
            }
            .frame(width: 640, height: 640)
            .border(Color(NSColor.separatorColor), width: 1)
        }
    }
}
