//
//  StockfishProcess.swift
//  MacChess
//
//  Stage 5.2 – Robust async process wrapper with logging and ready-check
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

        let stockfishPath =
            Bundle.main.path(forResource: "stockfish", ofType: "") ??
            "/usr/local/bin/stockfish"   // fallback for dev

        print("🚀 [StockfishProcess] Launching Stockfish from: \(stockfishPath)")

        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: stockfishPath)
        proc.standardInput = inputPipe
        proc.standardOutput = outputPipe
        proc.standardError = outputPipe

        proc.terminationHandler = { p in
            print("🧯 [StockfishProcess] Exited with code \(p.terminationStatus)")
        }

        // Create async output stream
        setupOutputStream()

        try proc.run()
        process = proc
        print("✅ [StockfishProcess] Started (pid \(proc.processIdentifier))")

        // Initialize & wait for ready
        try await send("uci")
        try await waitFor(keyword: "uciok")
        try await send("isready")
        try await waitFor(keyword: "readyok")
        print("🧠 [StockfishProcess] Ready to receive commands.")
    }

    func stop() {
        guard let proc = process else {
            print("⚙️ [StockfishProcess] Stop called but not running.")
            return
        }

        print("🛑 [StockfishProcess] Terminating (pid \(proc.processIdentifier))...")
        proc.terminate()
        process = nil
        continuation?.finish()
        continuation = nil
        print("✅ [StockfishProcess] Terminated.")
    }

    // MARK: - Stream setup
    private func setupOutputStream() {
        let handle = outputPipe.fileHandleForReading
        let stream = AsyncStream(String.self) { continuation in
            self.continuation = continuation
            Task.detached {
                for try await line in handle.bytes.lines {
                    let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmed.isEmpty { continue }
                    print("📥 [Stockfish] \(trimmed)")
                    continuation.yield(trimmed)
                }
                continuation.finish()
            }
        }
        outputStream = stream
    }

    func readLines() -> AsyncStream<String> {
        if let stream = outputStream {
            return stream
        } else {
            print("⚠️ [StockfishProcess] Output stream missing – recreating.")
            setupOutputStream()
            return outputStream!
        }
    }

    // MARK: - Command helpers
    func send(_ command: String) async throws {
        let handle = inputPipe.fileHandleForWriting
        let trimmed = command.trimmingCharacters(in: .whitespacesAndNewlines)
        print("📤 [Stockfish →] \(trimmed)")
        if let data = (command + "\n").data(using: .utf8) {
            try handle.write(contentsOf: data)
        }
    }

    private func waitFor(keyword: String, timeout: TimeInterval = 5.0) async throws {
        let stream = readLines()
        let startTime = Date()
        for await line in stream {
            if line.contains(keyword) {
                return
            }
            if Date().timeIntervalSince(startTime) > timeout {
                throw NSError(domain: "Stockfish", code: 1,
                              userInfo: [NSLocalizedDescriptionKey:
                                         "Timeout waiting for \(keyword)"])
            }
        }
    }
}
