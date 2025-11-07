//
//  GameFeature.swift
//  MacChess
//
//  Created by stone on 2025/11/08.
//

import Foundation
import ComposableArchitecture

/// The TCA reducer for the Game feature.
/// Stage Three (extended): adds move recording and index control.
struct GameFeature: Reducer, Sendable {

    // MARK: - Associated types
    typealias State = GameState
    typealias Action = GameAction

    // MARK: - Reducer
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {

        // ------------------------------------------------------------
        // 1️⃣  Initialize game on appear
        // ------------------------------------------------------------
        case .onAppear:
            state = GameState()
            return .none

        // ------------------------------------------------------------
        // 2️⃣  User clicked a square
        // ------------------------------------------------------------
        case let .selectSquare(square):
            if state.selectedSquare == nil {
                guard let piece = state.gameStatus.board.piece(at: square),
                      piece.color == state.currentTurn else {
                    return .none
                }
                state.selectedSquare = square
                state.highlightSquares = generateLegalMoves(for: square, in: state)
                return .none
            }

            let from = state.selectedSquare!
            if square == from {
                state.selectedSquare = nil
                state.highlightSquares = []
                return .none
            }

            return .send(.attemptMove(from: from, to: square))

        // ------------------------------------------------------------
        // 3️⃣  Attempt to move a piece
        // ------------------------------------------------------------
        case let .attemptMove(from, to):
            let board = state.gameStatus.board
            let color = state.currentTurn
            if MoveValidator.isLegalMove(board: board, from: from, to: to, color: color) {
                return .send(.moveAccepted(from: from, to: to))
            } else {
                return .send(.invalidMove(from: from, to: to))
            }

        // ------------------------------------------------------------
        // 4️⃣  Apply valid move & record history
        // ------------------------------------------------------------
        case let .moveAccepted(from, to):
            // Apply move
            state.gameStatus.move(from: from, to: to)

            // Record move in Stockfish-compatible format
            let record = MoveRecord(
                index: state.moveIndex,
                color: state.currentTurn,
                from: from,
                to: to
            )
            state.moveHistory.append(record)

            // Advance move index only after black’s move
            if state.currentTurn == .black {
                state.moveIndex += 1
            }

            // Switch turn and reset UI state
            state.currentTurn.toggle()
            state.selectedSquare = nil
            state.highlightSquares = []
            state.invalidMoveFlash = false
            return .none

        // ------------------------------------------------------------
        // 5️⃣  Handle invalid move
        // ------------------------------------------------------------
        case .invalidMove:
            state.invalidMoveFlash = true
            return .none

        // ------------------------------------------------------------
        // 6️⃣  Restart / Undo / Internal
        // ------------------------------------------------------------
        case .restart:
            state = GameState()
            return .none

        case .undo, .internalError:
            return .none
        }
    }

    // MARK: - Helper: generate list of valid targets
    private func generateLegalMoves(for from: Square, in state: State) -> [Square] {
        var moves: [Square] = []
        for rank in 0..<8 {
            for file in 0..<8 {
                let to = Square(file: file, rank: rank)
                if MoveValidator.isLegalMove(
                    board: state.gameStatus.board,
                    from: from,
                    to: to,
                    color: state.currentTurn
                ) {
                    moves.append(to)
                }
            }
        }
        return moves
    }
}
