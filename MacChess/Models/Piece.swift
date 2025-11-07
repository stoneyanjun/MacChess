//
//  Piece.swift
//  MacChess
//
//  Created by stone on 2025/11/07.
//

import Foundation

/// Represents a single chess piece on the board.
struct Piece: Equatable, Codable, Sendable {
    let type: PieceType
    let color: PieceColor

    /// Human-readable symbol (♙, ♘, ♗, etc.)
    var symbol: String {
        switch (color, type) {
        case (.white, .pawn):   return "♙"
        case (.white, .rook):   return "♖"
        case (.white, .knight): return "♘"
        case (.white, .bishop): return "♗"
        case (.white, .queen):  return "♕"
        case (.white, .king):   return "♔"
        case (.black, .pawn):   return "♟"
        case (.black, .rook):   return "♜"
        case (.black, .knight): return "♞"
        case (.black, .bishop): return "♝"
        case (.black, .queen):  return "♛"
        case (.black, .king):   return "♚"
        }
    }

    /// Asset name for image lookup (e.g., "white_rook").
    var assetName: String {
        "\(color.rawValue)_\(type.rawValue)"
    }
}

/// The six fundamental chess piece types.
enum PieceType: String, Codable, CaseIterable, Equatable, Sendable {
    case king
    case queen
    case rook
    case bishop
    case knight
    case pawn
}

/// Indicates which side the piece belongs to.
enum PieceColor: String, Codable, CaseIterable, Equatable, Sendable {
    case white
    case black

    /// Opponent color convenience.
    var opponent: PieceColor {
        self == .white ? .black : .white
    }
}

extension PieceColor {
    /// Switches turn between white and black.
    mutating func toggle() {
        self = (self == .white) ? .black : .white
    }

    /// A user-friendly name for display.
    var displayName: String {
        self == .white ? "White" : "Black"
    }
}
