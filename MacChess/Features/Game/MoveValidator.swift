//
//  MoveValidator.swift
//  MacChess
//
//  Created by stone on 2025/11/7.
//

import Foundation

/// A lightweight but correct chess move validator for all standard pieces.
/// It enforces turn-based color logic and disallows backward pawn moves.
struct MoveValidator {

    static func isValidMove(
        board: [[Piece?]],
        from: Square,
        to: Square,
        currentTurn: PieceColor
    ) -> Bool {
        guard let piece = board[from.row][from.col] else { return false }
        if from == to { return false }

        // 🧠 must move your own color
        if piece.color != currentTurn {
            return false
        }

        // 🚫 cannot capture your own piece
        if let targetPiece = board[to.row][to.col],
           targetPiece.color == piece.color {
            return false
        }

        // 🎯 dispatch by piece type
        switch piece.type {
        case .pawn:
            return validatePawn(board: board, from: from, to: to, piece: piece)
        case .rook:
            return validateRook(board: board, from: from, to: to)
        case .knight:
            return validateKnight(from: from, to: to)
        case .bishop:
            return validateBishop(board: board, from: from, to: to)
        case .queen:
            return validateQueen(board: board, from: from, to: to)
        case .king:
            return validateKing(from: from, to: to)
        }
    }

    // MARK: - Pawn
    private static func validatePawn(board: [[Piece?]], from: Square, to: Square, piece: Piece) -> Bool {
        let dir = piece.color == .white ? -1 : 1
        let startRow = piece.color == .white ? 6 : 1
        let dy = to.row - from.row
        let dx = to.col - from.col

        // 🚫 Prevent backward move
        if (piece.color == .white && dy >= 0) || (piece.color == .black && dy <= 0) {
            return false
        }

        // Forward move (no capture)
        if dx == 0 {
            // Move 1 step forward
            if dy == dir, board[to.row][to.col] == nil {
                return true
            }

            // Move 2 steps from starting position
            if from.row == startRow,
               dy == 2 * dir,
               board[from.row + dir][to.col] == nil,
               board[to.row][to.col] == nil {
                return true
            }
        }

        // Capture diagonally
        if abs(dx) == 1, dy == dir {
            if let target = board[to.row][to.col], target.color != piece.color {
                return true
            }
        }

        return false
    }

    // MARK: - Rook
    private static func validateRook(board: [[Piece?]], from: Square, to: Square) -> Bool {
        let dy = to.row - from.row
        let dx = to.col - from.col
        if dy != 0 && dx != 0 { return false }
        return pathIsClear(board: board, from: from, to: to)
    }

    // MARK: - Knight
    private static func validateKnight(from: Square, to: Square) -> Bool {
        let dy = abs(to.row - from.row)
        let dx = abs(to.col - from.col)
        return (dx == 1 && dy == 2) || (dx == 2 && dy == 1)
    }

    // MARK: - Bishop
    private static func validateBishop(board: [[Piece?]], from: Square, to: Square) -> Bool {
        let dy = abs(to.row - from.row)
        let dx = abs(to.col - from.col)
        if dy != dx { return false }
        return pathIsClear(board: board, from: from, to: to)
    }

    // MARK: - Queen
    private static func validateQueen(board: [[Piece?]], from: Square, to: Square) -> Bool {
        let dy = abs(to.row - from.row)
        let dx = abs(to.col - from.col)
        if dy == dx || dy == 0 || dx == 0 {
            return pathIsClear(board: board, from: from, to: to)
        }
        return false
    }

    // MARK: - King
    private static func validateKing(from: Square, to: Square) -> Bool {
        let dy = abs(to.row - from.row)
        let dx = abs(to.col - from.col)
        return max(dx, dy) == 1
    }

    // MARK: - Helpers
    private static func pathIsClear(board: [[Piece?]], from: Square, to: Square) -> Bool {
        let dx = to.col - from.col
        let dy = to.row - from.row
        let stepX = dx == 0 ? 0 : dx / abs(dx)
        let stepY = dy == 0 ? 0 : dy / abs(dy)
        var x = from.col + stepX
        var y = from.row + stepY

        while x != to.col || y != to.row {
            if board[y][x] != nil { return false }
            x += stepX
            y += stepY
        }
        return true
    }
}
