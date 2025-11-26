//
//  StockfishEngine.swift
//  MacChess
//
//  Stage 5.3 – Fixes actor isolation (await readLines) and async stop()
//

import Foundation
import Dependencies

extension DependencyValues {
    var stockfishEngine: StockfishEngine {
        get { self[StockfishEngineKey.self] }
        set { self[StockfishEngineKey.self] = newValue }
    }
}

private enum StockfishEngineKey: DependencyKey {
    static let liveValue = StockfishEngine()
    static let previewValue = StockfishEngine()
    static let testValue = StockfishEngine()
}

/// High-level Stockfish controller used by GameFeature via TCA Dependency.
actor StockfishEngine {
    private let process = StockfishProcess()
    private var isStarted = false

    // MARK: - Lifecycle
    func start() async {
        guard !isStarted else {
            print("⚙️ [StockfishEngine] Already started.")
            return
        }
        do {
            try await process.start()
            isStarted = true
        } catch {
            print("❌ [StockfishEngine] Failed to start Stockfish: \(error)")
        }
    }

    func stop() async {
        await process.stop()
        isStarted = false
    }

    // MARK: - Analysis
    func analyze(moves: [MoveRecord], depth: Int = 23) async -> EngineSuggestion? {
        guard isStarted else {
            print("⚠️ [StockfishEngine] Engine not started, starting now…")
            await start()
            return nil
        }

        let moveString = moves.map(\.notation).joined(separator: " ")
        let positionCmd = "position startpos moves \(moveString)"

        do {
            try await process.send(positionCmd)
            try await process.send("go depth \(depth)")
        } catch {
            print("❌ [StockfishEngine] Failed to send command: \(error)")
            return nil
        }

        var currentDepth = 0
        var currentScore: Int?
        var currentPV: [String] = []

        // ✅ Await the stream once, then iterate
        let stream = await process.readLines()
        for await line in stream {
            if line.hasPrefix("info ") {
                let parts = line.split(separator: " ")

                if let depthIdx = parts.firstIndex(of: "depth"),
                   depthIdx + 1 < parts.count,
                   let depthVal = Int(parts[depthIdx + 1]) {
                    currentDepth = depthVal
                }

                if let scoreIdx = parts.firstIndex(of: "cp"),
                   scoreIdx + 1 < parts.count,
                   let scoreVal = Int(parts[scoreIdx + 1]) {
                    currentScore = scoreVal
                }

                if let pvIdx = parts.firstIndex(of: "pv"),
                   pvIdx + 1 < parts.count {
                    currentPV = parts[(pvIdx + 1)...].map(String.init)
                }
            }
            else if line.hasPrefix("bestmove") {
                let parts = line.split(separator: " ")
                guard parts.count >= 2 else { continue }
                let move = String(parts[1])
                let suggestion = EngineSuggestion(
                    bestMove: move,
                    pv: currentPV,
                    score: currentScore,
                    depth: currentDepth
                )
                print("💡 [StockfishEngine] Best move: \(move) | score: \(currentScore ?? 0) | depth: \(currentDepth)")
                return suggestion
            }
        }

        print("⚠️ [StockfishEngine] No suggestion received (stream ended).")
        return nil
    }
}
