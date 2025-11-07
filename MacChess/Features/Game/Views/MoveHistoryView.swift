//
//  MoveHistoryView.swift
//  MacChess
//
//  Created by stone on 2025/11/7.
//


import SwiftUI
import ComposableArchitecture

struct MoveHistoryView: View {
    let store: StoreOf<GameFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 4) {
                Text("Move History")
                    .font(.headline)
                    .padding(.bottom, 6)

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        // Group by moveNumber
                        ForEach(groupedMoves(viewStore.moveHistory), id: \.0) { moveNumber, moves in
                            let whiteMove = moves.first(where: { $0.color == .white })
                            let blackMove = moves.first(where: { $0.color == .black })
                            let isLatest = moves.contains { $0.id == viewStore.moveHistory.last?.id }

                            HStack {
                                Text("\(moveNumber).")
                                    .frame(width: 25, alignment: .trailing)
                                Text(whiteMove?.notation ?? "")
                                    .frame(width: 60, alignment: .leading)
                                Text(blackMove?.notation ?? "")
                                    .frame(width: 60, alignment: .leading)
                            }
                            .padding(4)
                            .background(isLatest ? Color.orange.opacity(0.3) : Color.clear)
                            .cornerRadius(4)
                        }
                    }
                }
            }
            .padding()
            .frame(width: 200)
            .border(Color.gray.opacity(0.4))
        }
    }

    /// Groups moves by moveNumber into tuples (moveNumber, [moves])
    private func groupedMoves(_ moves: [MoveRecord]) -> [(Int, [MoveRecord])] {
        let grouped = Dictionary(grouping: moves) { $0.moveNumber }
        return grouped.keys.sorted().map { ($0, grouped[$0] ?? []) }
    }
}
