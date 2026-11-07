import Foundation
import SwiftUI
import CryptoKit

enum EvidenceStage: String, Codable, CaseIterable {
    case hypothesis, observed, reproduced, impactValidated, independentlyConfirmed
    case inconclusive, fixedOrKnown

    var label: String {
        switch self {
        case .hypothesis: return "Hipótese"
        case .observed: return "Observado"
        case .reproduced: return "Reproduzido"
        case .impactValidated: return "Impacto validado"
        case .independentlyConfirmed: return "Confirmação independente"
        case .inconclusive: return "Inconclusivo"
        case .fixedOrKnown: return "Conhecido/corrigido"
        }
    }
}

struct EvidenceRecord: Codable, Identifiable {
    var id: UUID
    var createdAt: Date
    var title: String
    var stage: EvidenceStage
    var component: String
    var expected: String
    var observed: String
    var method: String
    var sourceURL: String
    var inputSHA256: String
    var attempts: Int
    var confirmedSecurityImpact: String
    var reviewedByHuman: Bool

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        title: String,
        stage: EvidenceStage = .hypothesis,
        component: String,
        expected: String,
        observed: String = "",
        method: String = "",
        sourceURL: String = "",
        inputSHA256: String = "",
        attempts: Int = 0,
        confirmedSecurityImpact: String = "",
        reviewedByHuman: Bool = false
    ) {
        self.id = id
        self.createdAt = createdAt
        self.title = title
        self.stage = stage
        self.component = component
        self.expected = expected
        self.observed = observed
        self.method = method
        self.sourceURL = sourceURL
        self.inputSHA256 = inputSHA256
        self.attempts = attempts
        self.confirmedSecurityImpact = confirmedSecurityImpact
        self.reviewedByHuman = reviewedByHuman
    }
}

enum EvidenceValidator {
    static func isSHA256(_ text: String) -> Bool {
        text.count == 64 &&
        text.unicodeScalars.allSatisfy {
            CharacterSet(charactersIn: "0123456789abcdefABCDEF").contains($0)
        }
    }

    static func canTransition(_ record: EvidenceRecord, to stage: EvidenceStage) -> Bool {
        if stage == .inconclusive || stage == .fixedOrKnown { return true }
        switch stage {
        case .hypothesis: return record.stage == .hypothesis
        case .observed:
            return record.stage == .hypothesis &&
                !record.observed.isEmpty && !record.method.isEmpty
        case .reproduced:
            return record.stage == .observed && record.attempts >= 2 &&
                isSHA256(record.inputSHA256)
        case .impactValidated:
            return record.stage == .reproduced && record.reviewedByHuman &&
                !record.confirmedSecurityImpact.isEmpty
        case .independentlyConfirmed:
            return record.stage == .impactValidated && record.reviewedByHuman &&
                record.attempts >= 3
        case .inconclusive, .fixedOrKnown:
            return true
        }
    }
}

struct SyntheticExperimentResult {
    let passed: Bool
    let attempts: Int
    let inputHash: String
    let expected: String
    let observed: String
}

// Experimento benigno, determinístico, apenas em Foundation, sem arquivos externos.
enum SafeEvidenceExperiment {
    static func jsonRoundTrip() -> SyntheticExperimentResult {
        let fixture: [String: Any] = ["title": "ReimsJB", "value": 27, "active": true]
        do {
            let data = try JSONSerialization.data(withJSONObject: fixture, options: [.sortedKeys])
            let output = try JSONSerialization.jsonObject(with: data)
            let decoded = output as? [String: Any]
            let matched = (decoded?["title"] as? String == "ReimsJB")
                && (decoded?["value"] as? Int == 27)
                && (decoded?["active"] as? Bool == true)
            let sha = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
            return SyntheticExperimentResult(
                passed: matched, attempts: 1, inputHash: sha,
                expected: "JSON serializado deve preservar três campos conhecidos.",
                observed: matched
                    ? "Dados preservados na rodada sintética."
                    : "Inconsistência no teste de JSON: investigar ambiente e fixture."
            )
        } catch {
            return SyntheticExperimentResult(
                passed: false, attempts: 1, inputHash: "",
                expected: "Serialização e leitura do JSON sintético.",
                observed: "Falha da API durante o experimento: \(error.localizedDescription)"
            )
        }
    }
}

