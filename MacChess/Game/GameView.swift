//
//  GameView.swift
//  MacChess
//
//  Created by stone on 2025/11/06.
//

import SwiftUI
import ComposableArchitecture

struct GameView: View {
    let store: StoreOf<GameFeature>
    private let files = ["a","b","c","d","e","f","g","h"]

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 2) {
                // Board area with rank labels
                HStack(alignment: .top, spacing: 2) {
                    // Rank labels (1–8)
                    VStack(spacing: 0) {
                        ForEach((1...8).reversed(), id: \.self) { rank in
                            Text("\(rank)")
                                .font(.system(size: 12, weight: .bold))
                                .frame(width: 20, height: 60)
                        }
                    }

                    // Chess board
                    VStack(spacing: 0) {
                        ForEach((0..<8).reversed(), id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<8, id: \.self) { col in
                                    ZStack {
                                        Rectangle()
                                            .fill(((row + col).isMultiple(of: 2)) ? Color.white : Color.gray)
                                        if let piece = viewStore.board[row][col] {
                                            Image(pieceImageName(piece))
                                                .resizable()
                                                .scaledToFit()
                                                .padding(1)
                                        }
                                    }
                                    .frame(width: 60, height: 60)
                                }
                            }
                        }
                    }
                }

                // File labels (a–h)
                HStack(spacing: 0) {
                    Spacer().frame(width: 20)
                    ForEach(files, id: \.self) { file in
                        Text(file)
                            .font(.system(size: 12, weight: .bold))
                            .frame(width: 60, height: 20)
                    }
                }
            }
            .padding()
        }
    }

    private func pieceImageName(_ piece: Piece) -> String {
        switch (piece.color, piece.type) {
        case (.black, .bishop): return "blackBishop"
        case (.black, .rook): return "blackCastle"
        case (.black, .king): return "blackKing"
        case (.black, .knight): return "blackKnight"
        case (.black, .pawn): return "blackPawn"
        case (.black, .queen): return "blackQueen"
        case (.white, .bishop): return "whiteBishop"
        case (.white, .rook): return "whiteCastle"
        case (.white, .king): return "whiteKing"
        case (.white, .knight): return "whiteKnight"
        case (.white, .pawn): return "whitePawn"
        case (.white, .queen): return "whiteQueen"
        }
    }
}
