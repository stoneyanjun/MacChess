//
//  GameFeature.swift
//  MacChess
//
//  Created by stone on 2025/11/06.
//

import Foundation
import ComposableArchitecture

// MARK: - Models

enum PieceColor: String, Codable, Equatable {
    case white, black
}

enum PieceType: String, Codable, Equatable {
    case pawn, rook, knight, bishop, queen, king
}

struct Piece: Equatable, Identifiable {
    let id = UUID()
    let color: PieceColor
    let type: PieceType
}

// MARK: - Game Feature

struct GameFeature: Reducer {
    struct State: Equatable {
        var board: [[Piece?]] = GameFeature.initialBoard()
    }

    enum Action: Equatable {
        // Stage 1: no user interactions yet
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        .none
    }
}

// MARK: - Helpers

extension GameFeature {
    static func initialBoard() -> [[Piece?]] {
        var board: [[Piece?]] = Array(
            repeating: Array(repeating: nil, count: 8),
            count: 8
        )

        func setPiece(_ type: PieceType, _ color: PieceColor, _ row: Int, _ col: Int) {
            board[row][col] = Piece(color: color, type: type)
        }

        // Black back rank
        let blackBack: [PieceType] = [.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook]
        for (col, type) in blackBack.enumerated() { setPiece(type, .black, 0, col) }
        for col in 0..<8 { setPiece(.pawn, .black, 1, col) }

        // White back rank
        let whiteBack: [PieceType] = [.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook]
        for (col, type) in whiteBack.enumerated() { setPiece(type, .white, 7, col) }
        for col in 0..<8 { setPiece(.pawn, .white, 6, col) }

        return board
    }
}
