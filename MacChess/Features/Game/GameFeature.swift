//
//  GameFeature.swift
//  MacChess
//
//  Created by stone on 2025/11/08.
//

import Foundation
import ComposableArchitecture

/// The TCA reducer for the Game feature.
/// Stage 5.1 + Logging: integrates Stockfish engine and prints all moves sent.
struct GameFeature: Reducer, Sendable {

    typealias State = GameState
    typealias Action = GameAction

    @Dependency(\.stockfishEngine) var engine

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
            
        case .onAppear:
            state = GameState()
            return .run { _ in
                await engine.start()
            }

        case let .selectSquare(square):
            if state.selectedSquare == nil {
                guard let piece = state.gameStatus.board.piece(at: square),
                      piece.color == state.currentTurn else { return .none }
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

        case let .attemptMove(from, to):
            let board = state.gameStatus.board
            let color = state.currentTurn
            if MoveValidator.isLegalMove(board: board, from: from, to: to, color: color) {
                return .send(.moveAccepted(from: from, to: to))
            } else {
                return .send(.invalidMove(from: from, to: to))
            }

        case let .moveAccepted(from, to):
            state.gameStatus.move(from: from, to: to)
            let record = MoveRecord(index: state.moveIndex, color: state.currentTurn, from: from, to: to)
            state.moveHistory.append(record)
            if state.currentTurn == .black { state.moveIndex += 1 }
            state.currentTurn.toggle()
            state.selectedSquare = nil
            state.highlightSquares = []
            state.invalidMoveFlash = false
            state.isAnalyzing = true
            return .send(.requestEngineSuggestion)

        case .invalidMove:
            state.invalidMoveFlash = true
            return .none

        // ------------------------------------------------------------
        // 🔍 Engine: request analysis (with move logging)
        // ------------------------------------------------------------
        case .requestEngineSuggestion:
            state.isAnalyzing = true
            return .run { [moves = state.moveHistory] send in
                let moveString = moves.map(\.notation).joined(separator: " ")
                print("📤 Sending moves to Stockfish: \(moveString.isEmpty ? "(startpos)" : moveString)")
                let suggestion = await engine.analyze(moves: moves, depth: 22)
                await send(.receiveEngineSuggestion(suggestion))
            }

        case let .receiveEngineSuggestion(suggestion):
            state.isAnalyzing = false
            state.lastEngineSuggestion = suggestion
            if let s = suggestion {
                print("💡 Stockfish best move: \(s.bestMove) score: \(s.score ?? 0) depth: \(s.depth)")
            } else {
                print("⚠️ No suggestion received from Stockfish.")
            }
            return .none

        case .restart:
            state = GameState()
            return .none

        case .undo, .internalError:
            return .none
            
        case let .toggleHumanVsAI(isOn):
            state.isHumanVsAI = isOn
            print("🤖 Human vs AI mode: \(isOn ? "ON" : "OFF")")
            return .none

        case let .toggleAIPlayingWhite(isWhite):
            state.isAIPlayingWhite = isWhite
            print("♟️ AI plays: \(isWhite ? "White" : "Black")")
            return .none
        }
    }

    private func generateLegalMoves(for from: Square, in state: State) -> [Square] {
        var moves: [Square] = []
        for rank in 0..<8 {
            for file in 0..<8 {
                let to = Square(file: file, rank: rank)
                if MoveValidator.isLegalMove(board: state.gameStatus.board, from: from, to: to, color: state.currentTurn) {
                    moves.append(to)
                }
            }
        }
        return moves
    }
}
