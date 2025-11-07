//
//  MoveValidator.swift
//  MacChess
//
//  Created by stone on 2025/11/08.
//

import Foundation

/// Utility responsible for checking if a given move is legal.
/// Stage Two: Implements basic movement rules per piece type.
struct MoveValidator {

    /// Checks whether a move is legal for the given board and player.
    static func isLegalMove(
        board: Board,
        from: Square,
        to: Square,
        color: PieceColor
    ) -> Bool {
        // --- 1️⃣ Ensure coordinates are valid ---
        guard (0..<8).contains(from.file),
              (0..<8).contains(from.rank),
              (0..<8).contains(to.file),
              (0..<8).contains(to.rank)
        else { return false }

        // --- 2️⃣ Ensure there is a piece at `from` ---
        guard let piece = board.piece(at: from) else { return false }

        // --- 3️⃣ Ensure piece belongs to the current player ---
        guard piece.color == color else { return false }

        // --- 4️⃣ Ensure destination is not occupied by own color ---
        if let target = board.piece(at: to), target.color == color {
            return false
        }

        // --- 5️⃣ Check piece-specific movement rule ---
        switch piece.type {
        case .pawn:   return validatePawn(board: board, from: from, to: to, color: color)
        case .rook:   return validateRook(board: board, from: from, to: to)
        case .bishop: return validateBishop(board: board, from: from, to: to)
        case .knight: return validateKnight(from: from, to: to)
        case .queen:  return validateQueen(board: board, from: from, to: to)
        case .king:   return validateKing(from: from, to: to)
        }
    }

    // MARK: - Piece rules

    private static func validatePawn(board: Board, from: Square, to: Square, color: PieceColor) -> Bool {
        let direction = (color == .white) ? 1 : -1
        let startRank = (color == .white) ? 1 : 6
        let rankDiff = to.rank - from.rank
        let fileDiff = abs(to.file - from.file)

        // Forward move (no capture)
        if fileDiff == 0 {
            if rankDiff == direction && board.piece(at: to) == nil {
                return true
            }
            // First double move
            if from.rank == startRank && rankDiff == 2 * direction {
                let midSquare = Square(file: from.file, rank: from.rank + direction)
                return board.piece(at: midSquare) == nil && board.piece(at: to) == nil
            }
            return false
        }

        // Capture (diagonal)
        if fileDiff == 1 && rankDiff == direction {
            if let target = board.piece(at: to), target.color != color {
                return true
            }
        }
        return false
    }

    private static func validateRook(board: Board, from: Square, to: Square) -> Bool {
        if from.file != to.file && from.rank != to.rank { return false }
        return isPathClear(board: board, from: from, to: to)
    }

    private static func validateBishop(board: Board, from: Square, to: Square) -> Bool {
        let fileDiff = abs(to.file - from.file)
        let rankDiff = abs(to.rank - from.rank)
        guard fileDiff == rankDiff else { return false }
        return isPathClear(board: board, from: from, to: to)
    }

    private static func validateQueen(board: Board, from: Square, to: Square) -> Bool {
        let fileDiff = abs(to.file - from.file)
        let rankDiff = abs(to.rank - from.rank)
        let isDiagonal = fileDiff == rankDiff
        let isStraight = (from.file == to.file) || (from.rank == to.rank)
        guard isDiagonal || isStraight else { return false }
        return isPathClear(board: board, from: from, to: to)
    }

    private static func validateKnight(from: Square, to: Square) -> Bool {
        let fileDiff = abs(to.file - from.file)
        let rankDiff = abs(to.rank - from.rank)
        return (fileDiff == 2 && rankDiff == 1) || (fileDiff == 1 && rankDiff == 2)
    }

    private static func validateKing(from: Square, to: Square) -> Bool {
        let fileDiff = abs(to.file - from.file)
        let rankDiff = abs(to.rank - from.rank)
        return max(fileDiff, rankDiff) == 1
    }

    // MARK: - Helper: check path blocking
    private static func isPathClear(board: Board, from: Square, to: Square) -> Bool {
        let fileStep = (to.file - from.file).signum()
        let rankStep = (to.rank - from.rank).signum()
        var f = from.file + fileStep
        var r = from.rank + rankStep

        while f != to.file || r != to.rank {
            if board.piece(at: Square(file: f, rank: r)) != nil {
                return false
            }
            f += fileStep
            r += rankStep
        }
        return true
    }
}
