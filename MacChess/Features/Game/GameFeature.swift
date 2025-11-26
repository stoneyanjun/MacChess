//
//  GameFeature.swift
//  MacChess
//
//  Created by stone on 2025/11/08.
//

import Foundation
import ComposableArchitecture

/// Stage 5.5: integrates Stockfish engine + Human-vs-AI auto move logic.
struct GameFeature: Reducer, Sendable {
    
    typealias State = GameState
    typealias Action = GameAction
    
    @Dependency(\.stockfishEngine) var engine
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
            
            // ------------------------------------------------------------
            // 1️⃣ Initialize
            // ------------------------------------------------------------
        case .onAppear:
            state = GameState()
            return .run { _ in
                await engine.start()
            }
            
            // ------------------------------------------------------------
            // 2️⃣ User selects squares
            // ------------------------------------------------------------
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
            
            // ------------------------------------------------------------
            // 3️⃣ Attempt a move
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
            // 4️⃣ Apply valid move & record history
            // ------------------------------------------------------------
        case let .moveAccepted(from, to):
            let board = state.gameStatus.board
            // Apply move
            state.gameStatus.move(from: from, to: to)
            if board.piece(at: to) != nil {
                ChessSoundPlayer.playCaptureSound()
            } else {
                ChessSoundPlayer.playMoveSound()
            }
            
            // ✅ 如果是王车易位，则自动移动车
            if let piece = state.gameStatus.board.piece(at: to),
               piece.type == .king,
               abs(to.file - from.file) == 2 {
                let rank = to.rank
                if to.file == 6 {
                    // 王翼易位 O-O
                    let rookFrom = Square(file: 7, rank: rank)
                    let rookTo = Square(file: 5, rank: rank)
                    state.gameStatus.move(from: rookFrom, to: rookTo)
                    print("♔ Castling (King-side) executed")
                } else if to.file == 2 {
                    // 后翼易位 O-O-O
                    let rookFrom = Square(file: 0, rank: rank)
                    let rookTo = Square(file: 3, rank: rank)
                    state.gameStatus.move(from: rookFrom, to: rookTo)
                    print("♔ Castling (Queen-side) executed")
                }
            }
            
            // Record move
            let record = MoveRecord(
                index: state.moveIndex,
                color: state.currentTurn,
                from: from,
                to: to
            )
            state.moveHistory.append(record)
            state.lastMoveFrom = from
            state.lastMoveTo = to
            
            // Update turn
            if state.currentTurn == .black { state.moveIndex += 1 }
            state.currentTurn.toggle()
            state.selectedSquare = nil
            state.highlightSquares = []
            state.invalidMoveFlash = false
            
            // 如果是人机对战，自动让 AI 思考
            if state.isHumanVsAI {
                let aiColor = state.isAIPlayingWhite ? PieceColor.white : PieceColor.black
                if state.currentTurn == aiColor {
                    state.isAnalyzing = true
                    return .send(.requestEngineSuggestion)
                }
            }
            
            return .none
            
            // ------------------------------------------------------------
            // 5️⃣ Invalid move
            // ------------------------------------------------------------
        case .invalidMove:
            state.invalidMoveFlash = true
            return .none
            
            // ------------------------------------------------------------
            // 6️⃣ Ask Stockfish for suggestion
            // ------------------------------------------------------------
        case .requestEngineSuggestion:
            state.isAnalyzing = true
            return .run { [moves = state.moveHistory] send in
                let moveString = moves.map(\.notation).joined(separator: " ")
                print("📤 Sending moves to Stockfish: \(moveString.isEmpty ? "(startpos)" : moveString)")
                let suggestion = await engine.analyze(moves: moves, depth: 23)
                await send(.receiveEngineSuggestion(suggestion))
            }
            
            // ------------------------------------------------------------
            // 7️⃣ Receive Stockfish suggestion
            // ------------------------------------------------------------
        case let .receiveEngineSuggestion(suggestion):
            state.isAnalyzing = false
            state.lastEngineSuggestion = suggestion
            
            guard let suggestion = suggestion else {
                print("⚠️ No suggestion received from Stockfish.")
                return .none
            }
            
            print("💡 Stockfish best move: \(suggestion.bestMove) score: \(suggestion.score ?? 0) depth: \(suggestion.depth)")
            
            // ✅ 如果当前是人机对战并轮到AI，直接落子
            if state.isHumanVsAI {
                let aiColor = state.isAIPlayingWhite ? PieceColor.white : PieceColor.black
                if state.currentTurn == aiColor {
                    let move = suggestion.bestMove
                    // 解析 "e2e4" -> from("e2"), to("e4")
                    if move.count == 4 {
                        let fromStr = String(move.prefix(2))
                        let toStr = String(move.suffix(2))
                        if let from = Square(notation: fromStr),
                           let to = Square(notation: toStr) {
                            print("🤖 AI auto move: \(move)")
                            return .send(.moveAccepted(from: from, to: to))
                        }
                    }
                }
            }
            
            return .none
            
            // ------------------------------------------------------------
            // 8️⃣ Toggles
            // ------------------------------------------------------------
        case let .toggleHumanVsAI(isOn):
            state.isHumanVsAI = isOn
            print("🤖 Human vs AI: \(isOn)")
            return .none
            
        case let .toggleAIPlayingWhite(isWhite):
            state.isAIPlayingWhite = isWhite
            print("♟️ AI plays \(isWhite ? "White" : "Black")")
            return .none
            
            // ------------------------------------------------------------
            // 9️⃣ Restart
            // ------------------------------------------------------------
        case .restart:
            state = GameState()
            return .run { [engine] send in
                // 完全停止 Stockfish
                await engine.stop()
                // 重新启动 Stockfish
                await engine.start()
            }
            // ------------------------------------------------------------
            // 🔄 Undo last move
            // ------------------------------------------------------------
        case .undo:
            guard !state.moveHistory.isEmpty else {
                print("⚠️ No move to undo.")
                return .none
            }
            
            // 1️⃣ Remove the last move
            _ = state.moveHistory.popLast()
            
            // 2️⃣ Rebuild a fresh board from the start position
            var newBoard = Board.standardSetup()
            var newGameStatus = GameStatus()
            newGameStatus.board = newBoard
            
            // 3️⃣ Reapply all remaining moves
            for record in state.moveHistory {
                guard let from = Square(notation: record.from),
                      let to = Square(notation: record.to) else { continue }
                newGameStatus.move(from: from, to: to)
            }
            
            // 4️⃣ Update game state
            state.gameStatus = newGameStatus
            state.selectedSquare = nil
            state.highlightSquares = []
            state.invalidMoveFlash = false
            
            // 5️⃣ Determine whose turn it is now
            let totalMoves = state.moveHistory.count
            if totalMoves % 2 == 0 {
                state.currentTurn = .white
            } else {
                state.currentTurn = .black
            }
            
            // 6️⃣ Update move index (each full move = white+black)
            state.moveIndex = totalMoves / 2
            
            // 7️⃣ Stop any ongoing analysis
            state.isAnalyzing = false
            
            print("↩️ Undo successful. Moves left: \(state.moveHistory.count)")
            return .none
        case .internalError:
            return .none
        }
    }
    
    // MARK: - Helper
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
