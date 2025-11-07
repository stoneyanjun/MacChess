//
//  GameFeature.swift
//  MacChess
//
//  Created by stone on 2025/11/7.
//

import Foundation
import ComposableArchitecture

struct GameFeature: Reducer {
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
            
        case .selectSquare(let square):
            // If nothing selected yet → select
            if state.selectedSquare == nil {
                state.selectedSquare = square
            }
            // If already selected → move
            else if let from = state.selectedSquare, from != square {
                state.selectedSquare = nil
                return .send(.move(from: from, to: square))
            }
            // Deselect if same square tapped again
            else {
                state.selectedSquare = nil
            }
            return .none
            
        case let .move(from, to):
            guard MoveValidator.isValidMove(
                board: state.board,
                from: from,
                to: to,
                currentTurn: state.currentTurn
            ) else {
                state.selectedSquare = nil
                return .none
            }

            guard let piece = state.board[from.row][from.col] else { return .none }

            // Perform move
            state.board[to.row][to.col] = piece
            state.board[from.row][from.col] = nil

            // Record move
            let notation = GameFeature.notation(for: piece, from: from, to: to)
            let record = MoveRecord(
                moveNumber: state.moveNumber,
                color: state.currentTurn,
                from: from,
                to: to,
                notation: notation
            )
            state.moveHistory.append(record)

            // Update move number and turn
            if state.currentTurn == .black { state.moveNumber += 1 }
            state.currentTurn = (state.currentTurn == .white) ? .black : .white
            state.selectedSquare = nil

            // 🧠 Send move to Stockfish
//            let moves = state.moveHistory.map { $0.uciString.lowercased() }
//            Task {
//                await GameFeature.State.sharedEngine.analyze(positionFEN: "startpos", moves: moves)
//            }

            return .none
            
        case .toggleBoardFlip(let flipped):
            state.isBoardFlipped = flipped
            return .none

        case .reset:
            state.board = GameFeature.initialBoard()
            state.selectedSquare = nil
            state.currentTurn = .white
            state.moveHistory = []        // 🆕 clear move history
            state.moveNumber = 1          // 🆕 reset move counter
            state.isBoardFlipped = false  
            return .none
            
        }
    }
    
    // Simple initial setup
    static func initialBoard() -> [[Piece?]] {
        var board: [[Piece?]] = Array(
            repeating: Array(repeating: nil, count: 8),
            count: 8
        )
        
        // Place pawns
        for i in 0..<8 {
            board[1][i] = Piece(.pawn, .black)
            board[6][i] = Piece(.pawn, .white)
        }
        
        // Rooks
        board[0][0] = Piece(.rook, .black)
        board[0][7] = Piece(.rook, .black)
        board[7][0] = Piece(.rook, .white)
        board[7][7] = Piece(.rook, .white)
        
        // Knights
        board[0][1] = Piece(.knight, .black)
        board[0][6] = Piece(.knight, .black)
        board[7][1] = Piece(.knight, .white)
        board[7][6] = Piece(.knight, .white)
        
        // Bishops
        board[0][2] = Piece(.bishop, .black)
        board[0][5] = Piece(.bishop, .black)
        board[7][2] = Piece(.bishop, .white)
        board[7][5] = Piece(.bishop, .white)
        
        // Queens
        board[0][3] = Piece(.queen, .black)
        board[7][3] = Piece(.queen, .white)
        
        // Kings
        board[0][4] = Piece(.king, .black)
        board[7][4] = Piece(.king, .white)
        
        return board
    }
    
    static func notation(for piece: Piece, from: Square, to: Square) -> String {
        let files = ["a","b","c","d","e","f","g","h"]
        let pieceSymbol = {
            switch piece.type {
            case .pawn: return ""
            case .knight: return "N"
            case .bishop: return "B"
            case .rook: return "R"
            case .queen: return "Q"
            case .king: return "K"
            }
        }()
        let toSquare = files[to.col] + String(to.row + 1)
        return pieceSymbol + toSquare
    }
    
}
