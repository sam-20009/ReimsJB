import SwiftUI
import Foundation
import UIKit

// Laboratório local e limitado à sandbox do próprio aplicativo.
// Não tenta acessar o kernel, explorar drivers ou alterar proteções.
struct SafeResearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var worker: Task<LabReport, Never>?
    @State private var result: LabReport?
    @State private var running = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Laboratório local", systemImage: "waveform.path.ecg")
                            .font(.title2.bold())
                        Text("Testes controlados de APIs disponíveis ao app e consistência dos dados. Tudo acontece no aparelho, sem enviar dados para servidores.")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                        Text("Não é um scanner de falhas do kernel ou do chip A15. Não faz injeção, bypass nem instala Sileo.")
                            .foregroundStyle(.orange)
                            .font(.footnote)
                    }
                    .labCard()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Condições de segurança").font(.headline)
                        HStack {
                            Text("Temperatura")
                            Spacer()
                            Text(thermalDescription)
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("Energia")
                            Spacer()
                            Text(ProcessInfo.processInfo.isLowPowerModeEnabled ? "Modo de pouca energia" : "Normal")
                                .foregroundStyle(.secondary)
                        }
                        Text("Máximo de 2.000 casos, 128 bytes por entrada e apenas arquivos temporários da sandbox.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .labCard()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Testes disponíveis").font(.headline)
                        Label("JSON e Property List: entradas variadas e erros tratados", systemImage: "curlybraces")
                        Label("Codificação: Base64 e UTF-8", systemImage: "character.cursor.ibeam")
                        Label("URLs e normalização de texto", systemImage: "link")
                        Label("Leitura/escrita temporária apenas na sandbox", systemImage: "doc.text")
                        Divider()
                        if running {
                            ProgressView("Análise em execução…")
                        }
                        Button {
                            begin()
                        } label: {
                            Label("Executar análise local", systemImage: "play.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(running || thermalBlocked)

                        if running {
                            Button("Interromper análise", role: .cancel) {
                                worker?.cancel()
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .labCard()

                    if let result {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Relatório").font(.headline)
                            row("Entradas processadas", String(result.executed))
                            row("JSON rejeitado (esperado)", String(result.jsonRejected))
                            row("Property List rejeitada (esperado)", String(result.plistRejected))
                            row("Falhas de consistência", String(result.invariantsFailed))
                            row("Arquivo temporário", result.tempFileStatus)
                            row("Duração", String(format: "%.2f s", result.elapsedSeconds))
                            row("Estado", result.cancelled ? "Interrompido" : "Concluído")
                            if !result.messages.isEmpty {
                                ForEach(result.messages, id: \.self) { message in
                                    Text(message)
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                }
                            }
                            Text("Falha de consistência não comprova vulnerabilidade no iOS. A ausência de falhas também não comprova segurança.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            ShareLink(item: result.exportText) {
                                Label("Compartilhar relatório", systemImage: "square.and.arrow.up")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                        .labCard()
                    }
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Análise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
            .onDisappear { worker?.cancel() }
        }
    }

    private var thermalBlocked: Bool {
        let state = ProcessInfo.processInfo.thermalState
        return state == .serious || state == .critical
    }

    private var thermalDescription: String {
        switch ProcessInfo.processInfo.thermalState {
        case .nominal: return "Normal"
        case .fair: return "Moderada"
        case .serious: return "Elevada — análise bloqueada"
        case .critical: return "Crítica — análise bloqueada"
        @unknown default: return "Indeterminada"
        }
    }

    private func begin() {
        guard !running && !thermalBlocked else { return }
        result = nil
        running = true
        let job = Task.detached(priority: .utility) {
            LabEngine.run(maxCases: 2_000)
        }
        worker = job
        Task { @MainActor in
            let output = await job.value
            result = output
            running = false
            worker = nil
        }
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title).foregroundStyle(.secondary)
            Spacer(minLength: 12)
            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}

private extension View {
    func labCard() -> some View {
        self
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct LabReport {
    let executed: Int
    let jsonRejected: Int
    let plistRejected: Int
    let invariantsFailed: Int
    let tempFileStatus: String
    let elapsedSeconds: Double
    let cancelled: Bool
    let messages: [String]

    var exportText: String {
        ([
            "ReimsJB — laboratório local v0.3",
            "Casos: \(executed)",
            "JSON rejeitado (normal): \(jsonRejected)",
            "Property Lists rejeitadas (normal): \(plistRejected)",
            "Invariantes inválidas: \(invariantsFailed)",
            "Sandbox: \(tempFileStatus)",
            String(format: "Duração: %.2f s", elapsedSeconds),
            "Estado: \(cancelled ? "interrompido" : "concluído")",
            "NÃO é uma prova de jailbreak nem uma auditoria do kernel.",
            ""
        ] + messages).joined(separator: "\n")
    }
}

enum LabEngine {
    // PRNG determinístico: permite repetir o mesmo corpus em outro build.
    private struct Generator {
        var state: UInt64 = 0x7265696d736a6233
        mutating func next() -> UInt8 {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return UInt8(truncatingIfNeeded: state >> 32)
        }
        mutating func data(count: Int) -> Data {
            Data((0..<count).map { _ in next() })
        }
    }

    static func run(maxCases: Int) -> LabReport {
        let start = Date()
        var rng = Generator()
        var executed = 0
        var jsonRejected = 0
        var plistRejected = 0
        var invariantsFailed = 0
        var messages: [String] = []
        let limit = min(max(0, maxCases), 2_000)

        for index in 0..<limit {
            if Task<Never, Never>.isCancelled { break }
            let thermal = ProcessInfo.processInfo.thermalState
            if thermal == .serious || thermal == .critical {
                messages.append("Análise interrompida: aquecimento do dispositivo.")
                break
            }

            let data = rng.data(count: 1 + (index % 128))
            do {
                _ = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
            } catch {
                jsonRejected += 1 // Entrada aleatória inválida é comportamento esperado.
            }
            do {
                _ = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            } catch {
                plistRejected += 1
            }
            let encoded = data.base64EncodedString()
            if Data(base64Encoded: encoded) != data {
                invariantsFailed += 1
                if messages.count < 8 { messages.append("Base64 divergente no caso \(index).") }
            }
            if let string = String(data: data, encoding: .utf8) {
                if Data(string.utf8) != data {
                    invariantsFailed += 1
                    if messages.count < 8 { messages.append("UTF-8 divergente no caso \(index).") }
                }
            }
            _ = URLComponents(string: String(decoding: data, as: UTF8.self))
            executed += 1
        }

        let path = FileManager.default.temporaryDirectory
            .appendingPathComponent("reimsjb-lab-" + UUID().uuidString)
        var fileStatus = "Não executado"
        if !Task<Never, Never>.isCancelled {
            let sample = Data("ReimsJB sandbox test".utf8)
            do {
                try sample.write(to: path, options: .atomic)
                let loaded = try Data(contentsOf: path)
                if loaded == sample {
                    fileStatus = "Leitura e escrita verificadas"
                } else {
                    fileStatus = "Inconsistência"
                    invariantsFailed += 1
                }
                try? FileManager.default.removeItem(at: path)
            } catch {
                fileStatus = "Falhou: \(error.localizedDescription)"
            }
        }

        return LabReport(
            executed: executed,
            jsonRejected: jsonRejected,
            plistRejected: plistRejected,
            invariantsFailed: invariantsFailed,
            tempFileStatus: fileStatus,
            elapsedSeconds: Date().timeIntervalSince(start),
            cancelled: Task<Never, Never>.isCancelled,
            messages: messages
        )
    }
}
