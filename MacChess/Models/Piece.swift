//
//  Piece.swift
//  MacChess
//
//  Created by stone on 2025/11/7.
//

import Foundation

enum PieceColor: String, Codable, Equatable {
    case white
    case black
}

enum PieceType: String, Codable, Equatable {
    case pawn, rook, knight, bishop, queen, king
}

struct Piece: Codable, Equatable {
    var type: PieceType
    var color: PieceColor

    init(_ type: PieceType, _ color: PieceColor) {
        self.type = type
        self.color = color
    }

    var symbol: String {
        switch (color, type) {
        case (.white, .pawn): return "♙"
        case (.white, .rook): return "♖"
        case (.white, .knight): return "♘"
        case (.white, .bishop): return "♗"
        case (.white, .queen): return "♕"
        case (.white, .king): return "♔"
        case (.black, .pawn): return "♟"
        case (.black, .rook): return "♜"
        case (.black, .knight): return "♞"
        case (.black, .bishop): return "♝"
        case (.black, .queen): return "♛"
        case (.black, .king): return "♚"
        }
    }
}
