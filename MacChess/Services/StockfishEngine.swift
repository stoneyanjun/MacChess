//
//  StockfishEngine.swift
//  MacChess
//
//  Created by stone on 2025/11/7.
//

import Combine
import Foundation

@MainActor
final class StockfishEngine: ObservableObject {
    private var process: Process?
    private var inputPipe = Pipe()
    private var outputPipe = Pipe()
    private var readerQueue = DispatchQueue(label: "stockfish-output-reader")
    @Published var suggestion: String = "Waiting for Stockfish..."
    private var isRunning = false

    init() {
        startEngine()
    }

    private func startEngine() {
        guard let engineURL = Bundle.main.url(forResource: "stockfish", withExtension: nil) else {
            print("⚠️ [Stockfish] Engine binary not found in bundle.")
            suggestion = "⚠️ Engine not found"
            return
        }

        process = Process()
        process?.executableURL = engineURL
        process?.standardInput = inputPipe
        process?.standardOutput = outputPipe

        do {
            try process?.run()
            isRunning = true
            print("✅ [Stockfish] Started PID:", process?.processIdentifier ?? -1)
            listenToOutput()
            send("uci")
            send("isready")
        } catch {
            print("❌ [Stockfish] Failed to start:", error.localizedDescription)
            suggestion = "Engine failed to start"
        }
    }

    private func listenToOutput() {
        let handle = outputPipe.fileHandleForReading
        readerQueue.async { [weak self] in
            guard let self else { return }
            print("👂 [Stockfish] Listening for output...")

            while self.isRunning {
                autoreleasepool {
                    let data = handle.availableData
                    if data.isEmpty {
                        usleep(50_000) // wait 0.05s before retry
                        return
                    }

                    if let text = String(data: data, encoding: .utf8), !text.isEmpty {
                        for line in text.split(separator: "\n") {
                            print("🧾 [Stockfish OUT] \(line)")
                        }
                        Task { @MainActor in
                            self.parse(text)
                        }
                    }
                }
            }
        }

        process?.terminationHandler = { [weak self] process in
            Task { @MainActor in
                print("⚠️ [Stockfish] Engine terminated (exit code: \(process.terminationStatus))")
                self?.isRunning = false
                self?.suggestion = "Engine stopped (exit code \(process.terminationStatus))"
            }
        }
    }

    private func parse(_ text: String) {
        if text.contains("bestmove") {
            if let best = text.components(separatedBy: "bestmove ").last?.split(separator: " ").first {
                let result = "Stockfish suggests: \(best)"
                print("💡 [Stockfish Parsed] \(result)")
                suggestion = result
            }
        }
    }

    func send(_ command: String) {
        guard isRunning else {
            print("⚠️ [Stockfish] Attempted to send command but engine is not running.")
            return
        }
        guard let data = "\(command)\n".data(using: .utf8) else { return }
        do {
            try inputPipe.fileHandleForWriting.write(contentsOf: data)
            print("➡️ [Stockfish IN] \(command)")
        } catch {
            print("❌ [Stockfish] Write failed: \(error.localizedDescription)")
            suggestion = "Write failed: \(error.localizedDescription)"
            restartEngineIfNeeded()
        }
    }

    func analyze(positionFEN: String, moves: [String]) async {
        guard isRunning else {
            suggestion = "Engine not running."
            return
        }
        let moveList = moves.joined(separator: " ")
        print("🔍 [Stockfish] Analyzing position...")
        print("     FEN: \(positionFEN)")
        print("     Moves: \(moveList)")
        send("position fen \(positionFEN) moves \(moveList)")
        send("go movetime 1000")
    }

    private func restartEngineIfNeeded() {
        if !isRunning {
            print("🔄 [Stockfish] Restarting engine after crash or pipe failure...")
            stop()
            startEngine()
        }
    }

    func stop() {
        print("🛑 [Stockfish] Stopping engine.")
        if isRunning {
            send("quit")
            process?.terminate()
        }
        isRunning = false
    }
}
