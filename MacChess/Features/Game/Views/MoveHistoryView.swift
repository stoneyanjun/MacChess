//
//  MoveHistoryView.swift
//  MacChess
//
//  Created by stone on 2025/11/7.
//

import SwiftUI

/// Displays a scrollable list of all moves in the current game.
/// Stage Three: standalone; integration with GameView comes later.
struct MoveHistoryView: View {
    /// List of recorded moves (alternating white/black).
    let moves: [MoveRecord]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 6) {
                ForEach(groupedMoves(), id: \.0) { index, pair in
                    HStack {
                        Text("\(index).")
                            .font(.system(size: 16, weight: .bold))
                            .frame(width: 24, alignment: .trailing)
                        Text(pair.white ?? "")
                            .font(.system(size: 16))
                            .frame(width: 48, alignment: .leading)
                        Text(pair.black ?? "")
                            .font(.system(size: 16))
                            .frame(width: 48, alignment: .leading)
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                }
            }
            .padding(8)
        }
        .frame(width: 180)
        .background(Color(NSColor.textBackgroundColor))
        .border(Color(NSColor.separatorColor))
    }

    /// Groups the flat move list into tuples: (moveNumber, (white, black))
    private func groupedMoves() -> [(Int, (white: String?, black: String?))] {
        var result: [(Int, (String?, String?))] = []
        var currentIndex = 0
        while currentIndex < moves.count {
            let whiteMove = moves[currentIndex]
            var blackMove: MoveRecord?
            if currentIndex + 1 < moves.count {
                blackMove = moves[currentIndex + 1]
            }
            let moveNumber = whiteMove.color == .white ? whiteMove.index : whiteMove.index
            result.append((moveNumber, (whiteMove.notation, blackMove?.notation)))
            currentIndex += 2
        }
        return result
    }
}

#Preview {
    // Sample data
    let sampleMoves: [MoveRecord] = [
        MoveRecord(index: 1, color: .white, from: Square(file: 4, rank: 1), to: Square(file: 4, rank: 3)), // e2e4
        MoveRecord(index: 1, color: .black, from: Square(file: 4, rank: 6), to: Square(file: 4, rank: 4)), // e7e5
        MoveRecord(index: 2, color: .white, from: Square(file: 6, rank: 0), to: Square(file: 5, rank: 2)), // g1f3
    ]
    MoveHistoryView(moves: sampleMoves)
        .frame(height: 200)
}
