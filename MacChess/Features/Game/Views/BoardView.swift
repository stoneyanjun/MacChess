//
//  BoardView.swift
//  MacChess
//
//  Created by stone on 2025/11/7.
//

import SwiftUI
import ComposableArchitecture

struct BoardView: View {
    let store: StoreOf<GameFeature>
    let files: [String]
    let ranks: [Int]

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { geo in
                let boardSize = min(geo.size.width, geo.size.height)
                let squareSize = boardSize / 8

                VStack(spacing: 0) {
                    // Main board area
                    HStack(spacing: 0) {
                        // Left rank labels
                        VStack(spacing: 0) {
                            ForEach(ranks, id: \.self) { rank in
                                Text("\(rank)")
                                    .font(.system(size: 12, weight: .bold))
                                    .frame(width: 20, height: squareSize)
                            }
                        }

                        // 8×8 Squares
                        VStack(spacing: 0) {
                            ForEach(ranks.indices, id: \.self) { rIndex in
                                let row = viewStore.isBoardFlipped ? rIndex : (7 - rIndex)
                                HStack(spacing: 0) {
                                    ForEach(0..<8, id: \.self) { cIndex in
                                        let col = viewStore.isBoardFlipped ? (7 - cIndex) : cIndex
                                        let square = Square(row: row, col: col)
                                        let piece = viewStore.board[row][col]

                                        SquareView(
                                            square: square,
                                            piece: piece,
                                            isSelected: square == viewStore.selectedSquare,
                                            isFlipped: viewStore.isBoardFlipped
                                        )
                                        .frame(width: squareSize, height: squareSize)
                                        .onTapGesture {
                                            viewStore.send(.selectSquare(square))
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Bottom file labels
                    HStack(spacing: 0) {
                        Text(" ").frame(width: 20)
                        ForEach(files, id: \.self) { file in
                            Text(file)
                                .font(.system(size: 12, weight: .bold))
                                .frame(width: squareSize, height: 20)
                        }
                    }
                }
            }
        }
    }
}
