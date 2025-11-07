//
//  StockfishProcess.swift
//  MacChess
//
//  Created by stone on 2025/11/7.
//

import Foundation

/// Handles launching and communicating with the Stockfish binary.
actor StockfishProcess {
    private var process: Process?
    private var inputPipe = Pipe()
    private var outputPipe = Pipe()

    private var outputStream: AsyncStream<String>?
    private var continuation: AsyncStream<String>.Continuation?

    // MARK: - Launch / Terminate
    func start() async throws {
        guard process == nil else {
            print("⚙️ [StockfishProcess] Already running.")
            return
        }

        let stockfishPath = Bundle.main.path(forResource: "stockfish", ofType: "")
            ?? "/usr/local/bin/stockfish"   // fallback for dev

        print("🚀 [StockfishProcess] Launching Stockfish from: \(stockfishPath)")

        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: stockfishPath)
        proc.standardInput = inputPipe
        proc.standardOutput = outputPipe

        // Observe process termination
        proc.terminationHandler = { process in
            print("🧯 [StockfishProcess] Stockfish exited with code: \(process.terminationStatus)")
        }

        // Create async output stream
        let handle = outputPipe.fileHandleForReading
        let stream = AsyncStream(String.self) { continuation in
            self.continuation = continuation
            Task.detached {
                for try await line in handle.bytes.lines {
                    if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { continue }
                    print("📥 [Stockfish] \(line)")
                    continuation.yield(line)
                }
                continuation.finish()
            }
        }
        outputStream = stream

        do {
            try proc.run()
            print("✅ [StockfishProcess] Stockfish process started (pid: \(proc.processIdentifier)).")
        } catch {
            print("❌ [StockfishProcess] Failed to start Stockfish: \(error)")
            throw error
        }

        process = proc

        // Initialize engine
        try await send("uci")
        try await send("isready")
    }

    func stop() {
        guard let proc = process else {
            print("⚙️ [StockfishProcess] Stop called but process not running.")
            return
        }

        print("🛑 [StockfishProcess] Terminating Stockfish (pid: \(proc.processIdentifier))...")
        proc.terminate()
        process = nil
        continuation?.finish()
        continuation = nil
        print("✅ [StockfishProcess] Terminated.")
    }

    // MARK: - Send / Receive
    func send(_ command: String) async throws {
        let handle = inputPipe.fileHandleForWriting
        let trimmed = command.trimmingCharacters(in: .whitespacesAndNewlines)
        print("📤 [Stockfish →] \(trimmed)")
        if let data = (command + "\n").data(using: .utf8) {
            try handle.write(contentsOf: data)
        }
    }

    func readLines() -> AsyncStream<String> {
        if let stream = outputStream {
            print("🔄 [StockfishProcess] Returning active output stream.")
            return stream
        } else {
            print("⚠️ [StockfishProcess] No output stream available.")
            return AsyncStream { $0.finish() }
        }
    }
}