@MainActor
final class EvidenceVault: ObservableObject {
    @Published private(set) var records: [EvidenceRecord] = []
    @Published private(set) var lastError: String?

    init() { load() }

    func addHypothesis(title: String, component: String, expected: String, sourceURL: String) {
        let clean = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let rationale = expected.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty && !rationale.isEmpty else {
            lastError = "Preencha o título e o resultado esperado."
            return
        }
        records.insert(
            EvidenceRecord(title: String(clean.prefix(160)), component: component,
                expected: String(rationale.prefix(2000)),
                sourceURL: String(sourceURL.prefix(1000))),
            at: 0
        )
        save()
    }

    func runSyntheticJSONTest() {
        let output = SafeEvidenceExperiment.jsonRoundTrip()
        let item = EvidenceRecord(
            title: "Teste de regressão: JSON sintético",
            stage: output.passed ? .observed : .inconclusive,
            component: "Foundation",
            expected: output.expected,
            observed: output.observed,
            method: "JSONSerialization com fixture constante; execução local não privilegiada.",
            inputSHA256: output.inputHash,
            attempts: output.attempts
        )
        records.insert(item, at: 0)
        save()
    }

    func delete(_ id: UUID) {
        records.removeAll { $0.id == id }
        save()
    }

    private func fileURL() throws -> URL {
        let fm = FileManager.default
        let directory = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ReimsResearch", isDirectory: true)
        try fm.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("evidence.json")
    }

    private func load() {
        do {
            let path = try fileURL()
            guard FileManager.default.fileExists(atPath: path.path) else { return }
            let data = try Data(contentsOf: path)
            records = try JSONDecoder().decode([EvidenceRecord].self, from: data)
        } catch {
            lastError = "Falha ao ler evidências locais: \(error.localizedDescription)"
        }
    }

    private func save() {
        do {
            let path = try fileURL()
            let data = try JSONEncoder().encode(records)
            try data.write(to: path, options: .atomic)
            lastError = nil
        } catch {
            lastError = "Falha ao salvar evidências: \(error.localizedDescription)"
        }
    }
}

enum SecurityReportBuilder {
    static func export(_ record: EvidenceRecord, device: DeviceReport?) -> String {
        let system = device.map { "\($0.identifier) / iOS \($0.systemVersion) / \($0.build)" }
            ?? "Dispositivo não informado"
        return [
            "# ReimsJB 0.6 — rascunho confidencial de pesquisa",
            "NÃO SUBMETIDO À APPLE. Revisão humana obrigatória.",
            "Data: \(ISO8601DateFormatter().string(from: record.createdAt))",
            "Identificador: \(record.id.uuidString)",
            "Estado da evidência: \(record.stage.label)",
            "Título: \(record.title)",
            "Componente: \(record.component)",
            "Ambiente: \(system)",
            "Comportamento esperado: \(record.expected)",
            "Comportamento observado: \(record.observed.isEmpty ? "não testado" : record.observed)",
            "Método: \(record.method.isEmpty ? "não informado" : record.method)",
            "Número de execuções: \(record.attempts)",
            "SHA-256 da entrada: \(record.inputSHA256.isEmpty ? "não disponível" : record.inputSHA256)",
            "Fonte: \(record.sourceURL.isEmpty ? "não indicada" : record.sourceURL)",
            "Impacto de segurança verificado: \(record.confirmedSecurityImpact.isEmpty ? "não demonstrado" : record.confirmedSecurityImpact)",
            "Revisão humana: \(record.reviewedByHuman ? "sim" : "não")",
            "Limitações: testes de sandbox não demonstram bypass, KRW ou jailbreak.",
            "Próximos passos: reproduzir, excluir regressões conhecidas e validar impacto antes de relatar.",
            "Preserve sigilo; não publique vulnerabilidade inédita no repositório."
        ].joined(separator: "\n")
    }
}
