//
//  GameFeature.swift
//  MacChess
//
//  Created by stone on 2025/11/08.
//

import Foundation
import ComposableArchitecture

/// The TCA reducer for the Game feature.
/// Stage Two: handles piece selection, movement, validation, and turn control.
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
            state = GameState()            // reset entire game
            return .none

        // ------------------------------------------------------------
        // 2️⃣  User clicked a square
        // ------------------------------------------------------------
        case let .selectSquare(square):
            // If no selection yet → try selecting a piece
            if state.selectedSquare == nil {
                guard let piece = state.gameStatus.board.piece(at: square),
                      piece.color == state.currentTurn else {
                    return .none   // either empty square or wrong color
                }

                // Select this piece and compute its valid targets
                state.selectedSquare = square
                state.highlightSquares = generateLegalMoves(for: square, in: state)
                return .none
            }

            // If a piece is already selected
            let from = state.selectedSquare!
            //  Clicking same square again → cancel selection
            if square == from {
                state.selectedSquare = nil
                state.highlightSquares = []
                return .none
            }

            //  Otherwise → attempt a move
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
        // 4️⃣  Apply valid move
        // ------------------------------------------------------------
        case let .moveAccepted(from, to):
            state.gameStatus.move(from: from, to: to)
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
            // keep selection, do not toggle turn
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

    // MARK: - Helper: generate list of valid targets for selected piece
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
