import Foundation
import SwiftUI

struct ResearchLog: Identifiable {
    let id = UUID()
    let time: Date
    let level: String
    let message: String
}

@MainActor
final class ResearchStore: ObservableObject {
    @Published private(set) var state: ResearchState = .unverified
    @Published private(set) var snapshot: ResearchSnapshot?
    @Published private(set) var logs: [ResearchLog] = []
    @Published var allowLocalTests: Bool {
        didSet { UserDefaults.standard.set(allowLocalTests, forKey: "reims.allowLocalTests") }
    }

    init() {
        // O consentimento não é necessário para mostrar diagnósticos passivos.
        allowLocalTests = UserDefaults.standard.bool(forKey: "reims.allowLocalTests")
        addLog("INFO", "ReimsJB 0.6 iniciado. Nenhuma modificação no sistema.")
    }

    func addLog(_ level: String, _ message: String) {
        logs.append(ResearchLog(time: Date(), level: level, message: message))
        if logs.count > 300 { logs.removeFirst(logs.count - 300) }
    }

    func inspect() {
        guard state != .checking else { return }
        state = .checking
        addLog("INFO", "Iniciando verificação não destrutiva de metadados.")
        let report = DeviceReport.capture()
        let output = ReimsResearchEngine.assess(device: report)
        snapshot = output
        state = output.targetMatched ? .indeterminate : .incompatible
        addLog("DEVICE", "\(report.identifier) / iOS \(report.systemVersion) / \(report.build) / kernel \(report.kernelRelease)")
        addLog("RESULT", output.targetMatched
            ? "Alvo identificado. KRW/SPTM/bootstrap ainda sem validação."
            : "Dispositivo não corresponde integralmente ao alvo configurado.")
        addLog("GATE", "Jailbreak bloqueado: \(output.gate.missing.joined(separator: "; ")).")
    }

    var exportedLog: String {
        let lines = logs.map { entry in
            "[\(entry.time.formatted(date: .numeric, time: .standard))] \(entry.level): \(entry.message)"
        }
        return (["ReimsJB 0.6 — logs locais", "Sem alterações no iOS", ""] + lines).joined(separator: "\n")
    }

    var exportedReport: String {
        guard let snapshot else { return "ReimsJB 0.6: ainda não verificado." }
        var lines = [
            "ReimsJB 0.6 — relatório de compatibilidade",
            "Data: \(snapshot.checkedAt.formatted())",
            snapshot.device.exportText,
            "",
            "Componentes:"
        ]
        for component in snapshot.components {
            lines.append("- \(component.id.title): \(component.state.label)")
            lines.append("  \(component.detail)")
            lines.append("  Evidência: \(component.evidence)")
        }
        lines.append("Jailbreak habilitado: \(snapshot.gate.canRun ? "sim" : "não")")
        lines.append("Pendências: \(snapshot.gate.missing.joined(separator: "; "))")
        lines.append("Conclusão: nenhuma exploração foi executada.")
        return lines.joined(separator: "\n")
    }
}
