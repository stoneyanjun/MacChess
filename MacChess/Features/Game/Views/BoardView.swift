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
    private let files = ["a","b","c","d","e","f","g","h"]
    private let ranks = Array(1...8)

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { geo in
                let boardSize = min(geo.size.width, geo.size.height)
                let squareSize = boardSize / 8

                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        // Left rank labels
                        VStack(spacing: 0) {
                            ForEach(ranks.reversed(), id: \.self) { rank in
                                Text("\(rank)")
                                    .font(.system(size: 12, weight: .bold))
                                    .frame(width: 20, height: squareSize)
                            }
                        }

                        // Main board
                        VStack(spacing: 0) {
                            ForEach((0..<8).reversed(), id: \.self) { row in
                                HStack(spacing: 0) {
                                    ForEach(0..<8, id: \.self) { col in
                                        let square = Square(row: row, col: col)
                                        let piece = viewStore.board[row][col]
                                        SquareView(
                                            square: square,
                                            piece: piece,
                                            isSelected: square == viewStore.selectedSquare
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
                        Text(" ") // left margin align with rank labels
                            .frame(width: 20)
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
