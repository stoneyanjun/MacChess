//
//  StockfishEngine.swift
//  MacChess
//
//  Stage 5.1: Parse Stockfish output and return EngineSuggestion.
//

import Foundation
import Dependencies

extension DependencyValues {
    /// Direct dependency access to the StockfishEngine actor instance.
    var stockfishEngine: StockfishEngine {
        get { self[StockfishEngineKey.self] }
        set { self[StockfishEngineKey.self] = newValue }
    }
}

/// TCA dependency key that stores a single StockfishEngine actor instance.
private enum StockfishEngineKey: DependencyKey {
    static let liveValue: StockfishEngine = StockfishEngine()
    static let previewValue: StockfishEngine = StockfishEngine()
    static let testValue: StockfishEngine = StockfishEngine()
}

actor StockfishEngine {
    private let process = StockfishProcess()

    // MARK: - Public API
    func start() async {
        do { try await process.start() }
        catch { print("⚠️ Failed to start Stockfish:", error) }
    }

    func stop() {
        Task {
            await process.stop()
        }
    }

    /// Analyze the current game and return best move suggestion.
    func analyze(moves: [MoveRecord], depth: Int = 22) async -> EngineSuggestion? {
        let moveString = moves.map(\.notation).joined(separator: " ")
        let positionCmd = "position startpos moves \(moveString)"

        do {
            try await process.send(positionCmd)
            try await process.send("go depth \(depth)")
        } catch {
            print("⚠️ Failed to send command:", error)
            return nil
        }

        var currentDepth = 0
        var currentScore: Int?
        var currentPV: [String] = []

        // ✅ Capture the stream first (requires await)
        let stream = await process.readLines()

        // ✅ Then iterate
        for await line in stream {
            if line.hasPrefix("info ") {
                let parts = line.split(separator: " ")
                if let depthIdx = parts.firstIndex(of: "depth"),
                   depthIdx + 1 < parts.count,
                   let depth = Int(parts[depthIdx + 1]) {
                    currentDepth = depth
                }
                if let scoreIdx = parts.firstIndex(of: "cp"),
                   scoreIdx + 1 < parts.count,
                   let score = Int(parts[scoreIdx + 1]) {
                    currentScore = score
                }
                if let pvIdx = parts.firstIndex(of: "pv"), pvIdx + 1 < parts.count {
                    currentPV = parts[(pvIdx + 1)...].map(String.init)
                }
            } else if line.hasPrefix("bestmove") {
                let parts = line.split(separator: " ")
                if parts.count >= 2 {
                    let move = String(parts[1])
                    let suggestion = EngineSuggestion(
                        bestMove: move,
                        pv: currentPV,
                        score: currentScore,
                        depth: currentDepth
                    )
                    print("💡 Stockfish suggestion: \(suggestion)")
                    return suggestion
                }
            }
        }

        return nil
    }
}
